import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../generated/l10n.dart';
import '../services/vibration_service.dart';
import '../theme/app_spacing.dart';
import '../widgets/syntra_button.dart';

class StreakCelebrationScreen extends ConsumerStatefulWidget {
  final int streak;
  final bool isMilestone;

  const StreakCelebrationScreen({
    super.key,
    required this.streak,
    this.isMilestone = false,
  });

  @override
  ConsumerState<StreakCelebrationScreen> createState() =>
      _StreakCelebrationScreenState();
}

class _StreakCelebrationScreenState
    extends ConsumerState<StreakCelebrationScreen>
    with TickerProviderStateMixin {
  int _phase = 0; // 0: streak, 1: milestone

  late AnimationController _enterCtrl;
  late AnimationController _burstCtrl;
  late AnimationController _wobbleCtrl;
  late AnimationController _emberCtrl;
  late AnimationController _textCtrl;

  late Animation<double> _enterScale;
  late Animation<double> _wobble;
  late Animation<double> _glow;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _enterScale = CurvedAnimation(parent: _enterCtrl, curve: Curves.elasticOut);

    _burstCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _wobbleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _wobble = Tween<double>(begin: -0.04, end: 0.04).animate(
      CurvedAnimation(parent: _wobbleCtrl, curve: Curves.easeInOut),
    );
    _glow = Tween<double>(begin: 0.25, end: 0.9).animate(
      CurvedAnimation(parent: _wobbleCtrl, curve: Curves.easeInOut),
    );

    _emberCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _textOpacity = CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn);
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));

    _enterCtrl.forward();
    _burstCtrl.forward();
    _wobbleCtrl.repeat(reverse: true);
    _emberCtrl.repeat();

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _textCtrl.forward();
    });
  }

  void _onNext() {
    if (_phase == 0 && widget.isMilestone) {
      setState(() => _phase = 1);
      _enterCtrl.forward(from: 0.0);
      _burstCtrl.forward(from: 0.0);
      _textCtrl.reset();
      _textCtrl.forward();
      VibrationService.milestone();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _burstCtrl.dispose();
    _wobbleCtrl.dispose();
    _emberCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);

    final iconColor = _phase == 0 ? cs.tertiary : Colors.amber;
    final bgColor =
        _phase == 0 ? const Color(0xFF121212) : const Color(0xFF1A1A00);

    return Scaffold(
      backgroundColor: bgColor,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              iconColor.withValues(alpha: 0.15),
              bgColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                AnimatedBuilder(
                  animation: Listenable.merge(
                      [_enterCtrl, _burstCtrl, _wobbleCtrl, _emberCtrl]),
                  builder: (context, _) => SizedBox(
                    width: 300,
                    height: 300,
                    child: CustomPaint(
                      painter: _StreakCelebrationPainter(
                        burstProgress: _burstCtrl.value,
                        emberProgress: _emberCtrl.value,
                        phase: _phase,
                        color: iconColor,
                      ),
                      child: Center(
                        child: Transform.scale(
                          scale: _enterScale.value,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Radial glow blob behind the icon
                              Container(
                                width: 210,
                                height: 210,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      iconColor.withValues(
                                          alpha: _glow.value * 0.35),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              Transform.rotate(
                                angle: _wobble.value * 2 * pi,
                                child: Icon(
                                  _phase == 0
                                      ? Icons.local_fire_department_rounded
                                      : Icons.emoji_events_rounded,
                                  size: 150,
                                  color: iconColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                FadeTransition(
                  opacity: _textOpacity,
                  child: SlideTransition(
                    position: _textSlide,
                    child: Column(
                      children: [
                        Text(
                          _phase == 0
                              ? l.greetingStreak(widget.streak)
                              : l.streakMilestoneTitle(widget.streak),
                          style: tt.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (_phase == 1)
                          Text(
                            _getMilestoneMessage(l, widget.streak),
                            style: tt.bodyLarge?.copyWith(
                              color: Colors.white70,
                              height: 1.5,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                FadeTransition(
                  opacity: _textOpacity,
                  child: SyntraButton(
                    onPressed: _onNext,
                    color: iconColor,
                    child: Text(
                      _phase == 0 && widget.isMilestone
                          ? l.letsGoButton
                          : l.keepItUp,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getMilestoneMessage(S l, int streak) {
    switch (streak) {
      case 3:
        return l.streakMilestone3;
      case 7:
        return l.streakMilestone7;
      case 14:
        return l.streakMilestone14;
      case 30:
        return l.streakMilestone30;
      case 60:
        return l.streakMilestone60;
      case 100:
        return l.streakMilestone100;
      default:
        return l.streakMilestoneGeneric(streak);
    }
  }
}

// ── Painter ───────────────────────────────────────────────────────────────────

class _StreakCelebrationPainter extends CustomPainter {
  final double burstProgress;
  final double emberProgress;
  final int phase;
  final Color color;

  static const _emberCount = 10;

  _StreakCelebrationPainter({
    required this.burstProgress,
    required this.emberProgress,
    required this.phase,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Expanding rings on entrance / phase transition
    for (int i = 0; i < 3; i++) {
      final t = ((burstProgress - i * 0.2) / 0.6).clamp(0.0, 1.0);
      if (t <= 0) continue;
      canvas.drawCircle(
        center,
        75.0 + t * size.width * 0.40,
        Paint()
          ..color = color.withValues(alpha: (1.0 - t) * 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }

    // Rising embers — only during the fire phase
    if (phase == 0) {
      final startY = size.height * 0.62;
      for (int i = 0; i < _emberCount; i++) {
        final t = (emberProgress + i / _emberCount) % 1.0;
        final x = center.dx +
            sin(t * pi * 2.0 + i * 1.13) * 38.0 * (0.5 + (i % 3) * 0.35);
        final y = startY - t * size.height * 0.60;
        final opacity = (t < 0.15
                ? t / 0.15
                : (t > 0.75 ? (1.0 - t) / 0.25 : 1.0))
            .clamp(0.0, 0.85);
        final r = (3.5 - t * 2.5).clamp(0.5, 3.5);
        canvas.drawCircle(
          Offset(x, y),
          r,
          Paint()
            ..color = color.withValues(alpha: opacity)
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_StreakCelebrationPainter old) =>
      old.burstProgress != burstProgress ||
      old.emberProgress != emberProgress ||
      old.phase != phase;
}
