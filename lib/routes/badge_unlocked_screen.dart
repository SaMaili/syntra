import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../generated/l10n.dart';
import '../logic/badges_logic.dart';
import '../logic/comfort_zone_logic.dart';
import '../services/vibration_service.dart';
import '../theme/app_spacing.dart';
import '../theme/brand_colors.dart';
import '../widgets/syntra_button.dart';

class BadgeUnlockedScreen extends ConsumerStatefulWidget {
  final AppBadge badge;

  const BadgeUnlockedScreen({super.key, required this.badge});

  @override
  ConsumerState<BadgeUnlockedScreen> createState() =>
      _BadgeUnlockedScreenState();
}

class _BadgeUnlockedScreenState extends ConsumerState<BadgeUnlockedScreen>
    with TickerProviderStateMixin {
  late AnimationController _enterCtrl;
  late AnimationController _burstCtrl;
  late AnimationController _glowCtrl;
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
      duration: const Duration(milliseconds: 1000),
    );

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _wobble = Tween<double>(begin: -0.03, end: 0.03).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );
    _glow = Tween<double>(begin: 0.25, end: 0.85).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
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
    _glowCtrl.repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _textCtrl.forward();
    });

    VibrationService.milestone();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _burstCtrl.dispose();
    _glowCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);
    final badgeColor = widget.badge.color;
    final bgColor =
        Color.lerp(BrandColors.rootBg, badgeColor, 0.2) ??
            BrandColors.rootBg;
    final badgeName = _badgeName(l, widget.badge.id);

    return Scaffold(
      backgroundColor: bgColor,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              badgeColor.withValues(alpha: 0.3),
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
                  animation:
                      Listenable.merge([_enterCtrl, _burstCtrl, _glowCtrl]),
                  builder: (context, _) => SizedBox(
                    width: 300,
                    height: 300,
                    child: CustomPaint(
                      painter: _BadgeCelebrationPainter(
                        burstProgress: _burstCtrl.value,
                        color: badgeColor,
                      ),
                      child: Center(
                        child: Transform.scale(
                          scale: _enterScale.value,
                          child: Transform.rotate(
                            angle: _wobble.value * 2 * pi,
                            child: Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: badgeColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: badgeColor.withValues(
                                        alpha: _glow.value * 0.7),
                                    blurRadius: 30 + _glow.value * 30,
                                    spreadRadius: 4 + _glow.value * 12,
                                  ),
                                ],
                              ),
                              child: Icon(widget.badge.icon,
                                  size: 80, color: Colors.white),
                            ),
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
                          l.badgesTitle,
                          style: tt.titleMedium?.copyWith(
                            color: badgeColor,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          badgeName,
                          style: tt.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
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
                    onPressed: () => Navigator.of(context).pop(),
                    color: badgeColor,
                    child: Text(l.letsGoButton),
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

  String _badgeName(S l, String id) {
    if (id.startsWith('level_')) {
      final lvl = int.tryParse(id.substring(6)) ?? 0;
      if (lvl >= 1 && lvl <= ComfortZoneLogic.maxLevel) {
        return 'Level $lvl: ${ComfortZoneLogic.levelNames[lvl]}';
      }
    }
    switch (id) {
      case 'first_step':
        return l.badgeFirstStep;
      case 'ten_challenges':
        return l.badgeTenChallenges;
      case 'fifty_challenges':
        return l.badgeFiftyChallenges;
      case 'three_week_streak':
        return l.badgeThreeWeekStreak;
      case 'seven_week_streak':
        return l.badgeSevenWeekStreak;
      case 'century_aura':
        return l.badgeCenturyAura;
      case 'five_hundred_aura':
        return l.badgeFiveHundredAura;
      case 'brave_minutes':
        return l.badgeBraveMinutes;
      default:
        return id;
    }
  }
}

// ── Painter ───────────────────────────────────────────────────────────────────

class _BadgeCelebrationPainter extends CustomPainter {
  final double burstProgress;
  final Color color;

  // 12 particles evenly spread + slightly varied radii
  static const _angles = [
    0.0, 0.524, 1.047, 1.571, 2.094, 2.618,
    3.142, 3.665, 4.189, 4.712, 5.236, 5.760,
  ];
  static const _dists = [
    1.00, 0.88, 1.12, 0.92, 1.05, 0.85,
    1.00, 0.95, 1.10, 0.88, 1.02, 0.90,
  ];

  _BadgeCelebrationPainter({required this.burstProgress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Expanding rings (3, staggered)
    for (int i = 0; i < 3; i++) {
      final t = ((burstProgress - i * 0.2) / 0.6).clamp(0.0, 1.0);
      if (t <= 0) continue;
      canvas.drawCircle(
        center,
        80.0 + t * size.width * 0.42,
        Paint()
          ..color = color.withValues(alpha: (1.0 - t) * 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }

    // Burst particles
    if (burstProgress > 0) {
      final maxDist = size.width * 0.44;
      for (int i = 0; i < _angles.length; i++) {
        final r = burstProgress * maxDist * _dists[i];
        final opacity = burstProgress < 0.55
            ? 1.0
            : (1.0 - burstProgress) / 0.45;
        final pos = center +
            Offset(cos(_angles[i]) * r, sin(_angles[i]) * r);
        canvas.drawCircle(
          pos,
          5.0 * (1.0 - burstProgress * 0.5),
          Paint()..color = color.withValues(alpha: opacity.clamp(0.0, 1.0)),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BadgeCelebrationPainter old) =>
      old.burstProgress != burstProgress;
}
