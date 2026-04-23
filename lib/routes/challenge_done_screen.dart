import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../challenge.dart';
import '../data/logbook_repository.dart';
import '../data/settings_repository.dart';
import '../logic/weekly_streak_logic.dart';
import '../generated/l10n.dart';
import '../providers/settings_providers.dart';
import '../providers/statistics_providers.dart' show refreshStatistics;
import '../logic/badges_logic.dart';
import '../router.dart';
import '../services/sound_service.dart';
import '../services/vibration_service.dart';
import '../static.dart';
import '../theme/app_spacing.dart';
import '../widgets/syntra_button.dart';
import '../widgets/syntra_progress_bar.dart';
import '../widgets/syntra_blur_app_bar.dart';
import 'challenge_done/survey_widget.dart';

int socialProofCount(String challengeId) {
  var hash = 0;
  for (final c in challengeId.codeUnits) {
    hash = (hash * 31 + c) & 0x7FFFFFFF;
  }
  return 800 + (hash % 3700);
}

String coachMessage(S l, String challengeId) {
  final messages = [
    l.coachMsg1, l.coachMsg2, l.coachMsg3, l.coachMsg4,
    l.coachMsg5, l.coachMsg6, l.coachMsg7,
  ];
  var hash = 0;
  for (final c in challengeId.codeUnits) {
    hash = (hash * 17 + c) & 0x7FFFFFFF;
  }
  return messages[hash % messages.length];
}

class ChallengeDoneScreen extends ConsumerStatefulWidget {
  final Challenge challenge;
  final double rewardFactor;
  final int? durationSeconds;
  final bool isDailyMission;
  final int? preAnxiety;

  const ChallengeDoneScreen({
    super.key,
    required this.challenge,
    this.rewardFactor = 1.0,
    this.durationSeconds,
    this.isDailyMission = false,
    this.preAnxiety,
  });

  @override
  ConsumerState<ChallengeDoneScreen> createState() =>
      _ChallengeDoneScreenState();
}

class _ChallengeDoneScreenState extends ConsumerState<ChallengeDoneScreen> {
  final _surveyKey = GlobalKey<SurveyWidgetState>();
  int _oldWeeklyXp = 0;
  int _displayWeeklyXp = 0;
  bool _xpLoaded = false;

  bool get _isAborted => widget.rewardFactor < 0;
  int get _earnedXp =>
      _isAborted ? 0 : (widget.challenge.xp * widget.rewardFactor).round();
  int get _bonusXp =>
      widget.isDailyMission && !_isAborted ? (_earnedXp * 0.1).round() : 0;
  int get _totalXp => _earnedXp + _bonusXp;
  String get _status => _isAborted ? 'tried' : 'success';

  @override
  void initState() {
    super.initState();
    if (_isAborted) {
      unawaited(VibrationService.abort());
    } else {
      unawaited(VibrationService.success());
    }
    _loadXp();
  }

