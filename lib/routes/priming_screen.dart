import 'dart:async';

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../challenge.dart';
import '../generated/l10n.dart';
import '../router.dart';
import '../services/vibration_service.dart';
import '../theme/app_spacing.dart';
import '../widgets/syntra_button.dart';

/// 5-second priming screen shown between challenge selection and the timer.
class PrimingScreen extends StatefulWidget {
  final Challenge challenge;
  final bool isDailyMission;

  const PrimingScreen({
    super.key,
    required this.challenge,
    this.isDailyMission = false,
  });

  @override
  State<PrimingScreen> createState() => _PrimingScreenState();
}

class _PrimingScreenState extends State<PrimingScreen>
    with SingleTickerProviderStateMixin {
  static const _totalSeconds = 5;
  int _secondsLeft = _totalSeconds;
  Timer? _timer;
  bool _isExiting = false;

  /// Drives the circular arc from 1.0 → 0.0 continuously over the full
  /// countdown so the ring sweeps smoothly instead of jumping each second.
  late final AnimationController _arcController;

  @override
  void initState() {
    super.initState();

    _arcController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _totalSeconds),
    )..forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || _isExiting) {
        t.cancel();
        return;
      }
      if (ModalRoute.of(context)?.isCurrent != true) {
        t.cancel();
        return;
      }
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        t.cancel();
        _launch();
      }
    });
  }

  @override
  void dispose() {
    _arcController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String _headline(S l) {
    final c = widget.challenge;
    if (c.flirt) return l.primingHeadlineFlirt;
    if (c.type == 'group') return l.primingHeadlineGroup;
    if (c.time < 60) return l.primingHeadlineQuick;
    if (c.xp > 60) return l.primingHeadlineHard;
    return l.primingHeadlineDefault;
  }

  String _subtext(S l) {
    final c = widget.challenge;
    if (c.flirt) return l.primingSubFlirt;
    if (c.type == 'group') return l.primingSubGroup;
    if (c.time < 60) return l.primingSubQuick;
    if (c.xp > 60) return l.primingSubHard;
    return l.primingSubDefault;
  }

  Future<void> _launch() async {
    if (_isExiting) return;
    _isExiting = true;
    _timer?.cancel();
    if (!mounted) return;

    await VibrationService.start();
    if (!mounted) return;

    final result = await context.pushActiveChallenge(
      widget.challenge,
      isDailyMission: widget.isDailyMission,
    );
    if (mounted) context.pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = S.of(context);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const Spacer(),

              // ── Animated countdown ring + number ──────────────────────
              _CountdownRing(
                arcController: _arcController,
                secondsLeft: _secondsLeft,
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── Headline ──────────────────────────────────────────────
              Text(
                _headline(l),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _subtext(l),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.6,
                    ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // ── Actions ───────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: SyntraButton(
                  onPressed: _launch,
                  child: Text(l.imReady),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () {
                  if (_isExiting) return;
                  _isExiting = true;
                  _timer?.cancel();
                  context.pop();
                },
                child: Text(
                  l.notNow,
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Countdown ring ───────────────────────────────────────────────────────────

class _CountdownRing extends StatelessWidget {
  final AnimationController arcController;
  final int secondsLeft;

  const _CountdownRing({
    required this.arcController,
    required this.secondsLeft,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Arc value: 1.0 (full ring) → 0.0 (empty), continuous.
    final arcValue = Tween<double>(begin: 1.0, end: 0.0)
        .animate(arcController);

    return Stack(
      alignment: Alignment.center,
      children: [
        // ── Circular arc ──
        SizedBox(
          width: 120,
          height: 120,
          child: AnimatedBuilder(
            animation: arcValue,
            builder: (_, child) => CircularProgressIndicator(
              value: arcValue.value,
              strokeWidth: 5,
              strokeCap: StrokeCap.round,
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
            ),
          ),
        ),

        // ── Number — pops in with easeOutBack on each tick ──
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, animation) {
            // Incoming digit: scale from 0.4 → 1.0 with a slight overshoot,
            // outgoing digit: fades + scales down.
            final scaleIn = Tween<double>(begin: 0.4, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            );
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: scaleIn, child: child),
            );
          },
          child: Text(
            '$secondsLeft',
            // ValueKey forces AnimatedSwitcher to treat each number as a new
            // widget and run the transition even when the type stays the same.
            key: ValueKey(secondsLeft),
            style: tt.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.primary,
            ),
          ),
        ),
      ],
    );
  }
}
