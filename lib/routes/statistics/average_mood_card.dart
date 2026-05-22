import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../generated/l10n.dart';
import '../../providers/statistics_providers.dart';
import '../../theme/brand_colors.dart';
import 'profile_section.dart';

/// "Mood trend · last N" — soft pink area chart.
///
/// 1:1 with the design's `MoodArea`: 2 px pink stroke, pink-alpha gradient
/// fill (0.35 → 0), dashed baseline at neutral (mid of the 0–4 scale),
/// "N ago"/"Today" tick labels under the chart.
class AverageMoodCard extends ConsumerWidget {
  const AverageMoodCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(averageMoodProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);

    return async.when(
      skipLoadingOnReload: true,
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (points) {
        if (points.isEmpty) {
          return ProfileSection(
            title: l.profileMoodTitle,
            child: Text(
              l.avgMoodEmpty,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          );
        }

        final values = points.map((p) => p.avg).toList();
        return ProfileSection(
          title: '${l.profileMoodTitle} · ${l.lastNCount(values.length)}',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 80,
                child: CustomPaint(
                  painter: MoodAreaPainter(
                    values: values,
                    line: cs.primary,
                    baseline: Theme.of(context).brightness == Brightness.dark
                        ? SyntraSurface.dark.bg4
                        : SyntraSurface.light.bg3,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l.moodAgoLabel(values.length),
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    l.moodTodayLabel,
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class MoodAreaPainter extends CustomPainter {
  final List<double> values;
  final Color line;
  final Color baseline;

  MoodAreaPainter({
    required this.values,
    required this.line,
    required this.baseline,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    const padding = 4.0;
    final w = size.width;
    final h = size.height;
    final n = values.length;
    final stepX = n > 1 ? (w - padding * 2) / (n - 1) : 0.0;

    // Mood values are on a 0..4 scale; invert so 4 (happy) maps to top.
    double yFor(double v) =>
        padding + (1 - (v.clamp(0, 4)) / 4) * (h - padding * 2);

    // Build the data path.
    final dataPath = Path();
    for (int i = 0; i < n; i++) {
      final x = padding + i * stepX;
      final y = yFor(values[i]);
      if (i == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }
    }

    // Closed area path for the gradient fill.
    final areaPath = Path.from(dataPath)
      ..lineTo(padding + (n - 1) * stepX, h)
      ..lineTo(padding, h)
      ..close();

    // Dashed baseline at neutral (y of value = 2).
    final baselineY = yFor(2);
    final baselinePaint = Paint()
      ..color = baseline
      ..strokeWidth = 1;
    _drawDashedLine(
      canvas,
      Offset(padding, baselineY),
      Offset(w - padding, baselineY),
      baselinePaint,
      dashWidth: 3,
      dashGap: 3,
    );

    // Area gradient fill.
    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [line.withValues(alpha: 0.35), line.withValues(alpha: 0)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(areaPath, areaPaint);

    // Line stroke.
    final linePaint = Paint()
      ..color = line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(dataPath, linePaint);
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset a,
    Offset b,
    Paint paint, {
    required double dashWidth,
    required double dashGap,
  }) {
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    final dist = (dx * dx + dy * dy).abs() == 0 ? 0.0 : (dx).abs();
    if (dist == 0) return;
    final step = dashWidth + dashGap;
    final count = (dist / step).floor();
    final ux = dx / dist;
    final uy = dy / dist;
    for (int i = 0; i < count; i++) {
      final start = Offset(a.dx + ux * step * i, a.dy + uy * step * i);
      final end = Offset(start.dx + ux * dashWidth, start.dy + uy * dashWidth);
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(MoodAreaPainter old) =>
      old.values != values || old.line != line || old.baseline != baseline;
}
