import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syntra/routes/streak_celebration_screen.dart';

import '../challenge.dart';
import '../data/logbook_repository.dart';
import '../data/settings_repository.dart';
import '../generated/l10n.dart';
import '../logic/comfort_zone_logic.dart';
import '../providers/settings_providers.dart';
import '../providers/statistics_providers.dart' show refreshStatistics;
import 'active_challenge_screen.dart';
import '../services/sound_service.dart';
import '../services/vibration_service.dart';
import '../static.dart';
import '../theme/app_spacing.dart';
import '../widgets/syntra_button.dart';
import '../widgets/syntra_progress_bar.dart';

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
  final ValueChanged<double>? onDone;
  final bool isDailyMission;

  const ChallengeDoneScreen({
    super.key,
    required this.challenge,
    this.rewardFactor = 1.0,
    this.durationSeconds,
    this.onDone,
    this.isDailyMission = false,
  });

  @override
  ConsumerState<ChallengeDoneScreen> createState() =>
      _ChallengeDoneScreenState();
}

class _ChallengeDoneScreenState extends ConsumerState<ChallengeDoneScreen> {
  final _surveyKey = GlobalKey<_SurveyWidgetState>();

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
    if (!_isAborted) unawaited(VibrationService.success());
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
      appBar: AppBar(
        title:
            Text(_isAborted ? l.challengeAborted : l.challengeCompleted),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // ── Scrollable content ─────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                gapXl,
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

                  SizedBox(height: gapXl),

                  // ── XP chip — number counts up from 0 on appear ────────
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

                  // ── XP progress bar ────────────────────────────────────
                  if (!_isAborted) ...[
                    SizedBox(height: gapMd),
                    SyntraXpBar(
                      value: widget.rewardFactor.clamp(0.0, 1.0),
                      minHeight: 8,
                      duration: const Duration(milliseconds: 2300),
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
                  _SurveyWidget(key: _surveyKey, isAborted: _isAborted),
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

    final navigator = Navigator.of(context);

    await LogbookRepository.instance.addEntry(
      challengeId: widget.challenge.id,
      status: _status,
      earned: _totalXp,
      timestamp: DateTime.now(),
      feeling: feeling,
      perception: perception,
      notes: notes,
      durationSeconds: widget.durationSeconds,
    );

    int? newLevel;
    if (!_isAborted) {
      final lang = ref.read(activeLocaleProvider);
      newLevel = await ref
          .read(comfortZoneLevelProvider.notifier)
          .recordSuccessAndCheckLevelUp(widget.challenge, lang);
    }

    if (newLevel != null && context.mounted) {
      SoundService.playSuccess(enabled: ref.read(soundEffectsEnabledProvider));
      await VibrationService.milestone();
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _LevelUpDialog(newLevel: newLevel!),
      );
    }

    if (!_isAborted && context.mounted) {
      final stats = await LogbookRepository.instance.overviewStats();
      final streak = stats['streak'] ?? 0;

      // Update personal best.
      final prevBest = await SettingsRepository.instance.loadAllTimeMaxStreak();
      if (streak > prevBest) {
        await SettingsRepository.instance.saveAllTimeMaxStreak(streak);
      }

      final lastCelebrated =
          await SettingsRepository.instance.loadLastCelebratedStreak();

      if (streak > lastCelebrated) {
        await SettingsRepository.instance.saveLastCelebratedStreak(streak);
        final isMilestone = AppStatic.streakMilestones.contains(streak);
        if (context.mounted) {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => StreakCelebrationScreen(
                streak: streak,
                isMilestone: isMilestone,
              ),
            ),
          );
        }
      }
    }

    refreshStatistics(ref);
    if (widget.onDone != null) widget.onDone!(widget.rewardFactor);
    navigator.pop(widget.rewardFactor);
  }

  Future<void> _onTryAgain(BuildContext context) async {
    // Log the abort entry before navigating away.
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
    );

    refreshStatistics(ref);

    if (!context.mounted) return;
    // Replace this done-screen with a fresh active challenge, keeping the
    // back-stack so popUntil(isFirst) in ActiveChallengeScreen still works.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ActiveChallengeScreen(challenge: widget.challenge),
      ),
    );
  }
}

// ─── Level-up dialog ──────────────────────────────────────────────────────────

class _LevelUpDialog extends StatelessWidget {
  final int newLevel;
  const _LevelUpDialog({required this.newLevel});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);

    final name = newLevel <= ComfortZoneLogic.maxLevel
        ? ComfortZoneLogic.levelNames[newLevel]
        : ComfortZoneLogic.levelNames[ComfortZoneLogic.maxLevel];
    final desc = newLevel <= ComfortZoneLogic.maxLevel
        ? ComfortZoneLogic.levelDescriptions[newLevel]
        : ComfortZoneLogic.levelDescriptions[ComfortZoneLogic.maxLevel];

    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius * 2)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: cs.primaryContainer,
              child: Icon(Icons.trending_up_rounded,
                  size: 40, color: cs.onPrimaryContainer),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l.levelUnlocked(newLevel),
              style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              name,
              style: tt.titleMedium
                  ?.copyWith(color: cs.primary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              desc,
              style: tt.bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            SyntraButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l.letsGoButton),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Survey widget ────────────────────────────────────────────────────────────

class _SurveyWidget extends StatefulWidget {
  final bool isAborted;
  const _SurveyWidget({super.key, required this.isAborted});

  @override
  State<_SurveyWidget> createState() => _SurveyWidgetState();
}

class _SurveyWidgetState extends State<_SurveyWidget> {
  int _feeling = 2;
  int _perceived = 2;
  bool _submitted = false;
  final TextEditingController _notesController = TextEditingController();

  // Semantic sentiment scale — intentionally not theme colors.
  static const _smileys = [
    Icons.sentiment_very_dissatisfied,
    Icons.sentiment_dissatisfied,
    Icons.sentiment_neutral,
    Icons.sentiment_satisfied,
    Icons.sentiment_very_satisfied,
  ];
  static const _smileyColors = [
    Colors.red, Colors.orange, Colors.amber, Colors.lightGreen, Colors.green,
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);

    if (_submitted) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: Text(
          l.thankYouFeedback,
          style: tt.bodyLarge?.copyWith(color: cs.primary),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.howDidYouFeel,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (i) => IconButton(
            icon: Icon(
              _smileys[i],
              color: _feeling == i ? _smileyColors[i] : cs.outlineVariant,
              size: 36,
            ),
            onPressed: () => setState(() => _feeling = i),
          )),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(l.howPerceivedQuestion,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (i) => IconButton(
            icon: Icon(
              _smileys[i],
              color: _perceived == i ? _smileyColors[i] : cs.outlineVariant,
              size: 36,
            ),
            onPressed: () => setState(() => _perceived = i),
          )),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(l.notes,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _notesController,
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: widget.isAborted
                ? l.failureNotesHint
                : l.notesPlaceholder,
          ),
        ),
      ],
    );
  }

  bool get submitted => _submitted;
  int get feeling => _feeling;
  int get perceived => _perceived;
  String get notes => _notesController.text;
  void submit() => setState(() => _submitted = true);
}
