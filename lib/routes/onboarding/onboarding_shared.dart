import 'package:flutter/material.dart';

import '../../theme/brand_colors.dart';

// ─── Onboarding progress ─────────────────────────────────────────────────────

/// Design-accurate onboarding progress. A row of [total] flex segments on a
/// dark track: past segments are solid pink, the active one grows ~3× wider
/// over 650ms (`cubic-bezier(.32,.72,.24,1)`) while a pink fill sweeps across
/// it with a soft pulsing glow. 1:1 with the design prototype's pill bar.
class OnbProgress extends StatefulWidget {
  final int page;
  final int total;
  const OnbProgress({super.key, required this.page, required this.total});

  @override
  State<OnbProgress> createState() => _OnbProgressState();
}

class _OnbProgressState extends State<OnbProgress>
    with TickerProviderStateMixin {
  static const _moveCurve = Cubic(0.32, 0.72, 0.24, 1);

  late final AnimationController _move = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );
  late Animation<double> _shown =
      AlwaysStoppedAnimation(widget.page.toDouble());

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    // Sweep the first active segment's fill in on mount.
    _move.forward(from: 0);
  }

  @override
  void didUpdateWidget(covariant OnbProgress old) {
    super.didUpdateWidget(old);
    if (old.page != widget.page) {
      _shown = Tween<double>(begin: _shown.value, end: widget.page.toDouble())
          .animate(CurvedAnimation(parent: _move, curve: _moveCurve));
      _move.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _move.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final track = SyntraSurface.of(context).bg3;
    return SizedBox(
      height: 12,
      child: AnimatedBuilder(
        animation: Listenable.merge([_move, _pulse]),
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _OnbBarPainter(
            shown: _shown.value,
            page: widget.page,
            total: widget.total,
            fill: _move.isAnimating ? _move.value : 1.0,
            pulse: _pulse.value,
            pink: BrandColors.pink,
            track: track,
          ),
        ),
      ),
    );
  }
}

class _OnbBarPainter extends CustomPainter {
  final double shown;
  final int page;
  final int total;
  final double fill;
  final double pulse;
  final Color pink;
  final Color track;
  static const _gap = 6.0;
  static const _h = 4.0;

  _OnbBarPainter({
    required this.shown,
    required this.page,
    required this.total,
    required this.fill,
    required this.pulse,
    required this.pink,
    required this.track,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Active segment grows to ~3× the others; neighbours interpolate during
    // the move so the width handoff is smooth.
    final weights = List<double>.generate(total, (i) {
      final t = (1 - (i - shown).abs()).clamp(0.0, 1.0);
      return 1 + 2 * t;
    });
    final sum = weights.fold<double>(0, (a, b) => a + b);
    final avail = size.width - _gap * (total - 1);
    final cy = size.height / 2;
    final trackPaint = Paint()..color = track;
    final fillPaint = Paint()..color = pink;

    var x = 0.0;
    for (var i = 0; i < total; i++) {
      final w = avail * weights[i] / sum;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, cy - _h / 2, w, _h),
          const Radius.circular(999),
        ),
        trackPaint,
      );

      final f = i < page
          ? 1.0
          : i == page
              ? fill
              : 0.0;
      if (f > 0) {
        final fr = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, cy - _h / 2, w * f, _h),
          const Radius.circular(999),
        );
        if (i == page) {
          canvas.drawRRect(
            fr,
            Paint()
              ..color = pink.withValues(alpha: 0.5 + 0.45 * pulse)
              ..maskFilter =
                  MaskFilter.blur(BlurStyle.normal, 4 + 5 * pulse),
          );
        }
        canvas.drawRRect(fr, fillPaint);
      }
      x += w + _gap;
    }
  }

  @override
  bool shouldRepaint(_OnbBarPainter old) =>
      old.shown != shown ||
      old.page != page ||
      old.fill != fill ||
      old.pulse != pulse ||
      old.total != total ||
      old.pink != pink ||
      old.track != track;
}

// ─── Page atoms (design: OnbDisc / OnbHeadline / OnbSubtext / shell) ─────────

/// Big icon disc — 110px, radial tint glow + thin ring. Design `OnbDisc`.
class OnbDisc extends StatelessWidget {
  final IconData icon;
  final Color? tint;
  const OnbDisc({super.key, required this.icon, this.tint});

  @override
  Widget build(BuildContext context) {
    final t = tint ?? Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final core =
        isDark ? const Color(0xFF0A0A0A) : Theme.of(context).scaffoldBackgroundColor;
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.4, -0.4),
          radius: 0.95,
          colors: [
            t.withValues(alpha: 0.20),
            t.withValues(alpha: 0.067),
            core,
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        border: Border.all(color: t.withValues(alpha: 0.33)),
        boxShadow: [
          BoxShadow(color: t.withValues(alpha: 0.20), blurRadius: 40),
        ],
      ),
      child: Icon(icon, size: 52, color: t),
    );
  }
}

/// Centered display headline — Octarine 30 / -0.6 tracking. Design `OnbHeadline`.
class OnbHeadline extends StatelessWidget {
  final String text;
  const OnbHeadline(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 12),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Octarine',
          fontWeight: FontWeight.w700,
          fontSize: 30,
          height: 1.15,
          letterSpacing: -0.6,
          color: isDark ? Colors.white : cs.onSurface,
        ),
      ),
    );
  }
}

/// Centered supporting copy — Inter 15 / 1.55. Design `OnbSubtext`.
class OnbSubtext extends StatelessWidget {
  final String text;
  const OnbSubtext(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          height: 1.55,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Page shell: vertically-centred, scroll-on-overflow content with a pinned
/// footer. Matches the design's per-page flex column + bottom button area.
class OnbScaffold extends StatelessWidget {
  final List<Widget> children;
  final Widget? footer;
  const OnbScaffold({super.key, required this.children, this.footer});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, c) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: c.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: children,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (footer != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 4, 22, 12),
            child: footer!,
          ),
      ],
    );
  }
}
