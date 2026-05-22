// active_challenge_screen.dart — the runtime screen.
//
// Three states:
//   ready  → not started yet. read the prompt. optional starters.
//   arming → 700 ms breath/transition before the timer starts.
//   going  → timer running. coaching cycles. "I did it!" gated by lock.
//   last10 → going, but remaining ≤ 10 s: amber chip + caption.
//
// Timer is demoted: a 3 px progress bar at the top + a small corner chip.
// The challenge body is the hero (large Octarine, centered).
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:syntra/challenge.dart';
import 'package:syntra/logic/warmup_logic.dart' show WarmupSession;
import 'package:syntra/generated/l10n.dart';
import 'package:syntra/logic/comfort_zone_logic.dart';
import 'package:syntra/logic/notification_manager.dart';
import 'package:syntra/providers/note_providers.dart';
import 'package:syntra/providers/settings_providers.dart';
import 'package:syntra/routes/logbook/field_rows.dart'
    show emotionColor, emotionIcon, emotionText;
import 'package:syntra/router.dart';
import 'package:syntra/services/sound_service.dart';
import 'package:syntra/services/vibration_service.dart';
import 'package:syntra/theme/brand_colors.dart';
import 'package:syntra/widgets/syntra_button.dart';
import 'package:syntra/widgets/syntra_sheet.dart';
import 'package:timezone/data/latest.dart' as tz;

const double _kFullReward = 1.0;
const double _kLateReward = 0.8;
const double _kAbortPenalty = -0.5;
const Duration _kArmingDuration = Duration(milliseconds: 700);
const int _kLast10Seconds = 10;
const Duration _kCoachInterval = Duration(seconds: 8);

enum _Phase { ready, arming, going, last10 }

class ActiveChallengeScreen extends ConsumerStatefulWidget {
  final Challenge challenge;
  final bool isGuided;
  final int? overrideTime;

  /// Set when this challenge is one rung of a warm-up ladder. Threaded
  /// straight through to the done screen so it can chain to the next rung.
  final WarmupSession? warmup;

  const ActiveChallengeScreen({
    super.key,
    required this.challenge,
    this.isGuided = false,
    this.overrideTime,
    this.warmup,
  });

  @override
  ConsumerState<ActiveChallengeScreen> createState() =>
      _ActiveChallengeScreenState();
}

