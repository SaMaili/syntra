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
    with SingleTickerProviderStateMixin {
  static const _moveCurve = Cubic(0.32, 0.72, 0.24, 1);

  late final AnimationController _move = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );
  late Animation<double> _shown =
      AlwaysStoppedAnimation(widget.page.toDouble());

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final track = SyntraSurface.of(context).bg3;
    return SizedBox(
      height: 12,
      child: AnimatedBuilder(
        animation: _move,
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _OnbBarPainter(
            shown: _shown.value,
            page: widget.page,
            total: widget.total,
            fill: _move.isAnimating ? _move.value : 1.0,
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
  final Color pink;
  final Color track;
  static const _gap = 6.0;
  static const _h = 4.0;

  _OnbBarPainter({
    required this.shown,
    required this.page,
    required this.total,
    required this.fill,
    required this.pink,
    required this.track,
  });

  @override
  void paint(Canvas canvas, Size size) {
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
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, cy - _h / 2, w * f, _h),
            const Radius.circular(999),
          ),
          fillPaint,
        );
      }
      x += w + _gap;
    }
  }

  @override
  bool shouldRepaint(_OnbBarPainter old) =>
      old.shown != shown ||
      old.page != page ||
      old.fill != fill ||
      old.total != total ||
      old.pink != pink ||
      old.track != track;
}

// ─── Page atoms ───────────────────────────────────────────────────────────────

/// Three-layer hero icon — static, no animation.
///
/// Outer ambient circle (148px), mid ring (104px), core rounded square (68px).
class OnbHeroIcon extends StatelessWidget {
  final IconData icon;
  final Color? tint;
  const OnbHeroIcon({super.key, required this.icon, this.tint});

  @override
  Widget build(BuildContext context) {
    final t = tint ?? Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final coreBg = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF5F2F0);

    return SizedBox(
      width: 148,
      height: 148,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ambient halo
          Container(
            width: 148,
            height: 148,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: t.withValues(alpha: 0.07),
            ),
          ),
          // Mid ring
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: t.withValues(alpha: 0.10),
              border: Border.all(color: t.withValues(alpha: 0.18), width: 1),
            ),
          ),
          // Core icon square
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: coreBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: t.withValues(alpha: 0.28), width: 1.5),
            ),
            child: Icon(icon, size: 32, color: t),
          ),
        ],
      ),
    );
  }
}

/// Backwards-compat alias — callers that still use OnbDisc get OnbHeroIcon.
typedef OnbDisc = OnbHeroIcon;

/// Centered display headline — Octarine 34 / -0.8 tracking.
class OnbHeadline extends StatelessWidget {
  final String text;
  const OnbHeadline(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 12),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Octarine',
          fontWeight: FontWeight.w700,
          fontSize: 34,
          height: 1.12,
          letterSpacing: -0.8,
          color: isDark ? Colors.white : cs.onSurface,
        ),
      ),
    );
  }
}

/// Centered supporting copy — Inter 15 / 1.55.
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

/// Page shell with staggered entrance animation.
///
/// Each child fades + slides up (8px) with a 110ms stagger between items.
/// Re-animates whenever the widget is rebuilt with a new key (page change).
class OnbScaffold extends StatefulWidget {
  final List<Widget> children;
  final Widget? footer;
  const OnbScaffold({super.key, required this.children, this.footer});

  @override
  State<OnbScaffold> createState() => _OnbScaffoldState();
}

class _OnbScaffoldState extends State<OnbScaffold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 560),
  )..forward();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        Widget stagger(Widget child, int index) {
          final start = (index * 0.11).clamp(0.0, 0.7);
          final end = (start + 0.46).clamp(0.0, 1.0);
          final curve = CurvedAnimation(
            parent: _ctrl,
            curve: Interval(start, end, curve: Curves.easeOut),
          );
          return FadeTransition(
            opacity: curve,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.055),
                end: Offset.zero,
              ).animate(curve),
              child: child,
            ),
          );
        }

        final footerStart = (widget.children.length * 0.11).clamp(0.0, 0.55);
        final footerCurve = CurvedAnimation(
          parent: _ctrl,
          curve: Interval(footerStart, 1.0, curve: Curves.easeOut),
        );

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
                        children: [
                          for (var i = 0; i < widget.children.length; i++)
                            stagger(widget.children[i], i),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (widget.footer != null)
              FadeTransition(
                opacity: footerCurve,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.04),
                    end: Offset.zero,
                  ).animate(footerCurve),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 4, 22, 12),
                    child: widget.footer!,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
