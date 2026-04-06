import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../generated/l10n.dart';
import '../../logic/weekly_streak_logic.dart';
import '../../providers/statistics_providers.dart';
import '../../theme/app_spacing.dart';

class StatsOverviewGrid extends ConsumerWidget {
  const StatsOverviewGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(overviewStatsProvider);
    final bestStreakAsync = ref.watch(personalBestStreakProvider);
    final currentWeekXpAsync = ref.watch(currentWeekXpProvider);

    return async.when(
      loading: () => const StatsShimmer(),
      error: (e, _) => Text('Error: $e'),
      data: (stats) {
        final l = S.of(context);
        final cs = Theme.of(context).colorScheme;
        final bestStreak = bestStreakAsync.valueOrNull ?? 0;
        final currentWeekXp = currentWeekXpAsync.valueOrNull ?? 0;
        final weekProgress =
            (currentWeekXp / kWeeklyXpThreshold).clamp(0.0, 1.0);
        final weekStreak = stats['weekStreak'] ?? 0;
        final pendingWeekStreak = stats['pendingWeekStreak'] ?? 0;
        final displayStreak = weekStreak > 0 ? weekStreak : pendingWeekStreak;
        final isStreakActive = weekStreak > 0;
        return Column(
          children: [
            // ── Weekly Aura progress card ────────────────────────────────
            _WeeklyAuraCard(
              currentXp: currentWeekXp,
              progress: weekProgress,
            ),
            const SizedBox(height: AppSpacing.sm),
            // ── Stats grid ───────────────────────────────────────────────
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 1.3,
              children: [
                StatCard(
                  icon: Icons.emoji_events,
                  value: '${stats['totalXp']}',
                  label: l.totalXp,
                  color: cs.primary,
                ),
                StatCard(
                  icon: Icons.local_fire_department,
                  value: '$displayStreak',
                  label: l.weekStreak,
                  color: isStreakActive
                      ? const Color(0xFFFF6D00)
                      : null, // null → grey (pending or reset)
                ),
                StatCard(
                  icon: Icons.directions_run_rounded,
                  value: '${stats['completedAllTime']}',
                  label: l.timesTried,
                  color: cs.secondary,
                ),
                StatCard(
                  icon: Icons.timer_outlined,
                  value: '${stats['minutesBrave'] ?? 0}',
                  label: l.minutesBrave,
                  color: Colors.blueAccent,
                ),
                StatCard(
                  icon: Icons.military_tech_rounded,
                  value: '$bestStreak',
                  label: l.bestStreak,
                  color: const Color(0xFFFFB300),
                ),
                StatCard(
                  icon: Icons.today_rounded,
                  value: '${stats['completedToday'] ?? 0}',
                  label: l.doneToday,
                  color: cs.tertiary,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _WeeklyAuraCard extends StatelessWidget {
  final int currentXp;
  final double progress; // 0.0–1.0

  const _WeeklyAuraCard({required this.currentXp, required this.progress});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);
    final isComplete = progress >= 1.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isComplete
                      ? Icons.check_circle_rounded
                      : Icons.local_fire_department_outlined,
                  size: 18,
                  color: isComplete ? Colors.green : cs.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  l.weeklyAuraGoalTitle,
                  style: tt.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '$currentXp / $kWeeklyXpThreshold ${l.auraPoints}',
                  style: tt.labelSmall
                      ?.copyWith(color: cs.onSurfaceVariant),
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
                  isComplete ? Colors.green : cs.primary,
                ),
              ),
            ),
            if (isComplete) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                l.weeklyAuraGoalReached,
                style: tt.labelSmall
                    ?.copyWith(color: Colors.green),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? color;

  const StatCard({
    super.key,
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

class StatsShimmer extends StatelessWidget {
  const StatsShimmer();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 180,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
