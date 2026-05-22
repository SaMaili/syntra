// logbook_page.dart — V2 layout.
//
//   • Animated title ↔ search field swap in the header
//   • Mood ribbon hero (this-month count + 8-week mini bar chart + delta chip)
//   • Brand pill filters with counts (All / Completed / Tried)
//   • Entries grouped by ISO year-week with eyebrow headers
//   • Each row: before-face → arrow → after-face / title + date / aura / chevron
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/challenge_repository.dart';
import '../data/logbook_repository.dart';
import '../generated/l10n.dart';
import '../logic/weekly_streak_logic.dart';
import '../router.dart';
import '../theme/brand_colors.dart';
import '../widgets/syntra_chip.dart';

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
  bool _searching = false;
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  String _searchQuery = '';

  /// challenge_id → localized title.
  Map<String, String> _idToTitle = {};
  String _locale = '';

  /// Total counts per status (drives the pill badges; recomputed when entries
  /// load or after a detail edit). null = still loading.
  int? _countAll, _countCompleted, _countTried;

  /// 8-week mood-after series (most recent last). null = no data for that week.
  List<double?> _weeklyMoodAfter = const [];
  int _monthCount = 0;
  int? _moodDeltaPct;

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
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _loadChallengeTitles(String locale) async {
    final challenges =
        await ChallengeRepository.instance.loadChallenges(locale);
    if (!mounted) return;
    setState(() {
      _idToTitle = {for (final c in challenges) c.id: c.title};
    });
    _loadEntries();
    _loadRibbon();
    _loadCounts();
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

    if (!mounted) return;
    setState(() {
      _entries = append ? [..._entries, ...result] : result;
      _hasMore = result.length == _pageSize;
      _loading = false;
      _isLoadingMore = false;
    });
  }

  Future<void> _loadCounts() async {
    final all = await LogbookRepository.instance
        .filteredEntries(limit: 100000, offset: 0);
    if (!mounted) return;
    final completed = all.where((e) => e['status'] == 'success').length;
    final tried = all.where((e) => e['status'] == 'tried').length;
    setState(() {
      _countAll = all.length;
      _countCompleted = completed;
      _countTried = tried;
    });
  }

  /// Computes the mood ribbon: this-month count + 8-week mood averages + delta.
  Future<void> _loadRibbon() async {
    final rows = await LogbookRepository.instance
        .filteredEntries(limit: 600, offset: 0);
    if (!mounted) return;
    final now = DateTime.now();
    final currentMonth = (now.year, now.month);

    // This-month count
    final monthCount = rows.where((r) {
      final ts = DateTime.tryParse(r['timestamp']?.toString() ?? '');
      if (ts == null) return false;
      return ts.year == currentMonth.$1 && ts.month == currentMonth.$2;
    }).length;

    // 8-week mood-after averages
    final mondayThisWeek = WeeklyStreakLogic.startOfIsoWeek(now);
    final buckets = List<List<int>>.generate(8, (_) => <int>[]);
    for (final r in rows) {
      final ts = DateTime.tryParse(r['timestamp']?.toString() ?? '');
      if (ts == null) continue;
      final monday = WeeklyStreakLogic.startOfIsoWeek(ts);
      final diffDays = mondayThisWeek.difference(monday).inDays;
      final weekIdx = 7 - (diffDays ~/ 7); // 0..7 (oldest..newest)
      if (weekIdx < 0 || weekIdx >= 8) continue;
      final feeling = r['feeling'];
      if (feeling is int) buckets[weekIdx].add(feeling);
    }
    final averages = buckets.map<double?>((b) {
      if (b.isEmpty) return null;
      return b.reduce((a, c) => a + c) / b.length;
    }).toList();

    // Delta: avg of last 2 weeks vs first 2 weeks of the 8.
    final recent = averages.sublist(6).whereType<double>().toList();
    final older = averages.sublist(0, 2).whereType<double>().toList();
    int? delta;
    if (recent.isNotEmpty && older.isNotEmpty) {
      final r = recent.reduce((a, b) => a + b) / recent.length;
      final o = older.reduce((a, b) => a + b) / older.length;
      if (o > 0) {
        delta = (((r - o) / o) * 100).round();
      }
    }

    setState(() {
      _weeklyMoodAfter = averages;
      _monthCount = monthCount;
      _moodDeltaPct = delta;
    });
  }

  void _toggleSearch() {
    HapticFeedback.selectionClick();
    setState(() => _searching = !_searching);
    if (_searching) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocus.requestFocus();
      });
    } else {
      _searchController.clear();
      _searchFocus.unfocus();
    }
  }

  void _setStatusFilter(String? value) {
    HapticFeedback.selectionClick();
    setState(() => _statusFilter = value);
    _loadEntries();
  }

  String _formatRowDate(DateTime ts, S l) {
    final wd = _weekday(ts.weekday, l);
    final hh = ts.hour.toString().padLeft(2, '0');
    final mm = ts.minute.toString().padLeft(2, '0');
    return '$wd · $hh:$mm';
  }

  String _weekday(int wd, S l) {
    switch (wd) {
      case 1:
        return l.weekdayShortMon;
      case 2:
        return l.weekdayShortTue;
      case 3:
        return l.weekdayShortWed;
      case 4:
        return l.weekdayShortThu;
      case 5:
        return l.weekdayShortFri;
      case 6:
        return l.weekdayShortSat;
      default:
        return l.weekdayShortSun;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffold = Theme.of(context).scaffoldBackgroundColor;
    final topInset = MediaQuery.viewPaddingOf(context).top;

    return Scaffold(
      backgroundColor: scaffold,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            SizedBox(height: topInset + 8),
            _Header(
              searching: _searching,
              controller: _searchController,
              focusNode: _searchFocus,
              onToggleSearch: _toggleSearch,
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
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
                        onRefresh: () async {
                          await Future.wait([
                            _loadEntries(),
                            _loadRibbon(),
                            _loadCounts(),
                          ]);
                        },
                        child: CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                              child: _MoodRibbon(
                                monthCount: _monthCount,
                                deltaPct: _moodDeltaPct,
                                weeklyAfter: _weeklyMoodAfter,
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: _FilterRow(
                                statusFilter: _statusFilter,
                                countAll: _countAll,
                                countCompleted: _countCompleted,
                                countTried: _countTried,
                                onChanged: _setStatusFilter,
                              ),
                            ),
                            if (_entries.isEmpty)
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: _EmptyState(),
                              )
                            else
                              ..._buildGroupedSlivers(context, l, isDark),
                            SliverToBoxAdapter(
                              child: _isLoadingMore
                                  ? const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(
                                          child: CircularProgressIndicator()),
                                    )
                                  : SizedBox(
                                      height:
                                          MediaQuery.viewPaddingOf(context)
                                                  .bottom +
                                              16,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Groups loaded entries by ISO year-week (most recent first) and renders
  // a header sliver + a list sliver per group.
  List<Widget> _buildGroupedSlivers(BuildContext context, S l, bool isDark) {
    final groups = <String, List<Map<String, dynamic>>>{};
    final groupOrder = <String>[];
    final groupLabels = <String, String>{};

    final now = DateTime.now();
    final mondayThisWeek = WeeklyStreakLogic.startOfIsoWeek(now);

    for (final e in _entries) {
      final ts = DateTime.tryParse(e['timestamp']?.toString() ?? '');
      if (ts == null) continue;
      final monday = WeeklyStreakLogic.startOfIsoWeek(ts);
      final key = WeeklyStreakLogic.isoYearWeek(monday);
      final diff = mondayThisWeek.difference(monday).inDays;
      String label;
      if (diff < 7 && diff >= 0) {
        label = l.weekGroupThis;
      } else if (diff < 14 && diff >= 7) {
        label = l.weekGroupLast;
      } else if (diff < 28) {
        label = l.weekGroupAgoWeeks((diff ~/ 7));
      } else {
        label = '${ts.year}-${ts.month.toString().padLeft(2, '0')}';
      }
      groups.putIfAbsent(key, () {
        groupOrder.add(key);
        groupLabels[key] = label;
        return <Map<String, dynamic>>[];
      }).add(e);
    }

    final slivers = <Widget>[];
    for (final key in groupOrder) {
      final group = groups[key]!;
      final total = group.fold<int>(
          0, (a, e) => a + ((e['aura'] as int?) ?? 0));
      slivers.add(SliverToBoxAdapter(
        child: _WeekHeader(
          label: groupLabels[key] ?? '',
          entries: group.length,
          totalAura: total,
        ),
      ));
      slivers.add(SliverList.builder(
        itemCount: group.length,
        itemBuilder: (context, i) {
          final entry = group[i];
          final id = entry['challenge_id']?.toString() ?? '';
          final title = _idToTitle[id] ?? id;
          final ts = DateTime.tryParse(entry['timestamp']?.toString() ?? '');
          final dateLabel = ts == null ? '-' : _formatRowDate(ts, l);
          final isFirst = i == 0;
          final isLast = i == group.length - 1;
          return _LogRow(
            entry: entry,
            title: title,
            date: dateLabel,
            isFirst: isFirst,
            isLast: isLast,
            onTap: () async {
              await context.goLogbookDetail(entry, title);
              if (!mounted) return;
              _loadEntries();
              _loadRibbon();
              _loadCounts();
            },
          );
        },
      ));
    }
    return slivers;
  }
}

// ─── Header (back + animated title/search) ──────────────────────────────────

class _Header extends StatelessWidget {
  final bool searching;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onToggleSearch;
  final VoidCallback onBack;

  const _Header({
    required this.searching,
    required this.controller,
    required this.focusNode,
    required this.onToggleSearch,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = SyntraSurface.of(context);
    final l = S.of(context);
    final titleColor = isDark ? Colors.white : cs.onSurface;
    final fieldBg = s.bg2;
    final fieldBorder = isDark ? s.bg4 : s.bg3;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: Icon(Icons.arrow_back_rounded,
                size: 22, color: titleColor),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          ),
          Expanded(
            child: SizedBox(
              height: 40,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.25),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: searching
                    ? Container(
                        key: const ValueKey('search'),
                        height: 36,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          color: fieldBg,
                          border: Border.all(color: fieldBorder, width: 1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Icon(Icons.search_rounded,
                                  size: 16,
                                  color: cs.onSurfaceVariant),
                            ),
                            Expanded(
                              child: TextField(
                                controller: controller,
                                focusNode: focusNode,
                                textInputAction: TextInputAction.search,
                                style: tt.bodyMedium
                                    ?.copyWith(color: cs.onSurface),
                                decoration: InputDecoration(
                                  hintText: l.logbookSearchHint,
                                  hintStyle: tt.bodyMedium?.copyWith(
                                      color: cs.onSurfaceVariant),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 8),
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Align(
                        key: const ValueKey('title'),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l.logbook,
                          style: tt.headlineMedium?.copyWith(
                            fontFamily: 'Octarine',
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                            letterSpacing: -0.4,
                            color: titleColor,
                          ),
                        ),
                      ),
              ),
            ),
          ),
          IconButton(
            onPressed: onToggleSearch,
            tooltip: l.logbookSearchHint,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, animation) => RotationTransition(
                turns: Tween<double>(begin: 0.7, end: 1).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Icon(
                searching ? Icons.close_rounded : Icons.search_rounded,
                key: ValueKey(searching),
                size: 22,
                color: titleColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Mood ribbon hero ───────────────────────────────────────────────────────

class _MoodRibbon extends StatelessWidget {
  final int monthCount;
  final int? deltaPct;
  final List<double?> weeklyAfter; // 8 buckets, oldest..newest, null = no data

  const _MoodRibbon({
    required this.monthCount,
    required this.deltaPct,
    required this.weeklyAfter,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = S.of(context);
    const green = BrandColors.green;
    const greenSoft = BrandColors.greenSoft;
    const greenLight = BrandColors.greenLight;
    final scaffold = Theme.of(context).scaffoldBackgroundColor;
    final valueColor = isDark ? Colors.white : cs.onSurface;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            green.withValues(alpha: 0.10),
            scaffold,
          ],
          stops: const [0.0, 0.6],
        ),
        border: Border.all(color: green.withValues(alpha: 0.22), width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.logbookThisMonth.toUpperCase(),
                        style: tt.labelSmall?.copyWith(
                          color: greenLight,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$monthCount',
                            style: tt.displaySmall?.copyWith(
                              fontFamily: 'Octarine',
                              fontWeight: FontWeight.w700,
                              fontSize: 32,
                              letterSpacing: -0.6,
                              color: valueColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              l.logbookChallengesPlural,
                              style: tt.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (deltaPct != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: green.withValues(alpha: 0.16),
                      border: Border.all(
                          color: green.withValues(alpha: 0.32), width: 1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          deltaPct! >= 0
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          size: 13,
                          color: greenSoft,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l.logbookMoodDelta(deltaPct!),
                          style: TextStyle(
                            fontFamily: 'Octarine',
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: greenSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 44,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (int i = 0; i < weeklyAfter.length; i++) ...[
                    if (i > 0) const SizedBox(width: 6),
                    Expanded(
                      child: _MoodBar(
                        // Map avg 0..4 → 0..1; null gets a faint stub.
                        fraction: weeklyAfter[i] == null
                            ? 0.10
                            : (weeklyAfter[i]! / 4.0).clamp(0.18, 1.0),
                        recent: i >= weeklyAfter.length - 2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l.logbookEightWksAgo,
                  style: tt.labelSmall?.copyWith(
                    color: cs.outline,
                    fontSize: 10,
                    letterSpacing: 0.4,
                  ),
                ),
                Text(
                  l.logbookNow,
                  style: tt.labelSmall?.copyWith(
                    color: cs.outline,
                    fontSize: 10,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodBar extends StatelessWidget {
  final double fraction;
  final bool recent;
  const _MoodBar({required this.fraction, required this.recent});

  @override
  Widget build(BuildContext context) {
    const green = BrandColors.green;
    const greenSoft = BrandColors.greenSoft;
    return FractionallySizedBox(
      heightFactor: fraction,
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: BoxDecoration(
          gradient: recent
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [greenSoft, green],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [BrandColors.greenInk, BrandColors.greenInkDark],
                ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(3),
            topRight: Radius.circular(3),
            bottomLeft: Radius.circular(1),
            bottomRight: Radius.circular(1),
          ),
          boxShadow: recent
              ? [
                  BoxShadow(
                    color: green.withValues(alpha: 0.4),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}

// ─── Filter pill row ────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  final String? statusFilter;
  final int? countAll;
  final int? countCompleted;
  final int? countTried;
  final ValueChanged<String?> onChanged;

  const _FilterRow({
    required this.statusFilter,
    required this.countAll,
    required this.countCompleted,
    required this.countTried,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        // Don't hard-clip: the active chip's soft glow extends past the row
        // and would otherwise be sliced into a rectangle.
        clipBehavior: Clip.none,
        child: Row(
          children: [
            SyntraChip(
              active: statusFilter == null,
              onTap: () => onChanged(null),
              label: l.logbookFilterAll,
              count: countAll,
            ),
            const SizedBox(width: 8),
            SyntraChip(
              active: statusFilter == 'success',
              onTap: () => onChanged('success'),
              label: l.logbookFilterCompleted,
              count: countCompleted,
            ),
            const SizedBox(width: 8),
            SyntraChip(
              active: statusFilter == 'tried',
              onTap: () => onChanged('tried'),
              label: l.logbookFilterTried,
              count: countTried,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Week-group header ──────────────────────────────────────────────────────

class _WeekHeader extends StatelessWidget {
  final String label;
  final int entries;
  final int totalAura;

  const _WeekHeader({
    required this.label,
    required this.entries,
    required this.totalAura,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 8),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                style: tt.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  fontSize: 11,
                ),
                children: [
                  TextSpan(text: label.toUpperCase()),
                  TextSpan(
                    text: '  · ${l.logbookEntriesCount(entries)}',
                    style: TextStyle(color: cs.outline),
                  ),
                ],
              ),
            ),
          ),
          Text(
            '+$totalAura ${l.auraPoints}',
            style: tt.labelMedium?.copyWith(
              fontFamily: 'Octarine',
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: cs.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Log row (before → after / title / date / aura / chevron) ───────────────

class _LogRow extends StatelessWidget {
  final Map<String, dynamic> entry;
  final String title;
  final String date;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  const _LogRow({
    required this.entry,
    required this.title,
    required this.date,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = S.of(context);
    final s = SyntraSurface.of(context);
    final divider = isDark ? s.bg2 : s.bg3;
    final titleColor = isDark ? Colors.white : cs.onSurface;

    final preAnxiety = entry['pre_anxiety'] as int?;
    final feelingAfter = entry['feeling'] as int?;
    // pre_anxiety is 1..5 where 5 = very nervous. Convert to a 0..4 "calm"
    // index where 4 = totally calm.
    final beforeIdx = preAnxiety == null ? null : (5 - preAnxiety).clamp(0, 4);
    final improved = (beforeIdx != null && feelingAfter != null)
        ? feelingAfter > beforeIdx
        : false;

    final aura = (entry['aura'] as int?) ?? 0;
    final auraColor = aura > 0 ? cs.primary : cs.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: divider, width: 1),
              bottom: isLast
                  ? BorderSide(color: divider, width: 1)
                  : BorderSide.none,
            ),
          ),
          child: Row(
            children: [
              _MoodArrow(
                beforeIdx: beforeIdx,
                afterIdx: feelingAfter,
                improved: improved,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleSmall?.copyWith(
                        fontFamily: 'Octarine',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      date,
                      style: tt.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '+$aura',
                style: tt.bodyMedium?.copyWith(
                  color: auraColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                semanticsLabel:
                    '${entry['aura']} ${l.auraPoints}',
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: cs.outline),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoodArrow extends StatelessWidget {
  final int? beforeIdx;
  final int? afterIdx;
  final bool improved;

  const _MoodArrow({
    required this.beforeIdx,
    required this.afterIdx,
    required this.improved,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const improvedColor = BrandColors.greenSoft;
    final mutedArrow = cs.outline;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MoodGlyph(idx: beforeIdx, size: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            Icons.arrow_forward_rounded,
            size: 11,
            color: improved ? improvedColor : mutedArrow,
          ),
        ),
        _MoodGlyph(idx: afterIdx, size: 22),
      ],
    );
  }
}

class _MoodGlyph extends StatelessWidget {
  final int? idx;
  final double size;
  const _MoodGlyph({required this.idx, required this.size});

  static const _icons = [
    Icons.sentiment_very_dissatisfied,
    Icons.sentiment_dissatisfied,
    Icons.sentiment_neutral,
    Icons.sentiment_satisfied,
    Icons.sentiment_very_satisfied,
  ];
  static const _colors = [
    BrandColors.redSoft,
    BrandColors.amberWarm,
    BrandColors.amber,
    BrandColors.green,
    BrandColors.greenSoft,
  ];

  @override
  Widget build(BuildContext context) {
    if (idx == null) {
      final cs = Theme.of(context).colorScheme;
      return Icon(Icons.help_outline_rounded,
          size: size, color: cs.outlineVariant);
    }
    final i = idx!.clamp(0, 4);
    return Icon(_icons[i], size: size, color: _colors[i]);
  }
}

// ─── Empty state ────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book_rounded,
              size: 64, color: cs.outlineVariant),
          const SizedBox(height: 16),
          Text(
            S.of(context).noEntriesYet,
            style: tt.bodyLarge,
          ),
        ],
      ),
    );
  }
}
