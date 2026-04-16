import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../generated/l10n.dart';
import '../../providers/statistics_providers.dart';
import '../../theme/app_spacing.dart';

class ActivityCalendar extends ConsumerWidget {
  const ActivityCalendar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(activityHeatmapProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
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
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (map) => HeatmapGrid(data: map),
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
                        color: heatColor(level, cs),
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

class HeatmapGrid extends StatelessWidget {
  final Map<String, int> data;
  const HeatmapGrid({super.key, required this.data});

  static const _weeks = 12;
  static const _gap = 3.0;
  static const _dayLabelWidth = 14.0;
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
    final todayWeekday = now.weekday;
    final startOfGrid =
        now.subtract(Duration(days: (_weeks - 1) * 7 + (todayWeekday - 1)));

    final labelStyle = tt.labelSmall?.copyWith(
      fontSize: 9,
      color: cs.onSurfaceVariant,
    );

    return LayoutBuilder(builder: (context, constraints) {
      final gridWidth = constraints.maxWidth - _dayLabelWidth - _gap;
      final cellSize = (gridWidth - (_weeks - 1) * _gap) / _weeks;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          for (int row = 0; row < 7; row++) ...[
            if (row > 0) const SizedBox(height: _gap),
            Row(
              children: [
                SizedBox(
                  width: _dayLabelWidth,
                  child: Text(
                    _dayLabels[row] ?? '',
                    style: labelStyle,
                    textAlign: TextAlign.left,
                  ),
                ),
                const SizedBox(width: _gap),
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
    for (int d = 0; d < 7; d++) {
      final day = weekStart.add(Duration(days: d));
      if (day.day == 1 || (col == 0 && d == 0)) {
        return Text(_monthAbbr[day.month - 1], style: style, overflow: TextOverflow.visible);
      }
    }
    return null;
  }

  Widget _buildCell(DateTime start, int col, int row, DateTime now,
      double cellSize, ColorScheme cs) {
    final date = start.add(Duration(days: col * 7 + row));
    if (date.isAfter(now)) return SizedBox(width: cellSize, height: cellSize);
    final dateStr = date.toIso8601String().substring(0, 10);
    final count = data[dateStr] ?? 0;
    final level = count == 0 ? 0 : count == 1 ? 1 : count <= 3 ? 2 : 3;
    return Container(
      width: cellSize,
      height: cellSize,
      decoration: BoxDecoration(
        color: heatColor(level, cs),
        borderRadius: BorderRadius.circular(cellSize * 0.2),
      ),
    );
  }
}

Color heatColor(int level, ColorScheme cs) {
  switch (level) {
    case 1: return cs.primary.withValues(alpha: 0.25);
    case 2: return cs.primary.withValues(alpha: 0.55);
    case 3: return cs.primary;
    default: return cs.surfaceContainerHighest;
  }
}
