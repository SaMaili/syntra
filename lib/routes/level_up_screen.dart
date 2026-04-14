import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../generated/l10n.dart';
import '../logic/comfort_zone_logic.dart';
import '../services/vibration_service.dart';
import '../theme/app_spacing.dart';
import '../widgets/syntra_button.dart';

class LevelUpScreen extends ConsumerStatefulWidget {
  final int newLevel;

  const LevelUpScreen({super.key, required this.newLevel});

  @override
  ConsumerState<LevelUpScreen> createState() => _LevelUpScreenState();
}

class _LevelUpScreenState extends ConsumerState<LevelUpScreen>
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

    final level = widget.newLevel.clamp(1, ComfortZoneLogic.maxLevel);
    final gradient = ComfortZoneLogic.levelGradient(level);
    final (bgBegin, _) = ComfortZoneLogic.levelGradientColors[level];
    final bgColor = Color.lerp(const Color(0xFF121212), bgBegin, 0.25) ??
        const Color(0xFF121212);
    final icon = ComfortZoneLogic.levelIcons[level];
    final name = ComfortZoneLogic.levelNames[level];
    final desc = ComfortZoneLogic.levelDescriptions[level];

    return Scaffold(
      backgroundColor: bgColor,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              gradient.colors.first.withOpacity(0.25),
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
                        gradient: gradient,
                      ),
                      child: Icon(icon, size: 80, color: Colors.white),
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
                          l.levelUnlocked(widget.newLevel),
                          style: tt.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          name,
                          style: tt.titleLarge?.copyWith(
                            color: gradient.colors.first,
                            fontWeight: FontWeight.w600,
                            fontSize: 22,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          desc,
                          style: tt.bodyLarge?.copyWith(
                            color: Colors.white70,
                            height: 1.5,
                            fontSize: 16,
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
                    color: gradient.colors.first,
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
}
