import 'package:flutter/material.dart';

import '../data/challenge_repository.dart';
import '../data/logbook_repository.dart';
import '../generated/l10n.dart';
import '../router.dart';
import '../theme/app_spacing.dart';

class LogbookPage extends StatefulWidget {
  const LogbookPage({super.key});

  @override
  State<LogbookPage> createState() => _LogbookPageState();
}

class _LogbookPageState extends State<LogbookPage> {
  List<Map<String, dynamic>> _entries = [];
  bool _loading = true;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  static const int _pageSize = 50;

  String? _statusFilter;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  /// challenge_id → localized title, loaded once per locale.
  Map<String, String> _idToTitle = {};
  String _locale = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final q = _searchController.text.trim();
      if (q != _searchQuery) {
        setState(() => _searchQuery = q);
        _loadEntries();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context).languageCode;
    if (locale != _locale) {
      _locale = locale;
      _loadChallengeTitles(locale);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadChallengeTitles(String locale) async {
    final challenges = await ChallengeRepository.instance.loadChallenges(locale);
    if (!mounted) return;
    setState(() {
      _idToTitle = {for (final c in challenges) c.id: c.title};
    });
    _loadEntries();
  }

  Future<void> _loadEntries({bool append = false}) async {
    if (_isLoadingMore) return;
    setState(() {
      if (!append) _loading = true;
      _isLoadingMore = append;
    });

    Set<String>? challengeIds;
    if (_searchQuery.isNotEmpty && _idToTitle.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      challengeIds = _idToTitle.entries
          .where((e) => e.value.toLowerCase().contains(q))
          .map((e) => e.key)
          .toSet();
      if (challengeIds.isEmpty) {
        setState(() {
          _entries = [];
          _hasMore = false;
          _loading = false;
          _isLoadingMore = false;
        });
        return;
      }
    }

    final result = await LogbookRepository.instance.filteredEntries(
      limit: _pageSize,
      offset: append ? _entries.length : 0,
      status: _statusFilter,
      challengeIds: challengeIds,
    );

    setState(() {
      if (append) {
        _entries = [..._entries, ...result];
      } else {
        _entries = result;
      }
      _hasMore = result.length == _pageSize;
      _loading = false;
      _isLoadingMore = false;
    });
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return '-';
    try {
      final dt = DateTime.parse(timestamp);
      return '${dt.day.toString().padLeft(2, '0')}.'
          '${dt.month.toString().padLeft(2, '0')}.'
          '${dt.year}  '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l.logbook)),
      body: Column(
        children: [
          // ── Search bar ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l.logbookSearchHint,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: _searchController.clear,
                      )
                    : null,
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: cs.surfaceContainerHighest,
              ),
            ),
          ),

          // ── Status filter chips ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            child: Row(
              children: [
                _FilterChip(
                  label: l.logbookFilterAll,
                  selected: _statusFilter == null,
                  onTap: () => setState(() {
                    _statusFilter = null;
                    _loadEntries();
                  }),
                ),
                const SizedBox(width: AppSpacing.xs),
                _FilterChip(
                  label: l.logbookFilterCompleted,
                  selected: _statusFilter == 'success',
                  onTap: () => setState(() {
                    _statusFilter = 'success';
                    _loadEntries();
                  }),
                ),
                const SizedBox(width: AppSpacing.xs),
                _FilterChip(
                  label: l.logbookFilterTried,
                  selected: _statusFilter == 'tried',
                  onTap: () => setState(() {
                    _statusFilter = 'tried';
                    _loadEntries();
                  }),
                ),
              ],
            ),
          ),

          // ── Entry list ─────────────────────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _entries.isEmpty
                    ? _EmptyState()
                    : NotificationListener<ScrollNotification>(
                        onNotification: (info) {
                          if (_hasMore &&
                              !_isLoadingMore &&
                              info.metrics.pixels >=
                                  info.metrics.maxScrollExtent - 200) {
                            _loadEntries(append: true);
                          }
                          return false;
                        },
                        child: RefreshIndicator(
                          onRefresh: _loadEntries,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            itemCount:
                                _entries.length + (_isLoadingMore ? 1 : 0),
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: AppSpacing.sm),
                            itemBuilder: (context, i) {
                              if (i >= _entries.length) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(AppSpacing.md),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              final entry = _entries[i];
                              final title = _idToTitle[
                                      entry['challenge_id']?.toString()] ??
                                  entry['challenge_id']?.toString() ??
                                  '';
                              return _LogbookEntryTile(
                                entry: entry,
                                title: title,
                                timestamp: _formatTimestamp(
                                    entry['timestamp']?.toString()),
                                onTap: () async {
                                  await context.goLogbookDetail(entry, title);
                                  _loadEntries();
                                },
                              );
                            },
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// ─── Filter chip ──────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: selected ? cs.primaryContainer : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.outlineVariant),
          const SizedBox(height: AppSpacing.md),
          Text(
            S.of(context).noEntriesYet,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

// ─── Entry tile ───────────────────────────────────────────────────────────────

class _LogbookEntryTile extends StatelessWidget {
  final Map<String, dynamic> entry;
  final String title;
  final String timestamp;
  final VoidCallback onTap;

  const _LogbookEntryTile({
    required this.entry,
    required this.title,
    required this.timestamp,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final earned = (entry['earned'] as int?) ?? 0;
    final status = entry['status']?.toString() ?? '';
    final isSuccess = status == 'success';
    final xpColor = isSuccess ? cs.primary : cs.tertiary;
    final feeling = entry['feeling'] as int?;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSuccess
                      ? cs.primaryContainer
                      : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isSuccess
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 22,
                  color: isSuccess
                      ? cs.onPrimaryContainer
                      : cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timestamp,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: cs.outline),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${earned >= 0 ? '+' : ''}$earned XP',
                    style: TextStyle(
                      color: xpColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  if (feeling != null)
                    Icon(_feelingIcon(feeling),
                        size: 18, color: _feelingColor(feeling)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _feelingIcon(int f) {
    const icons = [
      Icons.sentiment_very_dissatisfied,
      Icons.sentiment_dissatisfied,
      Icons.sentiment_neutral,
      Icons.sentiment_satisfied,
      Icons.sentiment_very_satisfied,
    ];
    return icons[f.clamp(0, 4)];
  }

  Color _feelingColor(int f) {
    const colors = [
      Colors.red,
      Colors.orange,
      Colors.amber,
      Colors.lightGreen,
      Colors.green,
    ];
    return colors[f.clamp(0, 4)];
  }
}
