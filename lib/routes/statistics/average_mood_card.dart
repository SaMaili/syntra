import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../generated/l10n.dart';
import '../../providers/statistics_providers.dart';
import '../../theme/app_spacing.dart';

class AverageMoodCard extends ConsumerWidget {
  const AverageMoodCard();

  static const _smileyLabels = ['😞', '😕', '😐', '😊', '😄'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(averageMoodProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);

    final header = Row(
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
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
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

        final allSameDay = points.every(
          (p) =>
              p.date.year == points.first.date.year &&
              p.date.month == points.first.date.month &&
              p.date.day == points.first.date.day,
        );
        String xLabel(DateTime d) => allSameDay
            ? '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}'
            : '${d.month}/${d.day}';

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
                              return Text(
                                xLabel(points[idx].date),
                                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: cs.primary,
                          barWidth: 2.5,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
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