  Future<void> _loadXp() async {
    final latestXp = await LogbookRepository.instance.currentWeekXp();
    if (mounted) {
      setState(() {
        _oldWeeklyXp = latestXp;
        _displayWeeklyXp = latestXp;
        _xpLoaded = true;
      });
      // Sequence:
      // 1. Wait for screen fade-in (400ms)
      // 2. Start Aura Point (+X) counting up (begins at 400ms)
      // 3. Start Weekly Bar growing (begins at 1000ms)
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _displayWeeklyXp = _oldWeeklyXp + _totalXp;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);

    // Proportional spacing — tighter on small screens.
    final screenH = MediaQuery.sizeOf(context).height;
    final gapXl = (screenH * 0.04).clamp(16.0, 32.0);
    final gapMd = (screenH * 0.02).clamp(8.0, 16.0);
    final iconSize = (screenH * 0.13).clamp(72.0, 100.0);
    final iconInner = iconSize * 0.56;

    // Keyboard fix: when keyboard is open the scaffold already moves the body
    // up, so we only need a small pad instead of the full safe-area gap.
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final bottomPad = keyboardVisible
        ? AppSpacing.sm
        : AppSpacing.lg + MediaQuery.viewPaddingOf(context).bottom;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: SyntraBlurAppBar(
        title: Text(_isAborted ? l.challengeAborted : l.challengeCompleted),
        leading: const SizedBox.shrink(), // hide back button
      ),
      body: Column(
        children: [
          // ── Scrollable content ─────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                SyntraBlurAppBar.topPadding(context) + gapMd,
                AppSpacing.lg,
                gapMd,
              ),
              child: Column(
                children: [
                  // ── Hero icon ──────────────────────────────────────────
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: _isAborted
                          ? cs.surfaceContainerHighest
                          : cs.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isAborted
                          ? Icons.self_improvement_rounded
                          : Icons.emoji_events_rounded,
                      size: iconInner,
                      color: _isAborted
                          ? cs.onSurfaceVariant
                          : cs.onPrimaryContainer,
                    ),
                  ),
                  SizedBox(height: gapXl),

                  // ── Headline ───────────────────────────────────────────
                  Text(
                    _isAborted ? l.tooBad : l.congratulations,
                    style: tt.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: gapMd),

                  // ── Failure copy / coach message ───────────────────────
                  if (_isAborted)
                    Text(
                      l.failureCopy,
                      style: tt.bodyLarge?.copyWith(
                          color: cs.onSurfaceVariant, height: 1.5),
                      textAlign: TextAlign.center,
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.cardRadius),
                      ),
                      child: Text(
                        '"${coachMessage(l, widget.challenge.id)}"',
                        style: tt.bodyLarge?.copyWith(
                          color: cs.onSurface,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // ── Prediction-reality gap ────────────────────────────
                  if (!_isAborted && widget.preAnxiety != null) ...[
                    SizedBox(height: gapMd),
                    _PredictionRealityCard(preAnxiety: widget.preAnxiety!),
                  ],

                  SizedBox(height: gapXl),

                  // ── Aura chip — number counts up from 0 on appear ──────
                  if (_xpLoaded)
                    TweenAnimationBuilder<int>(
                      tween: IntTween(begin: 0, end: _totalXp),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                      builder: (_, value, child) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: _isAborted
                            ? cs.surfaceContainerHighest
                            : cs.primaryContainer,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.chipRadius),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.emoji_events_rounded,
                            color: _isAborted
                                ? cs.onSurfaceVariant
                                : cs.onPrimaryContainer,
                            size: 24,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            _isAborted
                                ? '+0 ${l.auraPoints}'
                                : '+$value ${l.auraPoints}',
                            style: tt.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _isAborted
                                  ? cs.onSurfaceVariant
                                  : cs.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Aura progress bar ──────────────────────────────────
                  if (!_isAborted && _xpLoaded) ...[
                    SizedBox(height: gapMd),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l.weeklyGoalTitle,
                          style: tt.labelMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TweenAnimationBuilder<int>(
                          tween: IntTween(begin: _oldWeeklyXp, end: _displayWeeklyXp),
                          duration: const Duration(milliseconds: 1500),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) => Text(
                            '$value / $kWeeklyXpThreshold',
                            style: tt.labelMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SyntraXpBar(
                      value: (_displayWeeklyXp / kWeeklyXpThreshold).clamp(0.0, 1.0),
                      initialValue: (_oldWeeklyXp / kWeeklyXpThreshold).clamp(0.0, 1.0),
                      minHeight: 12,
                      duration: const Duration(milliseconds: 1500),
                    ),
                  ],

                  // ── Daily bonus badge ──────────────────────────────────
                  if (_bonusXp > 0) ...[
                    const SizedBox(height: AppSpacing.sm),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutBack,
                      builder: (_, t, child) => Opacity(
                        opacity: t.clamp(0.0, 1.0),
                        child: Transform.scale(scale: t, child: child),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: cs.tertiaryContainer,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.chipRadius),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded,
                                size: 14,
                                color: cs.onTertiaryContainer),
                            const SizedBox(width: 4),
                            Text(
                              '+$_bonusXp ${l.dailyBonus}',
                              style: tt.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.onTertiaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: gapMd),

                  // ── Survey ─────────────────────────────────────────────
                  SurveyWidget(key: _surveyKey, isAborted: _isAborted),
                  SizedBox(height: gapMd),
                ],
              ),
            ),
          ),

