import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../generated/l10n.dart';
import '../../logic/weekly_streak_logic.dart';
import '../../providers/statistics_providers.dart';
import '../../theme/app_spacing.dart';

/// Weekly Aura bar chart: one bar per ISO week, threshold line at 300 Aura.
/// Grey  = below threshold · Orange = at/above threshold · Blue = streak freeze applied
class WeeklyAuraChart extends ConsumerWidget {
  const WeeklyAuraChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auraAsync = ref.watch(weeklyAuraByWeekProvider);
    final frozenAsync = ref.watch(frozenWeeksProvider);
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
              '$kWeeklyAuraThreshold Aura = active week',
              style: tt.bodySmall?.copyWith(color: cs.outline),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (auraAsync.isLoading || frozenAsync.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (auraAsync.hasError || frozenAsync.hasError)
              Text('Error: ${auraAsync.error ?? frozenAsync.error}')
            else
              _WeeklyBars(
                auraByWeek: auraAsync.value!,
                frozenWeeks: frozenAsync.value!,
              ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                _Dot(color: cs.surfaceContainerHighest),
                const SizedBox(width: 4),
                Text(
                  '<$kWeeklyAuraThreshold',
                  style: tt.labelSmall?.copyWith(color: cs.outline),
                ),
                const SizedBox(width: 12),
                _Dot(color: cs.tertiary),
                const SizedBox(width: 4),
                Text(
                  '≥$kWeeklyAuraThreshold',
                  style: tt.labelSmall?.copyWith(color: cs.outline),
                ),
                const SizedBox(width: 12),
                _Dot(color: Colors.blue.shade400),
                const SizedBox(width: 4),
                Text(
                  'Streak Freeze',
                  style: tt.labelSmall?.copyWith(color: cs.outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      );
}

// ─── Bar chart ────────────────────────────────────────────────────────────────

class _WeeklyBars extends StatelessWidget {
  final Map<String, int> auraByWeek;
  final Set<String> frozenWeeks;

  const _WeeklyBars({required this.auraByWeek, required this.frozenWeeks});

  static const int _weeks = 16;
  static const double _chartHeight = 120.0;
  static const double _labelHeight = 16.0;
  static const double _gap = 3.0;
  // Display cap: bars max out visually at 2× threshold (600 Aura).
  static const double _maxXp = kWeeklyAuraThreshold * 2.0;

  static const _monthAbbr = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final now = DateTime.now();
    final currentMonday = WeeklyStreakLogic.startOfIsoWeek(now);

    // Oldest week first.
    final weeks = List.generate(_weeks, (i) {
      final offset = (_weeks - 1 - i) * 7;
      return DateTime(
        currentMonday.year,
        currentMonday.month,
        currentMonday.day - offset,
      );
    });

    // Y-position of the threshold line from the bottom of the full widget.
    // labelHeight occupies the bottom; chart area above it.
    final thresholdFromBottom =
        _labelHeight + (kWeeklyAuraThreshold / _maxXp) * _chartHeight;

    return LayoutBuilder(builder: (context, constraints) {
      final barWidth =
          (constraints.maxWidth - _gap * (_weeks - 1)) / _weeks;

      return SizedBox(
        height: _chartHeight + _labelHeight,
        child: Stack(
          children: [
            // ── Bars (bottom-aligned inside chart area) ────────────────────
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: _labelHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (int i = 0; i < weeks.length; i++) ...[
                    if (i > 0) const SizedBox(width: _gap),
                    _Bar(
                      monday: weeks[i],
                      barWidth: barWidth,
                      chartHeight: _chartHeight,
                      auraByWeek: auraByWeek,
                      frozenWeeks: frozenWeeks,
                      cs: cs,
                    ),
                  ],
                ],
              ),
            ),

            // ── Threshold line ─────────────────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: thresholdFromBottom,
              height: 1,
              child: ColoredBox(
                color: cs.outline.withValues(alpha: 0.45),
              ),
            ),

            // ── Threshold label (just above the line, right edge) ──────────
            Positioned(
              right: 0,
              bottom: thresholdFromBottom + 2,
              child: Text(
                '$kWeeklyAuraThreshold',
                style: TextStyle(fontSize: 9, color: cs.outline),
              ),
            ),

            // ── Week / month labels ────────────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: _labelHeight,
              child: Row(
                children: [
                  for (int i = 0; i < weeks.length; i++) ...[
                    if (i > 0) const SizedBox(width: _gap),
                    SizedBox(
                      width: barWidth,
                      child: _monthLabel(weeks[i], i, tt, cs),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _monthLabel(
      DateTime monday, int index, TextTheme tt, ColorScheme cs) {
    // Show a label on the first bar and whenever a new month starts in this week.
    final isFirstBar = index == 0;
    final hasMonthStart = Iterable.generate(7)
        .map((d) => monday.add(Duration(days: d)))
        .any((d) => d.day == 1);
    if (!isFirstBar && !hasMonthStart) return const SizedBox.shrink();

    // Use the 1st of the month inside this week if there is one.
    DateTime labelDay = monday;
    for (int d = 0; d < 7; d++) {
      final day = monday.add(Duration(days: d));
      if (day.day == 1) {
        labelDay = day;
        break;
      }
    }

    return Text(
      _monthAbbr[labelDay.month - 1],
      style: tt.labelSmall?.copyWith(fontSize: 9, color: cs.outline),
      textAlign: TextAlign.center,
      overflow: TextOverflow.visible,
    );
  }
}

// ─── Single bar ───────────────────────────────────────────────────────────────

class _Bar extends StatelessWidget {
  final DateTime monday;
  final double barWidth;
  final double chartHeight;
  final Map<String, int> auraByWeek;
  final Set<String> frozenWeeks;
  final ColorScheme cs;

  const _Bar({
    required this.monday,
    required this.barWidth,
    required this.chartHeight,
    required this.auraByWeek,
    required this.frozenWeeks,
    required this.cs,
  });

  static const double _maxXp = kWeeklyAuraThreshold * 2.0;

  @override
  Widget build(BuildContext context) {
    final weekKey = WeeklyStreakLogic.isoYearWeek(monday);
    final isFrozen = frozenWeeks.contains(weekKey);

    // Frozen weeks are rendered at exactly the threshold height.
    final aura = isFrozen ? kWeeklyAuraThreshold : (auraByWeek[weekKey] ?? 0);
    final fraction = (aura / _maxXp).clamp(0.0, 1.0);
    final barHeight = fraction * chartHeight;

    final Color color;
    if (isFrozen) {
      color = Colors.blue.shade400;
    } else if (aura >= kWeeklyAuraThreshold) {
      color = cs.tertiary;
    } else {
      color = cs.surfaceContainerHighest;
    }

    // Always show at least a 2 dp stub so empty weeks are still visible.
    final displayHeight = barHeight < 2 ? 2.0 : barHeight;
    final displayColor =
        barHeight < 2 ? color.withValues(alpha: 0.35) : color;

    return SizedBox(
      width: barWidth,
      height: displayHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: displayColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
        ),
      ),
    );
  }
}
