import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../generated/l10n.dart';
import '../../providers/statistics_providers.dart';
import '../../theme/app_spacing.dart';

class StatsOverviewGrid extends ConsumerWidget {
  const StatsOverviewGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(overviewStatsProvider);
    final bestStreakAsync = ref.watch(personalBestStreakProvider);

    return async.when(
      loading: () => const StatsShimmer(),
      error: (e, _) => Text('Error: $e'),
      data: (stats) {
        final l = S.of(context);
        final cs = Theme.of(context).colorScheme;
        final bestStreak = bestStreakAsync.valueOrNull ?? 0;
        final weekStreak = stats['weekStreak'] ?? 0;
        final pendingWeekStreak = stats['pendingWeekStreak'] ?? 0;
        final displayStreak = weekStreak > 0 ? weekStreak : pendingWeekStreak;
        final isStreakActive = weekStreak > 0;
        return Column(
          children: [
            // ── Stats grid ───────────────────────────────────────────────
            GridView.count(
              padding: EdgeInsets.zero,
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
      margin: EdgeInsets.zero,
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
  const StatsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 180,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