          // ── Pinned bottom button(s) ────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              bottomPad,
            ),
            child: _isAborted
                ? Row(
                    children: [
                      Expanded(
                        child: SyntraButton.icon(
                          onPressed: () => _onBackToHome(context),
                          color: cs.error,
                          icon: Icons.home_rounded,
                          label: Text(l.backToHome),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: SyntraButton.icon(
                          onPressed: () => _onTryAgain(context),
                          color: cs.primary,
                          icon: Icons.refresh_rounded,
                          label: Text(l.retryChallenge),
                        ),
                      ),
                    ],
                  )
                : SyntraButton.icon(
                    onPressed: () => _onBackToHome(context),
                    color: cs.primary,
                    icon: Icons.home_rounded,
                    label: Text(l.backToHome),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _onBackToHome(BuildContext context) async {
    final surveyState = _surveyKey.currentState;
    if (surveyState != null && !surveyState.submitted) surveyState.submit();
    final feeling = surveyState?.feeling;
    final perception = surveyState?.perceived;
    final notes = surveyState?.notes;

    await LogbookRepository.instance.addEntry(
      challengeId: widget.challenge.id,
      status: _status,
      earned: _totalXp,
      timestamp: DateTime.now(),
      feeling: feeling,
      perception: perception,
      notes: notes,
      durationSeconds: widget.durationSeconds,
      preAnxiety: widget.preAnxiety,
    );

    int? newLevel;
    if (!_isAborted) {
      newLevel = await ref
          .read(comfortZoneLevelProvider.notifier)
          .recordSuccessAndCheckLevelUp(widget.challenge, ref.read(activeLocaleProvider));
    }

    if (newLevel != null && context.mounted) {
      SoundService.playSuccess(enabled: ref.read(soundEffectsEnabledProvider));
      if (!context.mounted) return;
      await context.goLevelUp(newLevel);
    }

    // ── Badge celebration ─────────────────────────────────────────────────────
    if (!_isAborted && context.mounted) {
      final stats = await LogbookRepository.instance.overviewStats();
      final storedBest =
          await SettingsRepository.instance.loadBestWeeklyStreak();
      // Use whichever is higher: the stored best or the current streak
      // (the stored value is updated later in the streak block below).
      final bestStreak =
          storedBest > (stats['weekStreak'] ?? 0) ? storedBest : (stats['weekStreak'] ?? 0);
      final currentLevel = ref.read(comfortZoneLevelProvider);
      final enrichedStats = {...stats, 'czlLevel': currentLevel};
      final earnedNow = BadgesLogic.computeEarned(enrichedStats, bestStreak);
      final seenBadges = await SettingsRepository.instance.loadSeenBadges();

      final newBadges = BadgesLogic.all
          .where((b) => earnedNow.contains(b.id) && !seenBadges.contains(b.id))
          .toList();

      if (newBadges.isNotEmpty) {
        await SettingsRepository.instance
            .saveSeenBadges({...seenBadges, ...newBadges.map((b) => b.id)});
        for (final badge in newBadges) {
          if (!context.mounted) break;
          await context.goBadgeUnlocked(badge);
        }
      }
    }

    if (!_isAborted && context.mounted) {
      // ── Weekly XP goal celebration ────────────────────────────────────
      // Fire the flame animation as soon as the user reaches the weekly
      // XP threshold — not at the week boundary. Uses an ISO year-week key
      // so the celebration fires at most once per week.
      final currentWeekXp =
          await LogbookRepository.instance.currentWeekXp();
      if (currentWeekXp >= kWeeklyXpThreshold) {
        final currentWeek =
            WeeklyStreakLogic.isoYearWeek(DateTime.now());
        final lastGoalWeek =
            await SettingsRepository.instance.loadLastGoalWeek();

        if (lastGoalWeek != currentWeek) {
          await SettingsRepository.instance.saveLastGoalWeek(currentWeek);

          // weekStreak already includes the current week (since threshold is met).
          final stats = await LogbookRepository.instance.overviewStats();
          final weekStreak = stats['weekStreak'] ?? 0;

          final prevBest =
              await SettingsRepository.instance.loadBestWeeklyStreak();
          if (weekStreak > prevBest) {
            await SettingsRepository.instance.saveBestWeeklyStreak(weekStreak);
          }

          final isMilestone = AppStatic.streakMilestones.contains(weekStreak);
          if (context.mounted) {
            await context.goStreakCelebration(weekStreak, isMilestone);
          }
        }
      }
    }

    refreshStatistics(ref);
    if (context.mounted) context.pop(widget.rewardFactor);
  }

  Future<void> _onTryAgain(BuildContext context) async {
    final surveyState = _surveyKey.currentState;
    if (surveyState != null && !surveyState.submitted) surveyState.submit();
    final feeling = surveyState?.feeling;
    final perception = surveyState?.perceived;
    final notes = surveyState?.notes;

    await LogbookRepository.instance.addEntry(
      challengeId: widget.challenge.id,
      status: _status,
      earned: 0,
      timestamp: DateTime.now(),
      feeling: feeling,
      perception: perception,
      notes: notes,
      durationSeconds: widget.durationSeconds,
      preAnxiety: widget.preAnxiety,
    );

    refreshStatistics(ref);

    if (!context.mounted) return;
    // Use go() to replace the entire stack so neither this screen nor the
    // previous ActiveChallengeScreen remain in the back-stack.
    context.goPriming(
      widget.challenge,
      isDailyMission: widget.isDailyMission,
    );
  }
}

// ─── Prediction-reality gap card ──────────────────────────────────────────────

class _PredictionRealityCard extends StatelessWidget {
  // 1–5 nervousness rated before the challenge
  final int preAnxiety;

  const _PredictionRealityCard({required this.preAnxiety});

  static const _icons = [
    Icons.sentiment_very_satisfied,
    Icons.sentiment_satisfied,
    Icons.sentiment_neutral,
    Icons.sentiment_dissatisfied,
    Icons.sentiment_very_dissatisfied,
  ];
  static const _colors = [
    Colors.green,
    Colors.lightGreen,
    Colors.amber,
    Colors.orange,
    Colors.red,
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);

    // preAnxiety is 1–5 (1=calm, 5=very nervous); index into icon list is reversed
    final iconIndex = (preAnxiety - 1).clamp(0, 4);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Row(
        children: [
          Icon(
            _icons[iconIndex],
            color: _colors[iconIndex],
            size: 28,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              l.predictionRealityInsight,
              style: tt.bodySmall?.copyWith(
                color: cs.onSecondaryContainer,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
