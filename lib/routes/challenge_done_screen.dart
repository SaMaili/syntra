// challenge_done_screen.dart — stepped reflection flow.
//
// Replaces the single-screen survey with a paced flow:
//
//   success path:
//     celebrate → reflect0 → reflect1 → reflect2 → notes → saved
//
//   aborted path:
//     aborted (single kindness page with Try-again / Back-to-home)
//
// Each reflect step is one question with five tap-targets and auto-advance.
// All celebration side-effects (level-up, badges, weekly goal) fire when the
// user taps "Save reflection" or "Skip — save the win", before the Saved
// confirmation appears.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../challenge.dart';
import '../data/logbook_repository.dart';
import '../data/settings_repository.dart';
import '../generated/l10n.dart';
import '../logic/badges_logic.dart';
import '../logic/comfort_zone_logic.dart';
import '../logic/warmup_logic.dart' show WarmupSession;
import '../logic/weekly_streak_logic.dart';
import '../providers/settings_providers.dart';
import '../providers/shop_providers.dart' show applyStreakFreezesIfNeeded;
import '../providers/statistics_providers.dart'
    show czlCompletionsProvider, refreshStatistics;
import '../router.dart';
import '../services/sound_service.dart';
import '../services/vibration_service.dart';
import '../static.dart';
import '../theme/brand_colors.dart';
import '../widgets/syntra_button.dart';
import 'onboarding/onboarding_shared.dart' show OnbProgress;

int socialProofCount(String challengeId) {
  var hash = 0;
  for (final c in challengeId.codeUnits) {
    hash = (hash * 31 + c) & 0x7FFFFFFF;
  }
  return 800 + (hash % 3700);
}

String coachMessage(S l, String challengeId) {
  final messages = [
    l.coachMsg1,
    l.coachMsg2,
    l.coachMsg3,
    l.coachMsg4,
    l.coachMsg5,
    l.coachMsg6,
    l.coachMsg7,
  ];
  var hash = 0;
  for (final c in challengeId.codeUnits) {
    hash = (hash * 17 + c) & 0x7FFFFFFF;
  }
  return messages[hash % messages.length];
}

enum _Stage { celebrate, reflect, notes, saved }

class ChallengeDoneScreen extends ConsumerStatefulWidget {
  final Challenge challenge;
  final double rewardFactor;
  final int? durationSeconds;
  final bool isGuided;

  /// Present when this challenge is a rung of a warm-up ladder. Drives the
  /// "Warm-up n/total" card and auto-chaining into the next rung.
  final WarmupSession? warmup;

  const ChallengeDoneScreen({
    super.key,
    required this.challenge,
    this.rewardFactor = 1.0,
    this.durationSeconds,
    this.isGuided = false,
    this.warmup,
  });

  @override
  ConsumerState<ChallengeDoneScreen> createState() =>
      _ChallengeDoneScreenState();
}

class _ChallengeDoneScreenState extends ConsumerState<ChallengeDoneScreen> {
  // Stepped flow: celebrate → reflect(0..2) → notes → saved.
  static const _questionCount = 3;
  static const _total = _questionCount + 1; // questions + notes

  _Stage _stage = _Stage.celebrate;
  int _q = 0; // current reflect question (0..2)
  int _navDir = 1; // 1 = forward, -1 = back — drives the reflect slide

  int? _preAnxiety; // 1..5
  int? _feeling; // 0..4
  int? _perception; // 0..4
  final TextEditingController _notesController = TextEditingController();

  int _weekStreak = 0;
  int _weekAura = 0;
  bool _loaded = false;
  bool _saving = false;

  // Level progress shown on the celebrate page — pre-computed once so the
  // card shows the post-win state (including this completion) immediately.
  int _czlLevel = 1;
  int _czlDisplayCompletions = 0;
  int _czlNeeded = 3;
  double _czlProgress = 0.0;

  bool get _isAborted => widget.rewardFactor < 0;
  int get _earnedAura =>
      _isAborted ? 0 : (widget.challenge.aura * widget.rewardFactor).round();
  int get _bonusAura =>
      widget.isGuided && !_isAborted ? (_earnedAura * 0.1).round() : 0;
  int get _totalAura => _earnedAura + _bonusAura;
  String get _status => _isAborted ? 'tried' : 'success';

  @override
  void initState() {
    super.initState();
    if (_isAborted) {
      unawaited(VibrationService.abort());
    } else {
      unawaited(VibrationService.success());
      // Pre-compute CZL progress including the current (not-yet-saved) win.
      final level = ref.read(comfortZoneLevelProvider);
      final completions = ref.read(czlCompletionsProvider);
      final needed = ComfortZoneLogic.completionsNeeded(level);
      final contributes = widget.challenge.level == level;
      _czlLevel = level;
      _czlDisplayCompletions = completions + (contributes ? 1 : 0);
      _czlNeeded = needed;
      _czlProgress = level >= ComfortZoneLogic.maxLevel || needed == 0
          ? 1.0
          : (_czlDisplayCompletions / needed).clamp(0.0, 1.0);
    }
    _loadStats();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    final aura = await LogbookRepository.instance.currentWeekAura();
    final stats = await LogbookRepository.instance.overviewStats();
    if (!mounted) return;
    setState(() {
      _weekAura = aura + _totalAura; // include the just-earned aura
      _weekStreak = stats['weekStreak'] ?? stats['pendingWeekStreak'] ?? 0;
      _loaded = true;
    });
  }

