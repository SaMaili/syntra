import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../generated/l10n.dart';
import '../../providers/statistics_providers.dart';
import '../../theme/app_spacing.dart';
import '../../theme/brand_colors.dart';

/// Dense 3×2 stats strip — demoted from the old 2×3 hero-sized cards.
///
/// Each cell shows: small icon, big value, tiny uppercase label. Microcopy
/// lift to match the design tone: "Min. Brave" → "Brave min", "Times Tried"
/// → "Faced", "Week Streak" → "Streak".
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

        final cells = <_StatCellData>[
          _StatCellData(
            icon: Icons.star_rounded,
            iconColor: cs.primary,
            value: _fmt(stats['totalAura'] ?? 0),
            label: l.totalAura,
          ),
          _StatCellData(
            icon: Icons.local_fire_department_rounded,
            iconColor: isStreakActive
                ? BrandColors.orange
                : cs.onSurfaceVariant,
            value: '${displayStreak}w',
            label: l.weekStreak,
          ),
          _StatCellData(
            icon: Icons.check_circle_rounded,
            iconColor: BrandColors.green,
            value: '${stats['completedToday'] ?? 0}',
            label: l.doneToday,
          ),
          _StatCellData(
            icon: Icons.directions_run_rounded,
            iconColor: BrandColors.red,
            value: _fmt(stats['completedAllTime'] ?? 0),
            label: l.timesTried,
          ),
          _StatCellData(
            icon: Icons.schedule_rounded,
            iconColor: BrandColors.blue,
            value: _fmt(stats['minutesBrave'] ?? 0),
            label: l.minutesBrave,
          ),
          _StatCellData(
            icon: Icons.military_tech_rounded,
            iconColor: BrandColors.amber,
            value: '${bestStreak}w',
            label: l.bestStreak,
          ),
        ];

        return GridView.count(
          padding: EdgeInsets.zero,
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.xs,
          crossAxisSpacing: AppSpacing.xs,
          childAspectRatio: 1.05,
          children: cells.map((c) => _StatCell(data: c)).toList(),
        );
      },
    );
  }

  String _fmt(int n) {
    if (n < 1000) return '$n';
    if (n < 1000000) {
      final v = n / 1000;
      return v.toStringAsFixed(v >= 10 ? 0 : 1).replaceAll('.0', '') + 'k';
    }
    return '${(n / 1000000).toStringAsFixed(1)}M';
  }
}

class _StatCellData {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  const _StatCellData({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });
}

class _StatCell extends StatelessWidget {
  final _StatCellData data;
  const _StatCell({required this.data});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = SyntraSurface.of(context);
    final valueColor = isDark ? Colors.white : cs.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: s.bg1,
        border: Border.all(color: s.bg3, width: 1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(data.icon, size: 24, color: data.iconColor),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  data.value,
                  style: tt.titleLarge?.copyWith(
                    fontFamily: 'Octarine',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    height: 1.1,
                    color: valueColor,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                data.label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tt.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatsShimmer extends StatelessWidget {
  const StatsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 130,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

// Kept for backwards compatibility — any caller that still imports `StatCard`
// gets a thin wrapper around the new dense cell.
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
    return _StatCell(
      data: _StatCellData(
        icon: icon,
        iconColor: color ?? cs.primary,
        value: value,
        label: label,
      ),
    );
  }
}
