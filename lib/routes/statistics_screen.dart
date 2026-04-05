import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../generated/l10n.dart';
import '../logic/badges_logic.dart';
import '../providers/statistics_providers.dart';
import '../theme/app_spacing.dart';
import '../widgets/syntra_button.dart';
import 'logbook_page.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).yourStatistics)),
      body: RefreshIndicator(
        onRefresh: () async => refreshStatistics(ref),
        child: ListView(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          children: [
            const _WeeklyGoalCard(),
            const SizedBox(height: AppSpacing.md),
            const _OverviewGrid(),
            const SizedBox(height: AppSpacing.md),
            const _BadgesSection(),
            const SizedBox(height: AppSpacing.md),
            const _ActivityCalendar(),
            const SizedBox(height: AppSpacing.md),
            _LogbookButton(),
            const SizedBox(height: AppSpacing.md),
            const _WeeklyCountChart(),
            const SizedBox(height: AppSpacing.md),
            const _WeeklyXpChart(),
            const SizedBox(height: AppSpacing.md),
            const _AverageMoodCard(),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

// ─── Overview grid ────────────────────────────────────────────────────────────

class _OverviewGrid extends ConsumerWidget {
  const _OverviewGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(overviewStatsProvider);
    final bestStreakAsync = ref.watch(personalBestStreakProvider);

    return async.when(
      loading: () => const _StatsShimmer(),
      error: (e, _) => Text('Error: $e'),
      data: (stats) {
        final l = S.of(context);
        final cs = Theme.of(context).colorScheme;
        final bestStreak = bestStreakAsync.valueOrNull ?? 0;
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 1.3,
          children: [
            _StatCard(
              icon: Icons.emoji_events,
              value: '${stats['totalXp']}',
              label: l.totalXp,
              color: cs.primary,
            ),
            _StatCard(
              icon: Icons.local_fire_department,
              value: '${stats['streak']}',
              label: l.dayStreak,
              color: const Color(0xFFFF6D00), // Reddish Orange
            ),
            _StatCard(
              icon: Icons.directions_run_rounded,
              value: '${stats['completedAllTime']}',
              label: l.timesTried,
              color: cs.secondary,
            ),
            _StatCard(
              icon: Icons.timer_outlined,
              value: '${stats['minutesBrave'] ?? 0}',
              label: l.minutesBrave,
              color: Colors.blueAccent,
            ),
            _StatCard(
              icon: Icons.military_tech_rounded,
              value: '$bestStreak',
              label: l.bestStreak,
              color: const Color(0xFFFFB300), // Amber
            ),
            _StatCard(
              icon: Icons.today_rounded,
              value: '${stats['completedToday'] ?? 0}',
              label: l.doneToday,
              color: cs.tertiary,
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final iconColor = color ?? cs.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: cs.outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsShimmer extends StatelessWidget {
  const _StatsShimmer();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 180,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

// ─── Activity calendar (12-week heatmap) ──────────────────────────────────────

class _ActivityCalendar extends ConsumerWidget {
  const _ActivityCalendar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(activityHeatmapProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).activity,
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              S.of(context).activitySubtitle,
              style: tt.bodySmall?.copyWith(color: cs.outline),
            ),
            const SizedBox(height: AppSpacing.sm),
            async.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (map) => _HeatmapGrid(data: map),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(S.of(context).less, style: tt.labelSmall),
                const SizedBox(width: 4),
                for (final level in [0, 1, 2, 3])
                  Padding(
                    padding: const EdgeInsets.only(right: 2),
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _heatColor(level, cs),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                const SizedBox(width: 4),
                Text(S.of(context).more, style: tt.labelSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeatmapGrid extends StatelessWidget {
  final Map<String, int> data;
  const _HeatmapGrid({required this.data});

  static const _weeks = 12;
  static const _gap = 3.0;
  static const _dayLabelWidth = 14.0;
  // Only show labels on Mon (0), Wed (2), Fri (4) to avoid crowding.
  static const _dayLabels = {0: 'M', 2: 'W', 4: 'F'};
  static const _monthAbbr = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final now = DateTime.now();
    final todayWeekday = now.weekday; // 1=Mon
    // Monday of 12 weeks ago — always column 0, row 0.
    // Formula: go back (weeks-1) complete weeks, then back to Monday of that week.
    // This guarantees col (weeks-1), row (weekday-1) == today exactly.
    final startOfGrid =
        now.subtract(Duration(days: (_weeks - 1) * 7 + (todayWeekday - 1)));

    final labelStyle = tt.labelSmall?.copyWith(
      fontSize: 9,
      color: cs.onSurfaceVariant,
    );

    return LayoutBuilder(builder: (context, constraints) {
      // Fill the full available width; size cells to fit exactly.
      final gridWidth = constraints.maxWidth - _dayLabelWidth - _gap;
      final cellSize = (gridWidth - (_weeks - 1) * _gap) / _weeks;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Month labels ──────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(width: _dayLabelWidth + _gap),
              for (int col = 0; col < _weeks; col++) ...[
                SizedBox(
                  width: cellSize,
                  child: _monthLabel(startOfGrid, col, labelStyle),
                ),
                if (col < _weeks - 1) const SizedBox(width: _gap),
              ],
            ],
          ),
          const SizedBox(height: 2),
          // ── Day rows ──────────────────────────────────────────────────────
          for (int row = 0; row < 7; row++) ...[
            if (row > 0) const SizedBox(height: _gap),
            Row(
              children: [
                // Day label
                SizedBox(
                  width: _dayLabelWidth,
                  child: Text(
                    _dayLabels[row] ?? '',
                    style: labelStyle,
                    textAlign: TextAlign.left,
                  ),
                ),
                const SizedBox(width: _gap),
                // Cells
                for (int col = 0; col < _weeks; col++) ...[
                  _buildCell(startOfGrid, col, row, now, cellSize, cs),
                  if (col < _weeks - 1) const SizedBox(width: _gap),
                ],
              ],
            ),
          ],
        ],
      );
    });
  }

  Widget? _monthLabel(DateTime start, int col, TextStyle? style) {
    final weekStart = start.add(Duration(days: col * 7));
    // Show label if any day in this week is the 1st, or it's the first column.
    for (int d = 0; d < 7; d++) {
      final day = weekStart.add(Duration(days: d));
      if (day.day == 1 || (col == 0 && d == 0)) {
        return Text(
          _monthAbbr[day.month - 1],
          style: style,
          overflow: TextOverflow.visible,
        );
      }
    }
    return null;
  }

  Widget _buildCell(DateTime start, int col, int row, DateTime now,
      double cellSize, ColorScheme cs) {
    final date = start.add(Duration(days: col * 7 + row));
    if (date.isAfter(now)) {
      return SizedBox(width: cellSize, height: cellSize);
    }
    final dateStr = date.toIso8601String().substring(0, 10);
    final count = data[dateStr] ?? 0;
    final level = count == 0 ? 0 : count == 1 ? 1 : count <= 3 ? 2 : 3;
    return Container(
      width: cellSize,
      height: cellSize,
      decoration: BoxDecoration(
        color: _heatColor(level, cs),
        borderRadius: BorderRadius.circular(cellSize * 0.2),
      ),
    );
  }
}

Color _heatColor(int level, ColorScheme cs) {
  switch (level) {
    case 1:
      return cs.primary.withValues(alpha: 0.25);
    case 2:
      return cs.primary.withValues(alpha: 0.55);
    case 3:
      return cs.primary;
    default:
      return cs.surfaceContainerHighest;
  }
}

// ─── Logbook button ───────────────────────────────────────────────────────────

class _LogbookButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SyntraButton.icon(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LogbookPage()),
      ),
      icon: Icons.history,
      label: Text(S.of(context).challengeLogbook),
    );
  }
}

// ─── Weekly challenges chart (moved above XP) ─────────────────────────────────

class _WeeklyCountChart extends ConsumerWidget {
  const _WeeklyCountChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(weeklyCountsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).challengesThisWeek,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              S.of(context).chartExplanation,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.outline),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _LegendDot(color: const Color(0xFF4CAF50), label: S.of(context).legendCompleted),
                const SizedBox(width: AppSpacing.md),
                _LegendDot(color: const Color(0xFFFF6D00), label: S.of(context).legendTried),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 160,
              child: async.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
                data: (counts) =>
                    _CountBarChart(completed: counts[0], failed: counts[1]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _CountBarChart extends StatelessWidget {
  final List<int> completed;
  final List<int> failed;
  const _CountBarChart({required this.completed, required this.failed});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    final days = [l.mon, l.tue, l.wed, l.thu, l.fri, l.sat, l.sun];
    final allValues = [...completed, ...failed];
    final maxY = allValues.fold(0, (a, b) => a > b ? a : b).toDouble();

    return BarChart(
      BarChartData(
        maxY: maxY == 0 ? 10 : maxY * 1.2,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final idx = value.toInt();
                if (idx < 0 || idx >= days.length) return const SizedBox();
                return Text(days[idx],
                    style: Theme.of(context).textTheme.labelSmall);
              },
            ),
          ),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: [
          for (int i = 0; i < completed.length; i++)
            BarChartGroupData(
              x: i,
              groupVertically: false,
              barRods: [
                BarChartRodData(
                  toY: completed[i].toDouble(),
                  color: const Color(0xFF4CAF50), // Green
                  width: 8,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4)),
                ),
                BarChartRodData(
                  toY: failed[i].toDouble(),
                  color: const Color(0xFFFF6D00), // Orange
                  width: 8,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ─── Weekly XP chart ──────────────────────────────────────────────────────────

class _WeeklyXpChart extends ConsumerWidget {
  const _WeeklyXpChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(weeklyXpProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).xpEarnedThisWeek,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 160,
              child: async.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
                data: (xp) => _XpBarChart(xp: xp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _XpBarChart extends StatelessWidget {
  final List<int> xp;
  const _XpBarChart({required this.xp});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    final days = [l.mon, l.tue, l.wed, l.thu, l.fri, l.sat, l.sun];
    final cs = Theme.of(context).colorScheme;
    final maxY = xp.fold(0, (a, b) => a > b ? a : b).toDouble();

    return BarChart(
      BarChartData(
        maxY: maxY == 0 ? 100 : maxY * 1.2,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final idx = value.toInt();
                if (idx < 0 || idx >= days.length) return const SizedBox();
                return Text(days[idx],
                    style: Theme.of(context).textTheme.labelSmall);
              },
            ),
          ),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: [
          for (int i = 0; i < xp.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: xp[i].toDouble(),
                  color: cs.primary,
                  width: 16,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ─── Weekly goal card ─────────────────────────────────────────────────────────

class _WeeklyGoalCard extends ConsumerWidget {
  const _WeeklyGoalCard();

  static const _goals = [3, 5, 7];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = ref.watch(weeklyGoalProvider);
    final progressAsync = ref.watch(weeklyProgressProvider);
    final done = progressAsync.valueOrNull ?? 0;
    final progress = (done / goal).clamp(0.0, 1.0);
    final l = S.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flag_rounded, color: cs.primary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    l.weeklyGoalTitle,
                    style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l.weeklyGoalProgress(done, goal),
                  style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: cs.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  done >= goal ? const Color(0xFF43A047) : cs.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l.weeklyGoalSetLabel,
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: List.generate(_goals.length, (i) {
                final g = _goals[i];
                final selected = g == goal;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: i == 0 ? 0 : AppSpacing.xs / 2,
                        right: i == _goals.length - 1 ? 0 : AppSpacing.xs / 2),
                    child: GestureDetector(
                      onTap: () =>
                          ref.read(weeklyGoalProvider.notifier).setGoal(g),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? cs.primaryContainer
                              : cs.surfaceContainerHighest,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.chipRadius),
                          border: selected
                              ? Border.all(color: cs.primary, width: 1.5)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '$g',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: selected
                                  ? cs.onPrimaryContainer
                                  : cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Badges section ───────────────────────────────────────────────────────────

class _BadgesSection extends ConsumerWidget {
  const _BadgesSection();

  String _badgeLabel(S l, String id) => switch (id) {
        'first_step' => l.badgeFirstStep,
        'ten_challenges' => l.badgeTenChallenges,
        'fifty_challenges' => l.badgeFiftyChallenges,
        'three_day_streak' => l.badgeThreeDayStreak,
        'seven_day_streak' => l.badgeSevenDayStreak,
        'century_xp' => l.badgeCenturyXp,
        'five_hundred_xp' => l.badgeFiveHundredXp,
        'brave_minutes' => l.badgeBraveMinutes,
        _ => id,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(overviewStatsProvider);
    final l = S.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return statsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, s) => const SizedBox.shrink(),
      data: (stats) {
        final earned = BadgesLogic.computeEarned(stats, stats['streak'] ?? 0);
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.workspace_premium_rounded,
                        color: cs.primary, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      l.badgesTitle,
                      style: tt.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Text(
                      '${earned.length}/${BadgesLogic.all.length}',
                      style: tt.labelSmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: BadgesLogic.all.map((badge) {
                    final isEarned = earned.contains(badge.id);
                    return Tooltip(
                      message: _badgeLabel(l, badge.id),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isEarned
                              ? badge.color.withValues(alpha: 0.15)
                              : cs.surfaceContainerHighest,
                          shape: BoxShape.circle,
                          border: isEarned
                              ? Border.all(color: badge.color, width: 2)
                              : null,
                        ),
                        child: Icon(
                          badge.icon,
                          color: isEarned ? badge.color : cs.outlineVariant,
                          size: 26,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (earned.length < BadgesLogic.all.length) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l.badgesLocked,
                    style: tt.labelSmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Average mood card ────────────────────────────────────────────────────────

class _AverageMoodCard extends ConsumerWidget {
  const _AverageMoodCard();

  static const _smileyLabels = ['😞', '😕', '😐', '😊', '😄'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(averageMoodProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final l = S.of(context);

    // Shared card header — shown even when empty
    Widget header = Row(
      children: [
        Icon(Icons.mood_rounded, color: cs.primary, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            l.avgMoodTitle,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );

    return async.when(
      skipLoadingOnReload: true,
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (points) {
        if (points.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  header,
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l.avgMoodEmpty,
                    style: tt.bodyMedium
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          );
        }

        final spots = [
          for (var i = 0; i < points.length; i++)
            FlSpot(i.toDouble(), points[i].avg),
        ];

        // Show time (HH:mm) when all entries are same day, else month/day
        final allSameDay = points.every(
          (p) =>
              p.date.year == points.first.date.year &&
              p.date.month == points.first.date.month &&
              p.date.day == points.first.date.day,
        );
        String xLabel(DateTime d) => allSameDay
            ? '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}'
            : '${d.month}/${d.day}';

        // X-axis: show labels spaced out (max ~4 visible)
        final labelStep = (points.length / 4).ceil().clamp(1, 99);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header,
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 140,
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: 4,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 1,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: cs.outlineVariant.withValues(alpha: 0.4),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            interval: 1,
                            getTitlesWidget: (v, _) {
                              final i = v.round().clamp(0, 4);
                              return Text(
                                _smileyLabels[i],
                                style: const TextStyle(fontSize: 12),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                            interval: labelStep.toDouble(),
                            getTitlesWidget: (v, _) {
                              final idx = v.round();
                              if (idx < 0 || idx >= points.length) {
                                return const SizedBox.shrink();
                              }
                              final d = points[idx].date;
                              return Text(
                                xLabel(d),
                                style: tt.labelSmall?.copyWith(
                                    color: cs.onSurfaceVariant),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: cs.primary,
                          barWidth: 2.5,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (_, __, ___, ____) =>
                                FlDotCirclePainter(
                              radius: 3.5,
                              color: cs.primary,
                              strokeWidth: 0,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: cs.primary.withValues(alpha: 0.10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l.avgMoodSubtitle,
                  style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
