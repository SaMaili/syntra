// active_challenge_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:syntra/challenge.dart';
import 'package:syntra/generated/l10n.dart';
import 'package:syntra/logic/notification_manager.dart';
import 'package:syntra/providers/settings_providers.dart';
import 'package:syntra/router.dart';
import 'package:syntra/services/sound_service.dart';
import 'package:syntra/services/vibration_service.dart';
import 'package:syntra/theme/app_spacing.dart';
import 'package:syntra/widgets/challenge_card.dart';
import 'package:syntra/widgets/not_sure_what_to_say_dialog.dart';
import 'package:syntra/widgets/syntra_button.dart';
import 'package:syntra/widgets/syntra_progress_bar.dart';
import 'package:timezone/data/latest.dart' as tz;

class ActiveChallengeScreen extends ConsumerStatefulWidget {
  final Challenge challenge;
  final bool isDailyMission;
  final int? overrideTime;
  final int? preAnxiety;

  const ActiveChallengeScreen({
    super.key,
    required this.challenge,
    this.isDailyMission = false,
    this.overrideTime,
    this.preAnxiety,
  });

  @override
  ConsumerState<ActiveChallengeScreen> createState() =>
      _ActiveChallengeScreenState();
}

class _ActiveChallengeScreenState extends ConsumerState<ActiveChallengeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int abortLockTimer = 15;
  int mainTimer = 0;

  late DateTime _startTime;
  late DateTime _endTime;
  bool abortLockDone = false;

  late final Future<void> mainTicker;
  late final Future<void> abortLockTicker;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  // Drives the linear progress bar continuously — no per-second jumps.
  late AnimationController _progressController;

  int? _bgScheduledNotificationId;
  bool _isDone = false;
  bool _timersStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    mainTimer = widget.overrideTime ?? widget.challenge.time;
    _startTime = DateTime.now();
    _endTime = _startTime.add(Duration(seconds: mainTimer));
    tz.initializeTimeZones();
    unawaited(VibrationService.start());

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();

    _progressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: mainTimer),
    )..forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_timersStarted) {
      _timersStarted = true;
      _startMainTimer();
      _startAbortLockTimer();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _fadeController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      final now = DateTime.now();
      final secondsLeft = _endTime.difference(now).inSeconds;
      setState(() {
        mainTimer = secondsLeft > 0 ? secondsLeft : 0;
      });
      // Re-sync the continuous progress animation to actual elapsed time.
      final total = widget.overrideTime ?? widget.challenge.time;
      if (total > 0) {
        final elapsed = now.difference(_startTime).inMilliseconds;
        final progress = (elapsed / (total * 1000)).clamp(0.0, 1.0);
        _progressController.forward(from: progress);
      }

      if (_bgScheduledNotificationId != null &&
          DateTime.now().isBefore(_endTime)) {
        NotificationManager.cancelNotification(_bgScheduledNotificationId!);
        _bgScheduledNotificationId = null;
      }
    } else if (state == AppLifecycleState.paused) {
      if (_bgScheduledNotificationId == null &&
          DateTime.now().isBefore(_endTime)) {
        final scheduledTime = _endTime;
        try {
          NotificationManager.sendNotification(
                channelId: 'challenge_timer',
                channelName: 'Challenge Timer',
                channelDescription: 'Notification for challenge timer',
                title: S.of(context).challengeTimerCompleteTitle,
                body: S
                    .of(context)
                    .challengeTimerCompleteBody(widget.challenge.title),
                vibration: true,
                scheduledTime: scheduledTime,
              )
              .then((id) {
                _bgScheduledNotificationId = id;
              })
              .catchError((e) {
                debugPrint('❌ Notification failed: $e');
              });
        } catch (e) {
          debugPrint('❌ Notification failed: $e');
        }
      }
    }
  }

  Future<void> _startMainTimer() async {
    final notifTitle = S.of(context).challengeTimerCompleteTitle;
    final notifBody =
        S.of(context).challengeTimerCompleteBody(widget.challenge.title);

    mainTicker = Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (_isDone) return false;
      final now = DateTime.now();
      final secondsLeft = _endTime.difference(now).inSeconds;

      if (secondsLeft > 0) {
        if (mounted) setState(() => mainTimer = secondsLeft);
        if (secondsLeft == 10) unawaited(VibrationService.timerWarning());
        return true;
      } else {
        if (mounted) setState(() => mainTimer = 0);
        unawaited(VibrationService.timerEnd());

        try {
          if (_bgScheduledNotificationId != null) {
            await NotificationManager.cancelNotification(
                _bgScheduledNotificationId!);
            _bgScheduledNotificationId = null;
          }
          await NotificationManager.sendImmediateNotification(
            title: notifTitle,
            body: notifBody,
            data: {'type': 'challenge_timer_complete'},
          );
        } catch (e) {
          debugPrint('Challenge-end notification failed: $e');
        }
        return false;
      }
    });
  }

  void _startAbortLockTimer() {
    abortLockTicker = Future.doWhile(() async {
      if (abortLockTimer > 0) {
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) setState(() => abortLockTimer--);
        return abortLockTimer > 0 && mounted;
      }
      if (mounted && !abortLockDone) setState(() => abortLockDone = true);
      return false;
    });
  }

  String _formatTime(int seconds) {
    final min = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  Future<void> _finishChallenge(double rewardFactor) async {
    final durationSeconds = DateTime.now().difference(_startTime).inSeconds;
    final result = await context.pushChallengeDone(
      widget.challenge,
      rewardFactor,
      durationSeconds: durationSeconds,
      isDailyMission: widget.isDailyMission,
      preAnxiety: widget.preAnxiety,
    );
    if (result != null && mounted) {
      if (_bgScheduledNotificationId != null) {
        await NotificationManager.cancelNotification(
            _bgScheduledNotificationId!);
        _bgScheduledNotificationId = null;
      }
      if (mounted) context.pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final over = abortLockTimer <= 0;
    final mainTimeOver = mainTimer <= 0;

    return PopScope(
      canPop: false,
      child: Scaffold(
        // No AppBar — every pixel is content on this screen.
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final h = constraints.maxHeight;

                // All vertical rhythm is proportional to available height.
                // Clamped so the layout stays sane on every device.
                final gapLg = (h * 0.028).clamp(10.0, 24.0);
                final gapSm = (h * 0.016).clamp(6.0, 14.0);
                final buttonH = (h * 0.09).clamp(52.0, 72.0);

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md),
                  child: Column(
                    children: [
                      SizedBox(height: gapSm),

                      // ── Timer bar ──────────────────────────────────────
                      if (!mainTimeOver) ...[
                        AnimatedBuilder(
                          animation: _progressController,
                          builder: (_, child) => _TimerBar(
                            formattedTime: _formatTime(mainTimer),
                            progress: _progressController.value,
                            isUrgent: mainTimer <= 10 && mainTimer > 0,
                          ),
                        ),
                        SizedBox(height: gapLg),
                      ] else ...[
                        SizedBox(height: gapSm),
                      ],

                      // ── Challenge card — fills all remaining space ─────
                      Expanded(
                        child: ChallengeCard(
                          challenge: widget.challenge,
                          showXP: false,
                        ),
                      ),

                      SizedBox(height: gapLg),

                      // ── Help button ────────────────────────────────────
                      if (!mainTimeOver) ...[
                        _HelpButton(hints: widget.challenge.hints),
                        SizedBox(height: gapSm),
                      ],

                      // ── Primary action ─────────────────────────────────
                      if (over)
                        SyntraButton.icon(
                          onPressed: () =>
                              _onDonePressed(mainTimeOver ? 0.8 : 1.0),
                          height: mainTimeOver ? buttonH + 8 : buttonH,
                          icon:
                              mainTimeOver ? Icons.flash_on : Icons.check,
                          label: Text(S.of(context).doneExcited),
                        )
                      else
                        SyntraButton(
                          onPressed: null,
                          height: buttonH,
                          child: Text(S
                              .of(context)
                              .stillSecondsLeft(
                                  abortLockTimer.toString())),
                        ),

                      // ── Abort — slides up from below when lock expires ──
                      ClipRect(
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 380),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.topCenter,
                          child: over
                              ? TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: const Duration(milliseconds: 320),
                                  curve: Curves.easeOutCubic,
                                  builder: (_, value, child) => Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset: Offset(0, 18 * (1.0 - value)),
                                      child: child,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(height: gapSm * 0.5),
                                      _AbortButton(
                                          onAbort: _onAbortPressed),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),

                      SizedBox(height: gapSm),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onDonePressed(double rewardFactor) async {
    _isDone = true;
    unawaited(VibrationService.success());
    SoundService.playSuccess(
        enabled: ref.read(soundEffectsEnabledProvider));
    await Future.delayed(const Duration(milliseconds: 600));
    await _finishChallenge(rewardFactor);
  }

  Future<void> _onAbortPressed() async {
    _isDone = true; // Stop the timer loop so no completion notification fires
    if (_bgScheduledNotificationId != null) {
      await NotificationManager.cancelNotification(_bgScheduledNotificationId!);
      _bgScheduledNotificationId = null;
    }
    SoundService.playError(enabled: ref.read(soundEffectsEnabledProvider));
    await Future.delayed(const Duration(milliseconds: 600));
    await _finishChallenge(-0.5);
  }
}

// ─── Timer bar ────────────────────────────────────────────────────────────────

class _TimerBar extends StatelessWidget {
  final String formattedTime;
  final double progress; // 0.0 = just started, 1.0 = time up
  final bool isUrgent;

  const _TimerBar({
    required this.formattedTime,
    required this.progress,
    required this.isUrgent,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final barColor = isUrgent ? cs.error : cs.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                S.of(context).timeRemaining.toUpperCase(),
                style: tt.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  final scaleIn = Tween<double>(begin: 0.55, end: 1.0).animate(
                    CurvedAnimation(
                        parent: animation, curve: Curves.easeOutBack),
                  );
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: scaleIn, child: child),
                  );
                },
                child: Text(
                  formattedTime,
                  key: ValueKey(formattedTime),
                  style: tt.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: barColor,
                    letterSpacing: 3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          // Progress bar — fills left to right as time elapses
          SyntraXpBar(
            value: progress,
            minHeight: 5,
            color: barColor,
            duration: const Duration(milliseconds: 200),
            silent: true,
          ),
        ],
      ),
    );
  }
}

// ─── Help button ──────────────────────────────────────────────────────────────

class _HelpButton extends StatelessWidget {
  final List<String> hints;
  const _HelpButton({required this.hints});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.lightbulb_outline),
        label: Text(S.of(context).notSureWhatToSay),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: cs.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
        ),
        onPressed: () => showDialog(
          context: context,
          builder: (_) => NotSureWhatToSayDialog(hints: hints),
        ),
      ),
    );
  }
}

// ─── Abort button ─────────────────────────────────────────────────────────────

class _AbortButton extends StatelessWidget {
  final VoidCallback onAbort;
  const _AbortButton({required this.onAbort});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onAbort,
      child: Text(
        S.of(context).notToday,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}
