import 'package:flutter/material.dart';

import '../data/logbook_repository.dart';
import '../generated/l10n.dart';
import '../theme/app_spacing.dart';
import 'logbook_detail_page.dart';

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

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries({bool append = false}) async {
    if (_isLoadingMore) return;
    setState(() {
      if (!append) _loading = true;
      _isLoadingMore = append;
    });

    final result = await LogbookRepository.instance.allEntries(
      limit: _pageSize,
      offset: append ? _entries.length : 0,
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
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).logbook)),
      body: _loading
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
                        return _LogbookEntryTile(
                          index: i,
                          entry: _entries[i],
                          timestamp:
                              _formatTimestamp(_entries[i]['timestamp']?.toString()),
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => LogbookDetailPage(
                                    entry: _entries[i]),
                              ),
                            );
                            _loadEntries();
                          },
                        );
                      },
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
          Icon(Icons.book_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: AppSpacing.md),
          Text(
            S.of(context).noEntriesYet,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            S.of(context).completeChallengesToSee,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Entry tile ───────────────────────────────────────────────────────────────

class _LogbookEntryTile extends StatelessWidget {
  final int index;
  final Map<String, dynamic> entry;
  final String timestamp;
  final VoidCallback onTap;

  const _LogbookEntryTile({
    required this.index,
    required this.entry,
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
              // Index badge
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: cs.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).challengeNumber(entry['challenge_id'].toString()),
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
