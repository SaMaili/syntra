import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_providers.dart';
import '../services/sound_service.dart';
import '../services/vibration_service.dart';

/// An animated, gamified progress bar with a 3-D cartoonish look.
///
/// Renders a chunky capsule with depth gradients, a looping shimmer sweep,
/// a tip glow, and subtle segment dividers. Audio/haptic feedback fires at
/// 25/50/75 % milestones; a completion chime plays when [value] reaches 1.0.
///
/// Set [silent] = true for timer / countdown bars where audio is unwanted.
class SyntraXpBar extends ConsumerStatefulWidget {
  final double value;
  final double initialValue;
  final double minHeight;
  final Color? color;
  final Color? backgroundColor;
  final Duration duration;
  final bool silent;

  const SyntraXpBar({
    super.key,
    required this.value,
    this.initialValue = 0.0,
    this.minHeight = 10,
    this.color,
    this.backgroundColor,
    this.duration = const Duration(milliseconds: 2300),
    this.silent = false,
  });

  @override
  ConsumerState<SyntraXpBar> createState() => _SyntraXpBarState();
}

class _SyntraXpBarState extends ConsumerState<SyntraXpBar>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late AnimationController _ctrl;
  late Animation<double> _anim;
  late AnimationController _shimmerCtrl;

  double _sweepFrom = 0.0;
  bool _feedbackActive = false;
  final Set<int> _milestonesFired = {};

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _ctrl.addListener(_onTick);
    _ctrl.addStatusListener(_onStatus);

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    final initialValue = widget.initialValue.clamp(0.0, 1.0);
    final targetValue = widget.value.clamp(0.0, 1.0);
    _sweepFrom = initialValue;
    _feedbackActive = !widget.silent && targetValue > initialValue;

    _anim = Tween<double>(begin: initialValue, end: targetValue)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    // Defer until after the first frame so ModalRoute is accessible.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final routeAnim = ModalRoute.of(context)?.animation;
      if (routeAnim != null && !routeAnim.isCompleted) {
        // Route push in flight (e.g. app cold-start) — wait for it to land.
        late final AnimationStatusListener listener;
        listener = (status) {
          if (status == AnimationStatus.completed) {
            routeAnim.removeStatusListener(listener);
            if (mounted) _startFill();
          }
        };
        routeAnim.addStatusListener(listener);
      } else {
        // No push animation (tab slide-in) — delay to match the 400 ms slide.
        Future.delayed(const Duration(milliseconds: 420), () {
          if (mounted) _startFill();
        });
      }
    });
  }

  void _startFill() {
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(SyntraXpBar old) {
    super.didUpdateWidget(old);
    final to = widget.value.clamp(0.0, 1.0);
    final from = _anim.value;
    if ((to - from).abs() < 0.001) return;

    _sweepFrom = from;
    _milestonesFired.clear();
    _feedbackActive = !widget.silent && to > from;

    _anim = Tween<double>(begin: from, end: to).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _ctrl
      ..duration = widget.duration
      ..reset()
      ..forward();
  }

  void _onTick() {
    if (!_feedbackActive) return;
    final v = _anim.value;
    for (final pct in [25, 50, 75]) {
      final t = pct / 100.0;
      if (!_milestonesFired.contains(pct) && v >= t && _sweepFrom < t) {
        _milestonesFired.add(pct);
        VibrationService.auraTick();
      }
    }
  }

  void _onStatus(AnimationStatus status) {
    if (!mounted || !_feedbackActive || status != AnimationStatus.completed) {
      return;
    }
    _feedbackActive = false;
    if (widget.value >= 1.0) {
      SoundService.playXpComplete(
          enabled: ref.read(soundEffectsEnabledProvider));
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final cs = Theme.of(context).colorScheme;
    final fillColor = widget.color ?? cs.primary;
    final trackColor = widget.backgroundColor ?? cs.surfaceContainerHighest;

    return AnimatedBuilder(
      animation: Listenable.merge([_anim, _shimmerCtrl]),
      builder: (context, _) => SizedBox(
        height: widget.minHeight,
        child: CustomPaint(
          painter: _CartoonBarPainter(
            value: _anim.value,
            fillColor: fillColor,
            trackColor: trackColor,
            shimmerProgress: _shimmerCtrl.value,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _CartoonBarPainter extends CustomPainter {
  final double value;
  final Color fillColor;
  final Color trackColor;
  final double shimmerProgress;

  const _CartoonBarPainter({
    required this.value,
    required this.fillColor,
    required this.trackColor,
    required this.shimmerProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final w = size.width;
    final r = h / 2;
    final outlineW = (h * 0.13).clamp(1.0, 2.5);

    final trackRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(r),
    );

    // ── Track ─────────────────────────────────────────────────────────────
    canvas.drawRRect(trackRRect, Paint()..color = trackColor);

    // ── Fill ──────────────────────────────────────────────────────────────
    if (value > 0.004) {
      final fillW = (w * value).clamp(0.0, w);
      final fillRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, fillW, h),
        Radius.circular(r),
      );

      canvas.drawRRect(fillRRect, Paint()..color = fillColor);

      // Shimmer sweep (clipped to fill shape)
      canvas.save();
      canvas.clipRRect(fillRRect);

      final shimW = (h * 3.5).clamp(14.0, 48.0);
      final shimX = fillW * (shimmerProgress * 1.2 - 0.1);
      canvas.drawRect(
        Rect.fromLTWH(shimX - shimW / 2, 0, shimW, h),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.white.withValues(alpha: 0.0),
              Colors.white.withValues(alpha: 0.30),
              Colors.white.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(Rect.fromLTWH(shimX - shimW / 2, 0, shimW, h)),
      );

      canvas.restore();
    }

    // ── Cartoon outline ───────────────────────────────────────────────────
    canvas.drawRRect(
      trackRRect,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.24)
        ..style = PaintingStyle.stroke
        ..strokeWidth = outlineW,
    );
  }

  @override
  bool shouldRepaint(_CartoonBarPainter old) =>
      old.value != value ||
      old.shimmerProgress != shimmerProgress ||
      old.fillColor != fillColor ||
      old.trackColor != trackColor;
}
