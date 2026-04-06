import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../generated/l10n.dart';
import '../../providers/statistics_providers.dart';
import '../../theme/app_spacing.dart';

// ─── Weekly challenge count chart ─────────────────────────────────────────────

class WeeklyCountChart extends ConsumerWidget {
  const WeeklyCountChart();

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
                LegendDot(color: const Color(0xFF4CAF50), label: S.of(context).legendCompleted),
                const SizedBox(width: AppSpacing.md),
                LegendDot(color: const Color(0xFFFF6D00), label: S.of(context).legendTried),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 160,
              child: async.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
                data: (counts) => CountBarChart(completed: counts[0], tried: counts[1]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const LegendDot({super.key, required this.color, required this.label});

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

class CountBarChart extends StatelessWidget {
  final List<int> completed;
  final List<int> tried;
  const CountBarChart({super.key, required this.completed, required this.tried});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    final days = [l.mon, l.tue, l.wed, l.thu, l.fri, l.sat, l.sun];
    final allValues = [...completed, ...tried];
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
                return Text(days[idx], style: Theme.of(context).textTheme.labelSmall);
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: [
          for (int i = 0; i < completed.length; i++)
            BarChartGroupData(
              x: i,
              groupVertically: false,
              barRods: [
                BarChartRodData(
                  toY: completed[i].toDouble(),
                  color: const Color(0xFF4CAF50),
                  width: 8,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
                BarChartRodData(
                  toY: tried[i].toDouble(),
                  color: const Color(0xFFFF6D00),
                  width: 8,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ─── Weekly Aura chart ────────────────────────────────────────────────────────

class WeeklyXpChart extends ConsumerWidget {
  const WeeklyXpChart();

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
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
                data: (xp) => XpBarChart(xp: xp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class XpBarChart extends StatelessWidget {
  final List<int> xp;
  const XpBarChart({super.key, required this.xp});

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
                return Text(days[idx], style: Theme.of(context).textTheme.labelSmall);
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
