import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../generated/l10n.dart';
import '../logic/badges_logic.dart';
import '../services/vibration_service.dart';
import '../theme/app_spacing.dart';
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
  late AnimationController _iconCtrl;
  late Animation<double> _iconScale;
  late Animation<double> _iconRotation;

  late AnimationController _textCtrl;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _iconCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _iconScale = CurvedAnimation(
      parent: _iconCtrl,
      curve: Curves.elasticOut,
    );

    _iconRotation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(
        parent: _iconCtrl,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
      ),
    );

    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _textOpacity = CurvedAnimation(
      parent: _textCtrl,
      curve: Curves.easeIn,
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textCtrl,
      curve: Curves.easeOutCubic,
    ));

    _iconCtrl.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _textCtrl.forward();
    });

    VibrationService.milestone();
  }

  @override
  void dispose() {
    _iconCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);

    final badgeColor = widget.badge.color;
    final bgColor =
        Color.lerp(const Color(0xFF121212), badgeColor, 0.2) ??
            const Color(0xFF121212);
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
              badgeColor.withOpacity(0.3),
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

                // ── Icon ───────────────────────────────────────────────────────
                ScaleTransition(
                  scale: _iconScale,
                  child: RotationTransition(
                    turns: _iconRotation,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: badgeColor,
                      ),
                      child: Icon(widget.badge.icon, size: 80,
                          color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Text ───────────────────────────────────────────────────────
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

                // ── Action ─────────────────────────────────────────────────────
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
    switch (id) {
      case 'first_step': return l.badgeFirstStep;
      case 'ten_challenges': return l.badgeTenChallenges;
      case 'fifty_challenges': return l.badgeFiftyChallenges;
      case 'three_week_streak': return l.badgeThreeWeekStreak;
      case 'seven_week_streak': return l.badgeSevenWeekStreak;
      case 'century_xp': return l.badgeCenturyXp;
      case 'five_hundred_xp': return l.badgeFiveHundredXp;
      case 'brave_minutes': return l.badgeBraveMinutes;
      default: return id;
    }
  }
}
