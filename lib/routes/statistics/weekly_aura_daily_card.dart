import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../generated/l10n.dart';
import '../../logic/weekly_streak_logic.dart';
import '../../providers/statistics_providers.dart';
import '../../theme/brand_colors.dart';
import 'profile_section.dart';

/// "Aura this week" — 7 daily bars (Mon..Sun) in a pink gradient with glow,
/// plus a dashed goal line at `kWeeklyAuraThreshold / 7`. Day labels under
/// the bars (M T W T F S S). Title-right shows `total / goal`.
class WeeklyAuraDailyCard extends ConsumerWidget {
  const WeeklyAuraDailyCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(weeklyAuraProvider);
    final l = S.of(context);

    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (days) {
        // Pad / truncate to exactly 7. Provider returns oldest-first;
        // align so the last value is "today".
        final week = List<int>.filled(7, 0);
        final start = (7 - days.length).clamp(0, 7);
        for (int i = 0; i < days.length && start + i < 7; i++) {
          week[start + i] = days[i];
        }
        final total = week.fold<int>(0, (a, b) => a + b);

        return ProfileSection(
          title: l.profileAuraWeekTitle,
          right: l.auraWeekRight(total, kWeeklyAuraThreshold),
          child: _Bars(daily: week),
        );
      },
    );
  }
}

class _Bars extends StatelessWidget {
  final List<int> daily;
  const _Bars({required this.daily});

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  // Per-day target = weekly threshold divided across 7 days.
  static const double _dayGoal = kWeeklyAuraThreshold / 7;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final s = SyntraSurface.of(context);
    final goalLineColor =
        Theme.of(context).brightness == Brightness.dark ? s.bg4 : s.bg3;

    // Bars top out at the larger of "max in week" and 1.5× per-day goal.
    final maxValue = daily.fold<int>(0, (a, b) => b > a ? b : a);
    final ceiling = (maxValue * 1.0).clamp(_dayGoal * 1.5, double.infinity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 110,
          child: Stack(
            children: [
              // Dashed goal line — at the per-day goal fraction of the area.
              Positioned(
                left: 0,
                right: 0,
                bottom: (_dayGoal / ceiling) * 110,
                child: CustomPaint(
                  size: const Size(double.infinity, 1),
                  painter: _DashedHLinePainter(color: goalLineColor),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (int i = 0; i < 7; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(
                      child: _Bar(
                        value: daily[i],
                        ceiling: ceiling.toDouble(),
                        color: cs.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (int i = 0; i < 7; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _dayLabels[i],
                  textAlign: TextAlign.center,
                  style: tt.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  final int value;
  final double ceiling;
  final Color color;

  const _Bar({
    required this.value,
    required this.ceiling,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = ceiling == 0 ? 0.0 : (value / ceiling).clamp(0.0, 1.0);
    final hasValue = value > 0;
    return FractionallySizedBox(
      heightFactor: hasValue ? fraction : 0.04,
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: BoxDecoration(
          gradient: hasValue
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withValues(alpha: 0.85),
                    color,
                  ],
                )
              : null,
          color: hasValue ? null : color.withValues(alpha: 0.15),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
            bottomLeft: Radius.circular(2),
            bottomRight: Radius.circular(2),
          ),
          boxShadow: hasValue
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}

class _DashedHLinePainter extends CustomPainter {
  final Color color;
  _DashedHLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dash = 3.0;
    const gap = 3.0;
    final step = dash + gap;
    final count = (size.width / step).floor();
    for (int i = 0; i < count; i++) {
      final x = i * step;
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), paint);
    }
  }

  @override
  bool shouldRepaint(_DashedHLinePainter old) => old.color != color;
}
