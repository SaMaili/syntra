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
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

// ─── Growth story ─────────────────────────────────────────────────────────────

class _GrowthStory extends ConsumerWidget {
  const _GrowthStory();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(overviewStatsProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (stats) {
        final l = S.of(context);
        final total = stats['completedAllTime'] ?? 0;
        final streak = stats['streak'] ?? 0;
        final totalXp = stats['totalXp'] ?? 0;

        // Narrative sentences
        final sentences = <String>[];
        if (total == 0) {
          sentences.add(l.storyFirstChallenge);
        } else if (total == 1) {
          sentences.add(l.storyOnce);
        } else {
          sentences.add(l.storyNTimes(total));
        }
        if (streak >= 2) {
          sentences.add(l.storyStreakMany(streak));
        } else if (streak == 1) {
          sentences.add(l.storyStreakOne);
        }
        if (totalXp >= 1000) {
          sentences.add(l.storyXpKilo((totalXp / 1000).toStringAsFixed(1)));
        } else if (totalXp > 0) {
          sentences.add(l.storyXpSmall(totalXp));
        }
        final mins = stats['minutesBrave'] ?? 0;
        if (mins >= 5) {
          sentences.add(l.storyMinutesBrave(mins));
        }

        return Card(
          color: cs.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_stories_rounded,
                        color: cs.onPrimaryContainer, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Text(l.yourProgress,
                        style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.onPrimaryContainer)),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ...sentences.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        s,
                        style: tt.bodyMedium?.copyWith(
                            color: cs.onPrimaryContainer, height: 1.5),
                      ),
                    )),
              ],
            ),
          ),
        );
      },
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final todayWeekday = now.weekday; // 1=Mon
    // Start from Monday of 12 weeks ago
    final startOfGrid =
        now.subtract(Duration(days: (12 * 7) - 1 + (todayWeekday - 1)));

    // Total days in the grid
    final totalDays = now.difference(startOfGrid).inDays + 1;
    // Number of columns (weeks)
    final cols = (totalDays / 7).ceil();

    const cellSize = 11.0;
    const gap = 2.0;

    return SizedBox(
      height: 7 * (cellSize + gap),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true, // most recent on the right
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int col = 0; col < cols; col++)
              Padding(
                padding: const EdgeInsets.only(right: gap),
                child: Column(
                  children: [
                    for (int row = 0; row < 7; row++)
                      _buildCell(startOfGrid, col, row, now, cellSize, gap, cs),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCell(DateTime start, int col, int row, DateTime now,
      double cellSize, double gap, ColorScheme cs) {
    final dayOffset = col * 7 + row;
    final date = start.add(Duration(days: dayOffset));
    // Don't render cells beyond today
    if (date.isAfter(now)) {
      return SizedBox(height: cellSize + gap);
    }
    final dateStr = date.toIso8601String().substring(0, 10);
    final count = data[dateStr] ?? 0;
    final level = count == 0
        ? 0
        : count == 1
            ? 1
            : count <= 3
                ? 2
                : 3;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Container(
        width: cellSize,
        height: cellSize,
        decoration: BoxDecoration(
          color: _heatColor(level, cs),
          borderRadius: BorderRadius.circular(2),
        ),
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
                Text(
                  l.weeklyGoalTitle,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
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
            Row(
              children: [
                Text(
                  l.weeklyGoalSetLabel,
                  style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(width: AppSpacing.sm),
                ..._goals.map((g) => Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.xs),
                      child: ChoiceChip(
                        label: Text('$g'),
                        selected: g == goal,
                        selectedColor: cs.primaryContainer,
                        backgroundColor: cs.surfaceContainerHighest,
                        showCheckmark: false,
                        visualDensity: VisualDensity.compact,
                        onSelected: (_) =>
                            ref.read(weeklyGoalProvider.notifier).setGoal(g),
                      ),
                    )),
              ],
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