  // ─── Save + side-effects (level up, badges, streak celebration) ────────

  Future<void> _runSave({required bool moveToSavedStep}) async {
    if (_saving) return;
    _saving = true;
    HapticFeedback.selectionClick();

    await LogbookRepository.instance.addEntry(
      challengeId: widget.challenge.id,
      status: _status,
      aura: _totalAura,
      timestamp: DateTime.now(),
      feeling: _feeling,
      perception: _perception,
      notes: _notesController.text.trim(),
      durationSeconds: widget.durationSeconds,
      preAnxiety: _preAnxiety,
    );

    int? newLevel;
    if (!_isAborted) {
      newLevel = await ref
          .read(comfortZoneLevelProvider.notifier)
          .recordSuccessAndCheckLevelUp(
            widget.challenge,
            ref.read(activeLocaleProvider),
          );
      await applyStreakFreezesIfNeeded(ref);
    }

    if (newLevel != null && mounted) {
      SoundService.playSuccess(enabled: ref.read(soundEffectsEnabledProvider));
      if (!mounted) return;
      await context.goLevelUp(newLevel);
    }

    if (!_isAborted && mounted) {
      final stats = await LogbookRepository.instance.overviewStats();
      final storedBest = await SettingsRepository.instance
          .loadBestWeeklyStreak();
      final bestStreak = storedBest > (stats['weekStreak'] ?? 0)
          ? storedBest
          : (stats['weekStreak'] ?? 0);
      final currentLevel = ref.read(comfortZoneLevelProvider);
      final enrichedStats = {...stats, 'czlLevel': currentLevel};
      final earnedNow = BadgesLogic.computeEarned(enrichedStats, bestStreak);
      final seenBadges = await SettingsRepository.instance.loadSeenBadges();

      final newBadges = BadgesLogic.all
          .where((b) => earnedNow.contains(b.id) && !seenBadges.contains(b.id))
          .toList();

      if (newBadges.isNotEmpty) {
        await SettingsRepository.instance.saveSeenBadges({
          ...seenBadges,
          ...newBadges.map((b) => b.id),
        });
        await SettingsRepository.instance.appendUnlockedBadges(
          newBadges.map((b) => b.id),
        );
        for (final badge in newBadges) {
          if (!mounted) break;
          await context.goBadgeUnlocked(badge);
        }
      }
    }

    if (!_isAborted && mounted) {
      final currentWeekAura = await LogbookRepository.instance
          .currentWeekAura();
      if (currentWeekAura >= kWeeklyAuraThreshold) {
        final currentWeek = WeeklyStreakLogic.isoYearWeek(DateTime.now());
        final lastGoalWeek = await SettingsRepository.instance
            .loadLastGoalWeek();
        if (lastGoalWeek != currentWeek) {
          await SettingsRepository.instance.saveLastGoalWeek(currentWeek);
          final stats = await LogbookRepository.instance.overviewStats();
          final weekStreak = stats['weekStreak'] ?? 0;
          final prevBest = await SettingsRepository.instance
              .loadBestWeeklyStreak();
          if (weekStreak > prevBest) {
            await SettingsRepository.instance.saveBestWeeklyStreak(weekStreak);
          }
          final isMilestone = AppStatic.streakMilestones.contains(weekStreak);
          if (mounted) {
            await context.goStreakCelebration(weekStreak, isMilestone);
          }
        }
      }
    }

    refreshStatistics(ref);
    if (!mounted) return;

    // Warm-up chaining: a successful rung with more to go jumps straight to
    // the next challenge instead of popping or showing the Saved screen.
    final w = widget.warmup;
    if (!_isAborted && w != null && w.hasNext) {
      _goToNextWarmup(w);
      return; // this screen is being replaced — nothing more to do
    }

    if (moveToSavedStep) {
      setState(() => _stage = _Stage.saved);
    } else if (w != null) {
      // End of the warm-up run (or aborted mid-ladder): the chained `.go`
      // navigations left no home route to pop back to.
      context.goHome();
    } else {
      context.pop(widget.rewardFactor);
    }
    _saving = false;
  }

  void _goToNextWarmup(WarmupSession w) {
    context.goActiveChallenge(
      w.nextChallenge!,
      isGuided: widget.isGuided,
      warmup: w.next,
    );
  }

  // ─── Stepped navigation ────────────────────────────────────────────────

  void _startReflect() => setState(() {
    _navDir = 1;
    _stage = _Stage.reflect;
    _q = 0;
  });

  /// Advance from a reflect question (answered or skipped): next question,
  /// then the notes step.
  void _advance() => setState(() {
    _navDir = 1;
    if (_q < _questionCount - 1) {
      _q++;
    } else {
      _stage = _Stage.notes;
    }
  });

  void _back() => setState(() {
    _navDir = -1;
    if (_stage == _Stage.notes) {
      _stage = _Stage.reflect;
      _q = _questionCount - 1;
    } else if (_q > 0) {
      _q--;
    } else {
      _stage = _Stage.celebrate;
    }
  });