class _ActiveChallengeScreenState extends ConsumerState<ActiveChallengeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  _Phase _phase = _Phase.ready;
  late int _durationSec;
  late int _remaining;

  /// Ready-state duration override; null = challenge default.
  int? _override;
  DateTime? _startTime;
  DateTime? _endTime;
  int _coachIdx = 0;

  Timer? _mainTicker;
  Timer? _coachTicker;

  int? _bgScheduledNotificationId;
  bool _isDone = false;
  bool _showStarters = false;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  // 0..1 reflecting elapsed fraction of the timer (drives the slim top bar).
  late final AnimationController _progressController;
  // Quick reaction animation when the user taps "I'm going" → arming.
  late final AnimationController _armingController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _override = widget.overrideTime;
    _durationSec = _override ?? widget.challenge.time;
    _remaining = _durationSec;
    tz.initializeTimeZones();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    _progressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _durationSec),
    );
    _armingController = AnimationController(
      vsync: this,
      duration: _kArmingDuration,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mainTicker?.cancel();
    _coachTicker?.cancel();
    _fadeController.dispose();
    _progressController.dispose();
    _armingController.dispose();
    super.dispose();
  }

  // ─── Lifecycle: background-tab notifications ───────────────────────────

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (_phase != _Phase.going && _phase != _Phase.last10) return;
    if (_endTime == null) return;

    if (state == AppLifecycleState.resumed) {
      final now = DateTime.now();
      final secondsLeft = _endTime!.difference(now).inSeconds;
      if (mounted) {
        setState(() {
          _remaining = secondsLeft > 0 ? secondsLeft : 0;
          if (_phase == _Phase.going && _remaining <= _kLast10Seconds) {
            _phase = _Phase.last10;
          }
        });
      }
      if (_durationSec > 0 && _startTime != null) {
        final elapsedMs = now.difference(_startTime!).inMilliseconds;
        final progress = (elapsedMs / (_durationSec * 1000)).clamp(0.0, 1.0);
        _progressController.forward(from: progress);
      }
      if (_bgScheduledNotificationId != null && now.isBefore(_endTime!)) {
        NotificationManager.cancelNotification(_bgScheduledNotificationId!);
        _bgScheduledNotificationId = null;
      }
    } else if (state == AppLifecycleState.paused) {
      if (_bgScheduledNotificationId == null &&
          DateTime.now().isBefore(_endTime!)) {
        try {
          final id = await NotificationManager.sendNotification(
            channelId: 'challenge_timer',
            channelName: 'Challenge Timer',
            channelDescription: 'Notification for challenge timer',
            title: S.of(context).challengeTimerCompleteTitle,
            body: S
                .of(context)
                .challengeTimerCompleteBody(widget.challenge.title),
            vibration: true,
            scheduledTime: _endTime!,
          );
          _bgScheduledNotificationId = id;
        } catch (e) {
          debugPrint('Notification failed: $e');
        }
      }
    }
  }

  // ─── State transitions ─────────────────────────────────────────────────

  /// Ready-state only: user picked a custom duration. null = challenge default.
  void _setOverride(int? seconds) {
    if (_phase != _Phase.ready) return;
    HapticFeedback.selectionClick();
    setState(() {
      _override = seconds;
      _durationSec = seconds ?? widget.challenge.time;
      _remaining = _durationSec;
    });
  }

  void _onImGoingPressed() {
    HapticFeedback.selectionClick();
    unawaited(VibrationService.start());
    setState(() => _phase = _Phase.arming);
    _armingController.forward();

    Future.delayed(_kArmingDuration, () {
      if (!mounted) return;
      _startTime = DateTime.now();
      _endTime = _startTime!.add(Duration(seconds: _durationSec));
      _progressController.duration = Duration(seconds: _durationSec);
      setState(() => _phase = _Phase.going);
      _progressController.forward(from: 0);
      _startMainTimer();
      _startCoachTimer();
    });
  }

  void _startMainTimer() {
    _mainTicker?.cancel();
    final notifTitle = S.of(context).challengeTimerCompleteTitle;
    final notifBody = S
        .of(context)
        .challengeTimerCompleteBody(widget.challenge.title);

    _mainTicker = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (_isDone || !mounted) {
        t.cancel();
        return;
      }
      final now = DateTime.now();
      final secondsLeft = _endTime!.difference(now).inSeconds;

      if (secondsLeft > 0) {
        setState(() {
          _remaining = secondsLeft;
          if (_phase == _Phase.going && secondsLeft <= _kLast10Seconds) {
            _phase = _Phase.last10;
            unawaited(VibrationService.timerWarning());
          }
        });
      } else {
        t.cancel();
        setState(() => _remaining = 0);
        unawaited(VibrationService.timerEnd());
        try {
          if (_bgScheduledNotificationId != null) {
            await NotificationManager.cancelNotification(
              _bgScheduledNotificationId!,
            );
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
      }
    });
  }

  void _startCoachTimer() {
    _coachTicker?.cancel();
    _coachTicker = Timer.periodic(_kCoachInterval, (_) {
      if (!mounted) return;
      setState(() => _coachIdx = (_coachIdx + 1) % _coachLines(context).length);
    });
  }

  // ─── Commitment lock ───────────────────────────────────────────────────

  int get _lockSec {
    if (_durationSec == 0) return 0;
    final t = (_durationSec * 0.4).round();
    return t.clamp(8, 30).clamp(0, _durationSec);
  }

  int get _elapsed => _durationSec - _remaining;
  bool get _locked =>
      (_phase == _Phase.going || _phase == _Phase.last10) &&
      _elapsed < _lockSec;
  int get _lockRemaining => (_lockSec - _elapsed).clamp(0, _lockSec);
  double get _lockPct =>
      _lockSec == 0 ? 1.0 : (_elapsed / _lockSec).clamp(0.0, 1.0);

  // ─── Actions ───────────────────────────────────────────────────────────

  Future<void> _onDonePressed() async {
    if (_locked || _isDone) return;
    _isDone = true;
    unawaited(VibrationService.success());
    SoundService.playSuccess(enabled: ref.read(soundEffectsEnabledProvider));
    await Future.delayed(const Duration(milliseconds: 600));
    final reward = _remaining > 0 ? _kFullReward : _kLateReward;
    await _finishChallenge(reward);
  }

  Future<void> _onBailConfirmed() async {
    _isDone = true;
    if (_bgScheduledNotificationId != null) {
      await NotificationManager.cancelNotification(_bgScheduledNotificationId!);
      _bgScheduledNotificationId = null;
    }
    SoundService.playError(enabled: ref.read(soundEffectsEnabledProvider));
    await Future.delayed(const Duration(milliseconds: 400));
    await _finishChallenge(_kAbortPenalty);
  }

  Future<void> _showBailSheet() async {
    HapticFeedback.selectionClick();
    final l = S.of(context);
    // Ready state: no commitment yet; "Back" pops out without penalty.
    // When arriving via goActiveChallenge (try-again) the stack has nothing
    // to pop — fall back to home so the back button always works.
    if (_phase == _Phase.ready || _phase == _Phase.arming) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.goHome();
      }
      return;
    }
    final confirmed = await showSyntraSheet<bool>(
      context,
      useRootNavigator: true,
      builder: (ctx) => _BailSheet(l: l),
    );
    if (confirmed == true && mounted) {
      await _onBailConfirmed();
    }
  }

  Future<void> _showNotesSheet(Map<String, dynamic>? attempt) async {
    if (attempt == null) return;
    HapticFeedback.selectionClick();
    await showSyntraSheet<void>(
      context,
      builder: (_) => _NotesSheet(attempt: attempt),
    );
  }

  Future<void> _finishChallenge(double rewardFactor) async {
    if (!mounted) return;
    final durationSeconds = _startTime == null
        ? 0
        : DateTime.now().difference(_startTime!).inSeconds;
    final result = await context.pushChallengeDone(
      widget.challenge,
      rewardFactor,
      durationSeconds: durationSeconds,
      isGuided: widget.isGuided,
      warmup: widget.warmup,
    );
    if (result != null && mounted) {
      if (_bgScheduledNotificationId != null) {
        await NotificationManager.cancelNotification(
          _bgScheduledNotificationId!,
        );
        _bgScheduledNotificationId = null;
      }
      if (mounted) context.pop(result);
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────────

  List<String> _coachLines(BuildContext context) {
    final l = S.of(context);
    return [l.coachBreath, l.coachMoment, l.coachNoRush, l.coachWantsToo];
  }

  String _fmt(int seconds) {
    final m = (seconds ~/ 60).toString();
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ─── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isAmber = _phase == _Phase.last10;
    final isRunning = _phase == _Phase.going || _phase == _Phase.last10;
    // The most recent noted attempt, surfaced as an optional recap on the
    // ready screen. Null while loading or if the user has no noted attempt.
    final lastAttempt = ref
        .watch(lastAttemptProvider(widget.challenge.id))
        .valueOrNull;

    return PopScope(
      canPop: false,
      // System/predictive back routes through the same bail logic: a free
      // exit while still in the ready phase, a confirm sheet once committed.
      // Blocked entirely during the commitment-lock window.
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_locked) return;
        _showBailSheet();
      },
      child: Scaffold(
        body: Stack(
          children: [
            _AmbientGlow(phase: _phase),
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    _TopBar(
                      phase: _phase,
                      remaining: _remaining,
                      durationSec: _durationSec,
                      progress: _progressController,
                      arming: _armingController,
                      isRunning: isRunning,
                      isAmber: isAmber,
                      locked: _locked,
                      fmt: _fmt,
                      onBail: _showBailSheet,
                    ),
                    Expanded(
                      child: _Hero(
                        challenge: widget.challenge,
                        phase: _phase,
                        coachLine: isRunning
                            ? _coachLines(context)[_coachIdx %
                                  _coachLines(context).length]
                            : null,
                      ),
                    ),
                    _BottomActions(
                      phase: _phase,
                      locked: _locked,
                      lockRemaining: _lockRemaining,
                      lockPct: _lockPct,
                      hints: widget.challenge.hints,
                      challengeTime: widget.challenge.time,
                      overrideSec: _override,
                      onDuration: _setOverride,
                      showStarters: _showStarters,
                      onToggleStarters: () =>
                          setState(() => _showStarters = !_showStarters),
                      onImGoing: _onImGoingPressed,
                      onDone: _onDonePressed,
                      hasLastAttempt: lastAttempt != null,
                      onShowNotes: () => _showNotesSheet(lastAttempt),
                      fmt: _fmt,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Ambient glow background ─────────────────────────────────────────────────

class _AmbientGlow extends StatelessWidget {
  final _Phase phase;
  const _AmbientGlow({required this.phase});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isAmber = phase == _Phase.last10;
    final isReady = phase == _Phase.ready;
    // Brighter pink halo in ready, soft pink while going, amber from below in last10.
    return IgnorePointer(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: isAmber
              ? RadialGradient(
                  center: const Alignment(0, 1),
                  radius: 1.1,
                  colors: [
                    BrandColors.orange.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55],
                )
              : RadialGradient(
                  center: const Alignment(0, -1),
                  radius: 1.1,
                  colors: [
                    cs.primary.withValues(alpha: isReady ? 0.10 : 0.06),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55],
                ),
        ),
      ),
    );
  }
}

// ─── Top bar (slim progress + bail + corner timer chip) ──────────────────────

class _TopBar extends StatelessWidget {
  final _Phase phase;
  final int remaining;
  final int durationSec;
  final AnimationController progress;
  final AnimationController arming;
  final bool isRunning;
  final bool isAmber;
  final bool locked;
  final String Function(int) fmt;
  final VoidCallback onBail;

  const _TopBar({
    required this.phase,
    required this.remaining,
    required this.durationSec,
    required this.progress,
    required this.arming,
    required this.isRunning,
    required this.isAmber,
    required this.locked,
    required this.fmt,
    required this.onBail,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.06);

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Slim 3 px progress bar. Fills 0 → full during the 700 ms arming
          // beat, then drains full → empty over the timer. Visible from the
          // moment the user commits (arming) so the fill-in is seen.
          AnimatedOpacity(
            opacity: (phase == _Phase.arming || isRunning) ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 240),
            child: SizedBox(
              height: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  color: trackColor,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([progress, arming]),
                    builder: (_, _) {
                      final double fraction;
                      if (phase == _Phase.arming) {
                        // Smooth fill-in synced to the commitment beat.
                        fraction = const Cubic(
                          .16,
                          1,
                          .3,
                          1,
                        ).transform(arming.value);
                      } else {
                        // Drain with the remaining time.
                        fraction = (1.0 - progress.value).clamp(0.0, 1.0);
                      }
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: fraction,
                          heightFactor: 1,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: isAmber ? BrandColors.orange : cs.primary,
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (isAmber
                                              ? BrandColors.orange
                                              : cs.primary)
                                          .withValues(alpha: 0.5),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Bail / Back — hidden during the commitment-lock window.
              AnimatedOpacity(
                opacity: locked ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 260),
                child: IgnorePointer(
                  ignoring: locked,
                  child: InkWell(
                    onTap: onBail,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 6, 10, 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            phase == _Phase.ready || phase == _Phase.arming
                                ? S.of(context).activeBack
                                : S.of(context).activeBail,
                            style: tt.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Small timer chip — only while running.
              if (isRunning)
                _TimerChip(remaining: remaining, isAmber: isAmber, fmt: fmt),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimerChip extends StatelessWidget {
  final int remaining;
  final bool isAmber;
  final String Function(int) fmt;
  const _TimerChip({
    required this.remaining,
    required this.isAmber,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = SyntraSurface.of(context);
    final neutralBg = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.black.withValues(alpha: 0.04);
    final neutralBorder = s.bg3;
    final neutralFg = isDark ? s.muted : cs.onSurfaceVariant;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isAmber ? BrandColors.orange.withValues(alpha: 0.16) : neutralBg,
        border: Border.all(
          color: isAmber
              ? BrandColors.orange.withValues(alpha: 0.4)
              : neutralBorder,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule_rounded,
            size: 14,
            color: isAmber ? BrandColors.orangeWarm : neutralFg,
          ),
          const SizedBox(width: 6),
          Text(
            fmt(remaining),
            style: TextStyle(
              fontFamily: 'Octarine',
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: isAmber ? BrandColors.orangeWarm : neutralFg,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero (eyebrow chips + small title + big body + coach line) ─────────────

class _Hero extends StatelessWidget {
  final Challenge challenge;
  final _Phase phase;
  final String? coachLine;

  const _Hero({
    required this.challenge,
    required this.phase,
    required this.coachLine,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = S.of(context);
    final bodyColor = isDark ? Colors.white : cs.onSurface;
    final gradient = ComfortZoneLogic.levelGradient(challenge.level);

    // Auto-shrink body for long prompts so 34 px headlines don't break layout.
    double fontSize;
    final len = challenge.description.length;
    if (len > 110) {
      fontSize = 24;
    } else if (len > 70) {
      fontSize = 28;
    } else {
      fontSize = 34;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Eyebrow meta chips.
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: [
                    _Chip(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              gradient: gradient,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l.levelN(challenge.level),
                            style: _chipStyle(context),
                          ),
                        ],
                      ),
                    ),
                    _Chip(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 11,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            challenge.time >= 60
                                ? '${(challenge.time / 60).round()} min'
                                : '${challenge.time}s',
                            style: _chipStyle(context),
                          ),
                        ],
                      ),
                    ),
                    _Chip(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded, size: 11, color: cs.primary),
                          const SizedBox(width: 4),
                          Text(
                            '+${challenge.aura}',
                            style: _chipStyle(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                // Small pink uppercase title.
                Text(
                  challenge.title.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Octarine',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 3,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 16),
                // Hero body — the actual challenge prompt.
                Text(
                  challenge.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Octarine',
                    fontWeight: FontWeight.w700,
                    fontSize: fontSize,
                    height: 1.18,
                    letterSpacing: -0.5,
                    color: bodyColor,
                    shadows: phase != _Phase.ready
                        ? [
                            Shadow(
                              color: cs.primary.withValues(alpha: 0.18),
                              blurRadius: 30,
                            ),
                          ]
                        : null,
                  ),
                ),
                // Coaching line — only while going.
                if (phase == _Phase.going && coachLine != null) ...[
                  const SizedBox(height: 32),
                  _CoachLine(text: coachLine!),
                ],
                if (phase == _Phase.last10) ...[
                  const SizedBox(height: 32),
                  Text(
                    l.activeLast10Caption,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Octarine',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: BrandColors.orangeWarm,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextStyle _chipStyle(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.w600,
      fontSize: 11,
      letterSpacing: 0.2,
      color: cs.onSurfaceVariant,
    );
  }
}

class _Chip extends StatelessWidget {
  final Widget child;
  const _Chip({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.black.withValues(alpha: 0.04);
    final border = SyntraSurface.of(context).bg3;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: 1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: child,
    );
  }
}

class _CoachLine extends StatelessWidget {
  final String text;
  const _CoachLine({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.25),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        ),
      ),
      child: Text(
        text,
        key: ValueKey(text),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Inter',
          fontStyle: FontStyle.italic,
          fontSize: 14,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}

// ─── Bottom actions (starter drop-up + primary button) ───────────────────────

class _BottomActions extends StatelessWidget {
  final _Phase phase;
  final bool locked;
  final int lockRemaining;
  final double lockPct;
  final List<String> hints;
  final int challengeTime;
  final int? overrideSec;
  final ValueChanged<int?> onDuration;
  final bool showStarters;
  final VoidCallback onToggleStarters;
  final VoidCallback onImGoing;
  final VoidCallback onDone;
  final bool hasLastAttempt;
  final VoidCallback onShowNotes;
  final String Function(int) fmt;

  const _BottomActions({
    required this.phase,
    required this.locked,
    required this.lockRemaining,
    required this.lockPct,
    required this.hints,
    required this.challengeTime,
    required this.overrideSec,
    required this.onDuration,
    required this.showStarters,
    required this.onToggleStarters,
    required this.onImGoing,
    required this.onDone,
    required this.hasLastAttempt,
    required this.onShowNotes,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    final isReady = phase == _Phase.ready || phase == _Phase.arming;

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hints.isNotEmpty)
            _StarterDropUp(
              open: showStarters,
              hints: hints,
              onToggle: onToggleStarters,
            ),
          if (phase == _Phase.ready && hasLastAttempt)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SeeNotesCard(onTap: onShowNotes),
            ),
          if (phase == _Phase.ready)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _ReadyDurationPicker(
                challengeTime: challengeTime,
                selected: overrideSec,
                onChanged: onDuration,
              ),
            ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: const Cubic(.16, 1, .3, 1),
                ),
              ),
              child: child,
            ),
            child: isReady
                ? IgnorePointer(
                    key: const ValueKey('imgoing'),
                    ignoring: phase == _Phase.arming,
                    child: SyntraButton.icon(
                      onPressed: onImGoing,
                      icon: Icons.arrow_forward_rounded,
                      label: Text(l.activeImGoing),
                    ),
                  )
                : _DonePrimary(
                    key: const ValueKey('done'),
                    locked: locked,
                    lockRemaining: lockRemaining,
                    lockPct: lockPct,
                    onPressed: onDone,
                    fmt: fmt,
                  ),
          ),
        ],
      ),
    );
  }
}

class _DonePrimary extends StatelessWidget {
  final bool locked;
  final int lockRemaining;
  final double lockPct;
  final VoidCallback onPressed;
  final String Function(int) fmt;

  const _DonePrimary({
    super.key,
    required this.locked,
    required this.lockRemaining,
    required this.lockPct,
    required this.onPressed,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    const successGreen = BrandColors.green;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedOpacity(
          duration: const Duration(milliseconds: 320),
          opacity: locked ? 0.55 : 1.0,
          child: ColorFiltered(
            colorFilter: locked
                ? const ColorFilter.matrix([
                    0.6,
                    0.4,
                    0,
                    0,
                    0,
                    0.4,
                    0.6,
                    0,
                    0,
                    0,
                    0.4,
                    0.4,
                    0.2,
                    0,
                    0,
                    0,
                    0,
                    0,
                    1,
                    0,
                  ])
                : const ColorFilter.mode(
                    Colors.transparent,
                    BlendMode.multiply,
                  ),
            child: IgnorePointer(
              ignoring: locked,
              child: SyntraButton.icon(
                onPressed: onPressed,
                icon: locked ? Icons.lock_outline_rounded : Icons.check_rounded,
                label: Text(
                  locked
                      ? '${l.activeStayWithIt} · ${fmt(lockRemaining)}'
                      : l.doneExcited,
                ),
                color: successGreen,
              ),
            ),
          ),
        ),
        // The green commitment-lock bar bumps up when the timer starts and
        // collapses away the instant it unlocks. No fade — pure spatial motion.
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 380),
          switchInCurve: const Cubic(.16, 1, .3, 1),
          switchOutCurve: Curves.easeOutCubic,
          transitionBuilder: (child, animation) => SizeTransition(
            sizeFactor: animation,
            axisAlignment: -1,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.4),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: locked
              ? _LockProgress(key: const ValueKey('lockbar'), lockPct: lockPct)
              : const SizedBox(key: ValueKey('nolock'), width: double.infinity),
        ),
      ],
    );
  }
}

// ─── Commitment-lock progress bar + hint (slides in/out as a unit) ──────────

class _LockProgress extends StatelessWidget {
  final double lockPct;
  const _LockProgress({super.key, required this.lockPct});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = S.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const successGreen = BrandColors.green;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 2,
            child: Container(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.08),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AnimatedFractionallySizedBox(
                  duration: const Duration(seconds: 1),
                  widthFactor: lockPct,
                  heightFactor: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: successGreen,
                      boxShadow: [
                        BoxShadow(
                          color: successGreen.withValues(alpha: 0.6),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l.activeLockHint,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: cs.outline,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

// ─── Starter drop-up panel ───────────────────────────────────────────────────

class _StarterDropUp extends StatelessWidget {
  final bool open;
  final List<String> hints;
  final VoidCallback onToggle;

  const _StarterDropUp({
    required this.open,
    required this.hints,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = S.of(context);
    final pink = cs.primary;
    final pinkSoft = isDark ? BrandColors.pinkSoft : pink;
    final fg = isDark ? Colors.white : cs.onSurface;
    final divider = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.06);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drop-UP panel — anchored above the trigger.
          AnimatedSize(
            duration: const Duration(milliseconds: 360),
            curve: Curves.easeOutCubic,
            alignment: Alignment.bottomCenter,
            child: open
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (int i = 0; i < hints.length; i++)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              border: i == 0
                                  ? null
                                  : Border(top: BorderSide(color: divider)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: pink,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: pink.withValues(alpha: 0.6),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    hints[i],
                                    style: tt.bodyLarge?.copyWith(
                                      fontFamily: 'Octarine',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: fg,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
          // Trigger text-link
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              onToggle();
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lightbulb_outline_rounded, size: 14, color: pink),
                  const SizedBox(width: 6),
                  Text(
                    open ? l.activeHideStarters : l.activeNeedStarter,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: pinkSoft,
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    turns: open ? 0.5 : 0.0,
                    child: Icon(
                      Icons.expand_less_rounded,
                      size: 16,
                      color: pinkSoft,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bail confirmation sheet ────────────────────────────────────────────────

class _BailSheet extends StatelessWidget {
  final S l;
  const _BailSheet({required this.l});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : cs.onSurface;

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.bailTitle,
            style: tt.titleLarge?.copyWith(
              fontFamily: 'Octarine',
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.bailBody,
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          SyntraButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.bailKeepGoing),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l.bailSaveForLater,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Ready-state duration picker (merged from the old PrimingScreen) ──────────

class _ReadyDurationPicker extends StatelessWidget {
  final int challengeTime;
  final int? selected; // null = challenge default
  final ValueChanged<int?> onChanged;

  const _ReadyDurationPicker({
    required this.challengeTime,
    required this.selected,
    required this.onChanged,
  });

  static const _overrides = [30, 60, 120, 300]; // seconds

  String _fmt(int s) {
    if (s < 60) return '${s}s';
    final m = s ~/ 60;
    final r = s % 60;
    return r == 0 ? '${m}m' : '${m}m ${r}s';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = S.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l.timerCustomLabel.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            color: cs.outline,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: [
            _DurationChip(
              label: '${_fmt(challengeTime)} ★',
              selected: selected == null,
              onTap: () => onChanged(null),
            ),
            for (final t in _overrides)
              if (t != challengeTime)
                _DurationChip(
                  label: _fmt(t),
                  selected: selected == t,
                  onTap: () => onChanged(t),
                ),
          ],
        ),
      ],
    );
  }
}

class _DurationChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DurationChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final neutralBg = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.black.withValues(alpha: 0.04);
    final border = SyntraSurface.of(context).bg3;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? cs.primary.withValues(alpha: 0.14) : neutralBg,
          border: Border.all(
            color: selected ? cs.primary : border,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? cs.primary : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ─── "See your last note" recap (ready screen) ───────────────────────────────

class _SeeNotesCard extends StatelessWidget {
  final VoidCallback onTap;
  const _SeeNotesCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = SyntraSurface.of(context);
    final l = S.of(context);
    final bg = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.black.withValues(alpha: 0.04);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: s.bg3, width: 1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(Icons.sticky_note_2_outlined, size: 18, color: cs.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l.activeSeeLastNote,
                  style: tt.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : cs.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Last-attempt recap sheet (Before → After + the note) ────────────────────

class _NotesSheet extends StatelessWidget {
  final Map<String, dynamic> attempt;
  const _NotesSheet({required this.attempt});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = SyntraSurface.of(context);
    final l = S.of(context);
    final fg = isDark ? Colors.white : cs.onSurface;

    final note = (attempt['notes'] as String?)?.trim() ?? '';
    final feeling = attempt['feeling'] as int?;
    final preAnxiety = attempt['pre_anxiety'] as int?;
    final beforeIdx = preAnxiety == null
        ? null
        : (5 - preAnxiety).clamp(0, 4).toInt();

    final ts = DateTime.tryParse(attempt['timestamp'] as String? ?? '');
    // No locale arg: only the default (en_US) date-symbol data is bundled
    // (the app never calls initializeDateFormatting), so a localized pattern
    // would throw for non-en users.
    final dateStr = ts == null ? '' : DateFormat('MMM d · HH:mm').format(ts);

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.activeLastAttempt.toUpperCase(),
            style: tt.labelSmall?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dateStr,
            style: tt.titleLarge?.copyWith(
              fontFamily: 'Octarine',
              fontWeight: FontWeight.w700,
              fontSize: 22,
              letterSpacing: -0.4,
              color: fg,
            ),
          ),
          if (beforeIdx != null && feeling != null) ...[
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _MoodCell(label: l.beforeLabel, idx: beforeIdx),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: cs.primary.withValues(alpha: 0.85),
                  ),
                ),
                Expanded(
                  child: _MoodCell(label: l.afterLabel, idx: feeling),
                ),
              ],
            ),
          ],
          if (note.isNotEmpty) ...[
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: s.bg1,
                border: Border.all(color: s.bg3, width: 1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.activeYourNote.toUpperCase(),
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '“$note”',
                    style: tt.bodyLarge?.copyWith(
                      fontFamily: 'Octarine',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                      color: fg,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          SyntraButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.activeGotIt),
          ),
        ],
      ),
    );
  }
}

class _MoodCell extends StatelessWidget {
  final String label;
  final int idx;
  const _MoodCell({required this.label, required this.idx});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = SyntraSurface.of(context);
    final color = emotionColor(idx);
    final bg = isDark ? s.bg2 : s.bg1;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.4 : 0.55),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: tt.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.4,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 6),
          Icon(emotionIcon(idx), color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            emotionText(context, idx),
            style: tt.labelLarge?.copyWith(
              fontFamily: 'Octarine',
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
