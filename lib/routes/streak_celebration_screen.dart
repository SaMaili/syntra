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

class _StreakCelebrationScreenState extends ConsumerState<StreakCelebrationScreen>
    with TickerProviderStateMixin {
  int _phase = 0; // 0: Daily Streak, 1: Milestone (if applicable)

  late AnimationController _fireCtrl;
  late Animation<double> _fireScale;
  late Animation<double> _fireRotation;
  
  late AnimationController _textCtrl;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _fireCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fireScale = CurvedAnimation(
      parent: _fireCtrl,
      curve: Curves.elasticOut,
    );

    _fireRotation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(
        parent: _fireCtrl,
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

    _startPhaseAnimations();
  }

  void _startPhaseAnimations() {
    _fireCtrl.forward(from: 0.0);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _textCtrl.forward(from: 0.0);
    });
  }

  void _onNext() {
    if (_phase == 0 && widget.isMilestone) {
      setState(() {
        _phase = 1;
      });
      _fireCtrl.reset();
      _textCtrl.reset();
      _startPhaseAnimations();
      VibrationService.milestone();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _fireCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);

    // Dynamic background color based on phase
    final bgColor = _phase == 0 
        ? const Color(0xFF121212) 
        : const Color(0xFF1A1A00); // Slight golden tint for milestone

    return Scaffold(
      backgroundColor: bgColor,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              _phase == 0 
                  ? cs.tertiary.withOpacity(0.15) 
                  : Colors.amber.withOpacity(0.2),
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
                
                // ── Animation Area ─────────────────────────────────────────────
                ScaleTransition(
                  scale: _fireScale,
                  child: RotationTransition(
                    turns: _fireRotation,
                    child: Icon(
                      _phase == 0
                          ? Icons.local_fire_department_rounded
                          : Icons.emoji_events_rounded,
                      size: 180,
                      color: _phase == 0 ? cs.tertiary : Colors.amber,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Text Content ───────────────────────────────────────────────
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

                // ── Action ─────────────────────────────────────────────────────
                FadeTransition(
                  opacity: _textOpacity,
                  child: SyntraButton(
                    onPressed: _onNext,
                    color: _phase == 0 ? cs.tertiary : Colors.amber,
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
      case 3: return l.streakMilestone3;
      case 7: return l.streakMilestone7;
      case 14: return l.streakMilestone14;
      case 30: return l.streakMilestone30;
      case 60: return l.streakMilestone60;
      case 100: return l.streakMilestone100;
      default: return l.streakMilestoneGeneric(streak);
    }
  }
}