  void _popWithReward() {
    if (!mounted) return;
    // A warm-up run reset the stack via chained `.go`, so there's no route
    // to pop back to — return to the home shell instead.
    if (widget.warmup != null) {
      context.goHome();
    } else {
      context.pop(widget.rewardFactor);
    }
  }

  Future<void> _tryAgain() async {
    await LogbookRepository.instance.addEntry(
      challengeId: widget.challenge.id,
      status: _status,
      aura: 0,
      timestamp: DateTime.now(),
      feeling: _feeling,
      perception: _perception,
      notes: _notesController.text.trim(),
      durationSeconds: widget.durationSeconds,
      preAnxiety: _preAnxiety,
    );
    refreshStatistics(ref);
    if (!mounted) return;
    context.goActiveChallenge(
      widget.challenge,
      isGuided: widget.isGuided,
      warmup: widget.warmup,
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isAborted) {
      return Scaffold(
        body: _AbortedView(
          challenge: widget.challenge,
          onTryAgain: _tryAgain,
          onBackToHome: () => _runSave(moveToSavedStep: false),
        ),
      );
    }

    final l = S.of(context);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = SyntraSurface.of(context);

    // Celebrate — full-bleed reward, its own background, no chrome.
    if (_stage == _Stage.celebrate) {
      return Scaffold(
        body: _CelebrateView(
          totalAura: _totalAura,
          bonusAura: _bonusAura,
          quote: coachMessage(l, widget.challenge.id),
          weekStreak: _weekStreak,
          weekAura: _weekAura,
          loaded: _loaded,
          warmup: widget.warmup,
          czlLevel: _czlLevel,
          czlDisplayCompletions: _czlDisplayCompletions,
          czlNeeded: _czlNeeded,
          czlProgress: _czlProgress,
          onContinue: _startReflect,
          onSkip: () => _runSave(moveToSavedStep: false),
        ),
      );
    }

    // Saved — final confirmation.
    if (_stage == _Stage.saved) {
      return Scaffold(
        body: _SavedView(onBack: _popWithReward, warmup: widget.warmup),
      );
    }

    // Reflect / Notes — shared chrome (back · onboarding progress · counter)
    // stays mounted across steps so the progress pill animates between them.
    final isNotes = _stage == _Stage.notes;
    final stepIdx = isNotes ? _questionCount : _q;
    // Distinct per step so the AnimatedSwitcher slides on every change.
    final stepKey = isNotes ? 'notes' : 'reflect_$_q';

    // Pre-anxiety is stored 1..5 with 5 = "very nervous"; the scale shows
    // index 0 = "very nervous", so it is inverted on read/write.
    final questions = <_ReflectQ>[
      _ReflectQ(
        question: l.howNervousQuestion,
        left: l.veryNervous,
        right: l.notNervousAtAll,
        value: _preAnxiety == null ? null : 5 - _preAnxiety!,
        onPick: (idx) => setState(() => _preAnxiety = 5 - idx),
      ),
      _ReflectQ(
        question: l.howDidYouFeel,
        left: l.feelingScaleLow,
        right: l.feelingScaleHigh,
        value: _feeling,
        onPick: (idx) => setState(() => _feeling = idx),
      ),
      _ReflectQ(
        question: l.howPerceivedQuestion,
        left: l.perceivedScaleLow,
        right: l.perceivedScaleHigh,
        value: _perception,
        onPick: (idx) => setState(() => _perception = idx),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 6),
              child: Row(
                children: [
                  InkResponse(
                    onTap: _back,
                    radius: 22,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: s.bg2,
                        border: Border.all(
                          color: isDark ? s.bg4 : s.bg3,
                          width: 1,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 18,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OnbProgress(page: stepIdx, total: _total),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${stepIdx + 1}/$_total',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ClipRect(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    // Side-by-side horizontal slide (no in-place fade-stack):
                    // the new page enters from the nav direction while the
                    // old one leaves the opposite way.
                    final isIncoming = child.key == ValueKey(stepKey);
                    final dir = _navDir.toDouble();
                    final begin = Offset(isIncoming ? dir : -dir, 0);
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: begin,
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey(stepKey),
                    child: isNotes
                        ? _NotesPage(
                            controller: _notesController,
                            saving: _saving,
                            onSave: () => _runSave(moveToSavedStep: true),
                          )
                        : _ReflectPage(
                            key: ValueKey(_q),
                            q: questions[_q],
                            onAdvance: _advance,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reusable entrance ──────────────────────────────────────────────────────

/// One-shot fade + rise. Each instance animates on its *own* mount, so a child
/// that appears late (e.g. the streak card after stats finish loading) still
/// animates in instead of popping. Replaces the old post-frame `_mounted`
/// flag, which had already flipped to `true` by the time late children
/// appeared, leaving them un-animated.
class _EntranceFx extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final double slide;
  final Duration duration;

  /// When set, the child also scales from this value → 1.0 with a gentle
  /// easeOutBack overshoot, for a slow "pop in".
  final double? popFrom;

  const _EntranceFx({
    required this.child,
    this.delay = Duration.zero,
    this.slide = 0.12,
    this.duration = const Duration(milliseconds: 520),
    this.popFrom,
  });

  @override
  State<_EntranceFx> createState() => _EntranceFxState();
}

class _EntranceFxState extends State<_EntranceFx>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _c,
    curve: Curves.easeOut,
  );
  late final Animation<Offset> _offset = Tween<Offset>(
    begin: Offset(0, widget.slide),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
  late final Animation<double> _scale =
      Tween<double>(begin: widget.popFrom ?? 1.0, end: 1.0).animate(
        CurvedAnimation(parent: _c, curve: const Cubic(0.34, 1.36, 0.64, 1)),
      );

  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _c.forward();
    } else {
      _delayTimer = Timer(widget.delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = SlideTransition(position: _offset, child: widget.child);
    if (widget.popFrom != null) {
      child = ScaleTransition(scale: _scale, child: child);
    }
    return FadeTransition(opacity: _fade, child: child);
  }
}

// ─── Celebrate ───────────────────────────────────────────────────────────────

class _CelebrateView extends StatelessWidget {
  final int totalAura;
  final int bonusAura;
  final String quote;
  final int weekStreak;
  final int weekAura;
  final bool loaded;
  final WarmupSession? warmup;
  final int czlLevel;
  final int czlDisplayCompletions;
  final int czlNeeded;
  final double czlProgress;
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  const _CelebrateView({
    required this.totalAura,
    required this.bonusAura,
    required this.quote,
    required this.weekStreak,
    required this.weekAura,
    required this.loaded,
    required this.warmup,
    required this.czlLevel,
    required this.czlDisplayCompletions,
    required this.czlNeeded,
    required this.czlProgress,
    required this.onContinue,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = S.of(context);
    final topPad = MediaQuery.viewPaddingOf(context).top + 24;
    final bottomPad = MediaQuery.viewPaddingOf(context).bottom + 24;
    final scaffold = Theme.of(context).scaffoldBackgroundColor;
    final goalPct = (weekAura / kWeeklyAuraThreshold).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        // Pink halo from the top.
        gradient: RadialGradient(
          center: const Alignment(0, -1.2),
          radius: 1.2,
          colors: [
            cs.primary.withValues(alpha: isDark ? 0.22 : 0.18),
            scaffold,
          ],
          stops: const [0.0, 0.65],
        ),
      ),
      child: Stack(
        children: [
          const _ConfettiDots(),
          ListView(
            padding: EdgeInsets.fromLTRB(22, topPad, 22, bottomPad + 120),
            children: [
              // Each block pops in after the previous one, with a clear
              // pause between them (≈300 ms cadence).
              // Eyebrow
              _EntranceFx(
                child: Center(
                  child: Text(
                    l.celebrateEyebrow.toUpperCase(),
                    style: tt.labelSmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // +Aura hero
              _EntranceFx(
                delay: const Duration(milliseconds: 320),
                popFrom: 0.9,
                child: _AuraHero(value: totalAura, bonus: bonusAura),
              ),
              const SizedBox(height: 24),
              // Warm-up progress — only when this win is part of a ladder.
              if (warmup != null) ...[
                _EntranceFx(
                  delay: const Duration(milliseconds: 640),
                  popFrom: 0.9,
                  child: _WarmupCard(session: warmup!),
                ),
                const SizedBox(height: 24),
              ] else
                const SizedBox(height: 12),
              // Quote card
              _EntranceFx(
                delay: Duration(milliseconds: warmup != null ? 960 : 640),
                popFrom: 0.9,
                child: _QuoteCard(text: quote),
              ),
              const SizedBox(height: 24),
              // Streak + level progress — both mount once stats load.
              // When the weekly goal was already met before this win, the streak
              // card is less exciting news — show level progress first.
              if (loaded) ...[
                () {
                  final alreadyComplete =
                      (weekAura - totalAura) >= kWeeklyAuraThreshold;
                  final baseMs = warmup != null ? 1280 : 960;
                  // Fill starts ~300ms after the card's entrance animation begins.
                  // Both cards are mounted at the same time (when `loaded` flips),
                  // so fillDelay = card's entrance delay + 300ms.
                  final streakEnterMs = baseMs + (alreadyComplete ? 320 : 0);
                  final levelEnterMs = baseMs + (alreadyComplete ? 0 : 320);
                  final streakCard = _EntranceFx(
                    delay: Duration(milliseconds: streakEnterMs),
                    duration: const Duration(milliseconds: 720),
                    slide: 0.16,
                    popFrom: 0.9,
                    child: _StreakCard(
                      streak: weekStreak,
                      weekAura: weekAura,
                      pct: goalPct,
                      fillDelay: Duration(milliseconds: streakEnterMs + 300),
                    ),
                  );
                  final levelCard = _EntranceFx(
                    delay: Duration(milliseconds: levelEnterMs),
                    duration: const Duration(milliseconds: 720),
                    slide: 0.16,
                    popFrom: 0.9,
                    child: _LevelProgressCard(
                      level: czlLevel,
                      displayCompletions: czlDisplayCompletions,
                      needed: czlNeeded,
                      progress: czlProgress,
                      fillDelay: Duration(milliseconds: levelEnterMs + 300),
                    ),
                  );
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: alreadyComplete
                        ? [levelCard, const SizedBox(height: 16), streakCard]
                        : [streakCard, const SizedBox(height: 16), levelCard],
                  );
                }(),
              ],
            ],
          ),
          // Bottom pinned CTAs — sit on a solid scrim that fades up into the
          // gradient so they stay legible over whatever scrolls behind them.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(22, 40, 22, bottomPad),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    scaffold.withValues(alpha: 0.0),
                    scaffold.withValues(alpha: 0.85),
                    scaffold,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
              child: _EntranceFx(
                delay: const Duration(milliseconds: 340),
                // Reflection is always the guided path — in a warm-up the user
                // reflects on each rung before the next challenge starts. Skip
                // stays available; mid-ladder it's labelled as "continue".
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SyntraButton.icon(
                      onPressed: onContinue,
                      icon: Icons.arrow_forward_rounded,
                      label: Text(l.reflectOnThis),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: onSkip,
                      child: Text(
                        (warmup != null && warmup!.hasNext)
                            ? l.warmupContinue
                            : l.skipSaveTheWin,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : cs.onSurface,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact "Warm-up n/total" card — segmented ladder progress plus the next
/// rung's title, so the user sees the chain they're moving through.
class _WarmupCard extends StatelessWidget {
  final WarmupSession session;
  const _WarmupCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = SyntraSurface.of(context);
    final l = S.of(context);
    final fg = isDark ? Colors.white : cs.onSurface;
    final next = session.nextChallenge;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: s.bg2,
        border: Border.all(color: isDark ? s.bg4 : s.bg3),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_fire_department_rounded,
                  size: 19,
                  color: cs.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l.warmupProgress(session.position, session.total),
                  style: TextStyle(
                    fontFamily: 'Octarine',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: fg,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < session.total; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: i < session.position
                          ? cs.primary
                          : (isDark ? s.bg4 : s.bg3),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (next != null) ...[
            const SizedBox(height: 12),
            Text(
              l.warmupNextUp(next.title),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tt.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AuraHero extends StatefulWidget {
  final int value;
  final int bonus;
  const _AuraHero({required this.value, required this.bonus});

  @override
  State<_AuraHero> createState() => _AuraHeroState();
}

class _AuraHeroState extends State<_AuraHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 760),
  )..forward();
  late final Animation<double> _scale = Tween<double>(begin: 0.55, end: 1.0)
      .animate(
        CurvedAnimation(parent: _c, curve: const Cubic(0.34, 1.56, 0.64, 1)),
      );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = S.of(context);
    final valueColor = isDark ? Colors.white : cs.onSurface;
    return Column(
      children: [
        ScaleTransition(
          scale: _scale,
          child: TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: widget.value),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (_, v, _) => Text(
              '+$v',
              style: tt.displayLarge?.copyWith(
                fontFamily: 'Octarine',
                fontWeight: FontWeight.w700,
                fontSize: 92,
                height: 1.0,
                letterSpacing: -2,
                color: valueColor,
                shadows: [
                  Shadow(
                    color: cs.primary.withValues(alpha: 0.55),
                    blurRadius: 40,
                  ),
                  Shadow(
                    color: cs.primary.withValues(alpha: 0.25),
                    blurRadius: 80,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l.auraEarnedLabel.toUpperCase(),
          style: tt.labelLarge?.copyWith(
            fontFamily: 'Octarine',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: cs.primary,
            letterSpacing: 4,
          ),
        ),
        if (widget.bonus > 0) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: cs.tertiaryContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '+${widget.bonus} ${l.dailyBonus}',
              style: tt.labelMedium?.copyWith(
                color: cs.onTertiaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _QuoteCard extends StatelessWidget {
  final String text;
  const _QuoteCard({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.black.withValues(alpha: 0.04);
    final border = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.08);
    final fg = isDark ? Colors.white : cs.onSurface;
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.format_quote_rounded, size: 22, color: cs.primary),
          const SizedBox(height: 6),
          Text(
            text,
            style: tt.titleMedium?.copyWith(
              fontFamily: 'Octarine',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              height: 1.3,
              fontStyle: FontStyle.italic,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatefulWidget {
  final int streak;
  final int weekAura;
  final double pct;
  // Total delay from widget mount until the fill starts. Should be roughly
  // the parent _EntranceFx delay + ~300ms so the bar is already visible.
  final Duration fillDelay;

  const _StreakCard({
    required this.streak,
    required this.weekAura,
    required this.pct,
    this.fillDelay = Duration.zero,
  });

  @override
  State<_StreakCard> createState() => _StreakCardState();
}

class _StreakCardState extends State<_StreakCard> {
  bool _ready = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.fillDelay, () {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = S.of(context);
    const orange = BrandColors.orange;
    const orangeWarm = BrandColors.orangeWarm;
    final fg = isDark ? Colors.white : cs.onSurface;
    final target = _ready ? widget.pct.clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: orange.withValues(alpha: 0.10),
        border: Border.all(color: orange.withValues(alpha: 0.28), width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                size: 26,
                color: orange,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l.streakAliveN(widget.streak),
                      style: tt.titleSmall?.copyWith(
                        fontFamily: 'Octarine',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: fg,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l.weeklyGoalProgress(widget.weekAura, kWeeklyAuraThreshold),
                      style: tt.labelMedium?.copyWith(
                        color: orangeWarm,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: target),
                duration: const Duration(milliseconds: 1100),
                curve: const Cubic(.16, 1, .3, 1),
                builder: (_, v, _) => Text(
                  '${(v * 100).round()}%',
                  style: const TextStyle(
                    fontFamily: 'Octarine',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: target),
            duration: const Duration(milliseconds: 1100),
            curve: const Cubic(.16, 1, .3, 1),
            builder: (_, v, _) => ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: SizedBox(
                height: 6,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(color: orange.withValues(alpha: 0.15)),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: v,
                        heightFactor: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [orange, orangeWarm],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: orange.withValues(alpha: 0.55),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Level progress card (celebrate page) ────────────────────────────────────

class _LevelProgressCard extends StatefulWidget {
  final int level;
  final int displayCompletions;
  final int needed;
  final double progress; // 0..1, post-win
  final Duration fillDelay;

  const _LevelProgressCard({
    required this.level,
    required this.displayCompletions,
    required this.needed,
    required this.progress,
    this.fillDelay = Duration.zero,
  });

  @override
  State<_LevelProgressCard> createState() => _LevelProgressCardState();
}

class _LevelProgressCardState extends State<_LevelProgressCard> {
  bool _ready = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.fillDelay, () {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? Colors.white : Theme.of(context).colorScheme.onSurface;
    final maxL = ComfortZoneLogic.maxLevel;
    final isComplete = widget.progress >= 1.0;
    final currentGrad = ComfortZoneLogic.levelGradient(widget.level);
    final nextGrad = widget.level < maxL
        ? ComfortZoneLogic.levelGradient(widget.level + 1)
        : currentGrad;
    final c1 = isComplete ? nextGrad.colors[0] : currentGrad.colors[0];
    final c2 = isComplete ? nextGrad.colors[1] : currentGrad.colors[1];
    final target = _ready ? widget.progress.clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: c1.withValues(alpha: 0.10),
        border: Border.all(color: c1.withValues(alpha: 0.28), width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [c1, c2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  ComfortZoneLogic.levelIcons[widget.level.clamp(1, maxL)],
                  size: 19,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'LEVEL ${widget.level}',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: c1,
                      ),
                    ),
                    Text(
                      ComfortZoneLogic.levelNames[widget.level.clamp(1, maxL)],
                      style: tt.titleSmall?.copyWith(
                        fontFamily: 'Octarine',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: fg,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                widget.level >= maxL
                    ? 'MAX'
                    : '${widget.displayCompletions} / ${widget.needed}',
                style: TextStyle(
                  fontFamily: 'Octarine',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: c1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: target),
            duration: const Duration(milliseconds: 1100),
            curve: const Cubic(.16, 1, .3, 1),
            builder: (_, v, _) => ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: SizedBox(
                height: 6,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(color: c1.withValues(alpha: 0.15)),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: v,
                        heightFactor: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [c1, c2],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: c2.withValues(alpha: 0.55),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _ConfettiDots extends StatelessWidget {
  const _ConfettiDots();

  @override
  Widget build(BuildContext context) {
    // Pre-baked positions so layout doesn't reshuffle on rebuild.
    final dots = List<_Dot>.generate(18, (i) {
      return _Dot(
        leftPct: ((i * 137) % 100) / 100.0,
        topPct: (8 + ((i * 41) % 50)) / 100.0,
        size: 3.0 + (i % 4),
        delayMs: (i % 6) * 80,
      );
    });
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [for (final d in dots) _ConfettiDot(dot: d)],
      ),
    );
  }
}

class _Dot {
  final double leftPct;
  final double topPct;
  final double size;
  final int delayMs;
  const _Dot({
    required this.leftPct,
    required this.topPct,
    required this.size,
    required this.delayMs,
  });
}

class _ConfettiDot extends StatefulWidget {
  final _Dot dot;
  const _ConfettiDot({required this.dot});

  @override
  State<_ConfettiDot> createState() => _ConfettiDotState();
}

class _ConfettiDotState extends State<_ConfettiDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  Timer? _start;

  @override
  void initState() {
    super.initState();
    _start = Timer(Duration(milliseconds: widget.dot.delayMs), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _start?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final palette = [
      cs.primary,
      BrandColors.pinkBright,
      BrandColors.pinkSoft,
      BrandColors.orange,
    ];
    final color = palette[widget.dot.leftPct.hashCode % palette.length];
    // Place via Align (alignment is -1..1) instead of a Positioned inside a
    // LayoutBuilder — a Positioned is only valid as a *direct* Stack child,
    // and the old structure threw ParentDataWidget assertions every frame.
    final ax = (widget.dot.leftPct * 2) - 1;
    final ay = (widget.dot.topPct * 2) - 1;
    return Align(
      alignment: Alignment(ax.clamp(-1.0, 1.0), ay.clamp(-1.0, 1.0)),
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, _) {
          final v = _c.value;
          // Burst in over the first 35% (overshoot), then fade out and
          // drift down so the dots don't sit on screen forever.
          final pop = Curves.easeOutBack.transform((v / 0.35).clamp(0.0, 1.0));
          final tail = ((v - 0.35) / 0.65).clamp(0.0, 1.0);
          final opacity = ((1.0 - tail) * 0.9).clamp(0.0, 0.9);
          if (opacity <= 0.0) return const SizedBox.shrink();
          return Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(0, tail * 22),
              child: Transform.scale(
                scale: pop,
                child: Container(
                  width: widget.dot.size,
                  height: widget.dot.size,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.6),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Reflection boarding (real PageView, mirrors onboarding) ────────────────

/// One reflection question on a 0..4 scale.
class _ReflectQ {
  final String question;
  final String left;
  final String right;
  final int? value; // 0..4
  final ValueChanged<int> onPick;
  const _ReflectQ({
    required this.question,
    required this.left,
    required this.right,
    required this.value,
    required this.onPick,
  });
}

// ─── Reflect page (one question; auto-advances on pick) ─────────────────────

class _ReflectPage extends StatefulWidget {
  final _ReflectQ q;
  final VoidCallback onAdvance;
  const _ReflectPage({super.key, required this.q, required this.onAdvance});

  @override
  State<_ReflectPage> createState() => _ReflectPageState();
}

class _ReflectPageState extends State<_ReflectPage> {
  Timer? _advance;

  @override
  void dispose() {
    _advance?.cancel();
    super.dispose();
  }

  void _pick(int i) {
    HapticFeedback.selectionClick();
    widget.q.onPick(i);
    // Cancel any pending auto-advance so a fast double-tap can't double-page.
    // Hold a beat so the chosen answer visibly registers before the page
    // slides away.
    _advance?.cancel();
    _advance = Timer(const Duration(milliseconds: 550), () {
      if (mounted) widget.onAdvance();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = S.of(context);
    final fg = isDark ? Colors.white : cs.onSurface;
    final q = widget.q;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.reflectEyebrow.toUpperCase(),
                  style: tt.labelSmall?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  q.question,
                  style: tt.headlineMedium?.copyWith(
                    fontFamily: 'Octarine',
                    fontWeight: FontWeight.w700,
                    fontSize: 32,
                    height: 1.15,
                    letterSpacing: -0.4,
                    color: fg,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        q.left,
                        style: tt.labelMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        q.right,
                        style: tt.labelMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      for (int i = 0; i < 5; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: _StopPill(
                              index: i,
                              selected: q.value == i,
                              onTap: () => _pick(i),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 22,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: Text(
                        _anchorPreview(q.value, q.left, q.right, l),
                        key: ValueKey(q.value),
                        textAlign: TextAlign.center,
                        style: tt.titleMedium?.copyWith(
                          fontFamily: 'Octarine',
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: fg,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: widget.onAdvance,
              child: Text(
                l.skipThisQuestion,
                style: TextStyle(color: cs.outline, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _anchorPreview(int? v, String left, String right, S l) {
    if (v == null) return '';
    return switch (v) {
      0 => left,
      1 => l.mostlyX(left.toLowerCase()),
      2 => l.somewhereInTheMiddle,
      3 => l.mostlyX(right.toLowerCase()),
      _ => right,
    };
  }
}

class _StopPill extends StatelessWidget {
  final int index;
  final bool selected;
  final VoidCallback onTap;

  const _StopPill({
    required this.index,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = SyntraSurface.of(context);
    final inactiveBg = s.bg2;
    final inactiveFg = isDark ? SyntraSurface.light.muted : cs.onSurfaceVariant;
    // Cool → warm tone per stop, blended toward the brand pink at the top.
    const tones = [
      Color(0xFF5C5C5C),
      Color(0xFF7A7A7A),
      Color(0xFF9C9C9C),
      BrandColors.pinkBright,
      BrandColors.pink,
    ];
    final tone = tones[index];
    // Scale the whole pill from its centre (the old Matrix4 transform scaled
    // from the top-left origin, so a selected pill jumped diagonally instead
    // of growing in place — that was the visible "buggy" pop).
    return AnimatedScale(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      scale: selected ? 1.04 : 1.0,
      alignment: Alignment.center,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [tone, cs.primary],
                )
              : null,
          color: selected ? null : inactiveBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.45),
                    blurRadius: 28,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Center(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontFamily: 'Octarine',
                  fontWeight: FontWeight.w700,
                  fontSize: selected ? 24 : 18,
                  color: selected ? Colors.white : inactiveFg,
                ),
                child: Text('${index + 1}'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Notes page ────────────────────────────────────────────────────────────

class _NotesPage extends StatefulWidget {
  final TextEditingController controller;
  final bool saving;
  final VoidCallback onSave;

  const _NotesPage({
    required this.controller,
    required this.saving,
    required this.onSave,
  });

  @override
  State<_NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<_NotesPage> {
  bool _expanded = false;
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _expanded = widget.controller.text.trim().isNotEmpty;
    widget.controller.addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    _focus.dispose();
    super.dispose();
  }

  void _expand() {
    setState(() => _expanded = true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = S.of(context);
    final fg = isDark ? Colors.white : cs.onSurface;
    final s = SyntraSurface.of(context);
    final cardBg = s.bg1;
    final dashedBorder = isDark ? s.bg4 : s.bg3;
    final chipBg = cardBg;
    final chipBorder = isDark ? s.bg4 : s.bg3;

    final quickPrompts = [
      l.notePromptSmiled,
      l.notePromptEasier,
      l.notePromptPowerful,
      l.notePromptAwkward,
    ];

    final notesLen = widget.controller.text.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.notesEyebrow.toUpperCase(),
                  style: tt.labelSmall?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l.notesQuestion,
                  style: tt.headlineMedium?.copyWith(
                    fontFamily: 'Octarine',
                    fontWeight: FontWeight.w700,
                    fontSize: 32,
                    height: 1.15,
                    letterSpacing: -0.4,
                    color: fg,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l.notesHelper,
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
              children: [
                if (!_expanded)
                  InkWell(
                    onTap: _expand,
                    borderRadius: BorderRadius.circular(16),
                    child: DottedBorderBox(
                      color: dashedBorder,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_note_rounded,
                              size: 20,
                              color: cs.outline,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              l.addANote,
                              style: tt.bodyMedium?.copyWith(
                                color: cs.outline,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      border: Border.all(color: cs.primary, width: 1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextField(
                          controller: widget.controller,
                          focusNode: _focus,
                          maxLines: 6,
                          minLines: 4,
                          maxLength: 500,
                          buildCounter:
                              (
                                _, {
                                required currentLength,
                                required isFocused,
                                maxLength,
                              }) => null,
                          decoration: InputDecoration(
                            hintText: l.notePromptSmiled,
                            hintStyle: tt.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: tt.bodyLarge?.copyWith(
                            color: fg,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                        Text(
                          '$notesLen/500',
                          style: tt.labelSmall?.copyWith(
                            color: cs.outline,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final p in quickPrompts)
                      InkWell(
                        onTap: () {
                          widget.controller.text = p;
                          _expand();
                        },
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: chipBg,
                            border: Border.all(color: chipBorder, width: 1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            p,
                            style: tt.labelMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
            child: SyntraButton.icon(
              onPressed: widget.saving ? null : widget.onSave,
              icon: Icons.check_rounded,
              label: Text(l.saveReflection),
            ),
          ),
        ],
      ),
    );
  }
}

class DottedBorderBox extends StatelessWidget {
  final Color color;
  final Widget child;

  const DottedBorderBox({super.key, required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBoxPainter(color: color, radius: 16),
      child: child,
    );
  }
}

class _DashedBoxPainter extends CustomPainter {
  final Color color;
  final double radius;
  _DashedBoxPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const dash = 5.0;
    const gap = 4.0;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final segment = metric.extractPath(
          distance,
          (distance + dash).clamp(0, metric.length).toDouble(),
        );
        canvas.drawPath(segment, paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBoxPainter old) =>
      old.color != color || old.radius != radius;
}

// ─── Saved confirmation ────────────────────────────────────────────────────

class _SavedView extends StatelessWidget {
  final VoidCallback onBack;
  final WarmupSession? warmup;
  const _SavedView({required this.onBack, this.warmup});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = S.of(context);
    final fg = isDark ? Colors.white : cs.onSurface;
    const green = BrandColors.green;
    // Intermediate rungs auto-chain, so reaching Saved inside a warm-up means
    // the whole ladder is done.
    final w = warmup;
    final isWarmupComplete = w != null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _EntranceFx(
              slide: 0.0,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: green.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, size: 40, color: green),
              ),
            ),
            const SizedBox(height: 20),
            _EntranceFx(
              delay: const Duration(milliseconds: 90),
              child: Text(
                isWarmupComplete ? l.warmupCompleteTitle : l.savedTitle,
                textAlign: TextAlign.center,
                style: tt.headlineSmall?.copyWith(
                  fontFamily: 'Octarine',
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                  color: fg,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                isWarmupComplete ? l.warmupCompleteBody : l.savedBody,
                textAlign: TextAlign.center,
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
            if (isWarmupComplete) ...[
              const SizedBox(height: 24),
              _EntranceFx(
                delay: const Duration(milliseconds: 160),
                child: _WarmupCard(session: w),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: SyntraButton.icon(
                onPressed: onBack,
                icon: Icons.home_rounded,
                label: Text(l.backToHome),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Aborted page (kindness, two CTAs) ─────────────────────────────────────

class _AbortedView extends StatelessWidget {
  final Challenge challenge;
  final VoidCallback onTryAgain;
  final VoidCallback onBackToHome;
  const _AbortedView({
    required this.challenge,
    required this.onTryAgain,
    required this.onBackToHome,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = S.of(context);
    final fg = isDark ? Colors.white : cs.onSurface;
    final topPad = MediaQuery.viewPaddingOf(context).top + 32;
    final bottomPad = MediaQuery.viewPaddingOf(context).bottom + 24;

    return Padding(
      padding: EdgeInsets.fromLTRB(22, topPad, 22, bottomPad),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.self_improvement_rounded,
              size: 48,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l.tooBad,
            textAlign: TextAlign.center,
            style: tt.headlineSmall?.copyWith(
              fontFamily: 'Octarine',
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              l.failureCopy,
              textAlign: TextAlign.center,
              style: tt.bodyLarge?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: SyntraButton.icon(
                  onPressed: onBackToHome,
                  color: cs.error,
                  icon: Icons.home_rounded,
                  label: Text(l.backToHome),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SyntraButton.icon(
                  onPressed: onTryAgain,
                  color: cs.primary,
                  icon: Icons.refresh_rounded,
                  label: Text(l.retryChallenge),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
