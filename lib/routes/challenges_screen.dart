import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:syntra/data/settings_repository.dart';
import 'package:syntra/challenge.dart';
import 'package:syntra/generated/l10n.dart';
import 'package:syntra/logic/weekly_streak_logic.dart';
import 'package:syntra/providers/challenge_providers.dart';
import 'package:syntra/providers/scroll_providers.dart';
import 'package:syntra/providers/settings_providers.dart';
import 'package:syntra/providers/shop_providers.dart';
import 'package:syntra/providers/statistics_providers.dart';
import 'package:syntra/router.dart';
import 'package:syntra/services/sound_service.dart';

import 'challenges/challenge_list.dart';
import 'challenges/challenges_header.dart';
import 'challenges/filter_bar.dart';

class ChallengesScreen extends ConsumerStatefulWidget {
  const ChallengesScreen({super.key});

  @override
  ConsumerState<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends ConsumerState<ChallengesScreen>
    with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();
  int _displayWeeklyXp = 0;
  int _displayAura = 0;
  bool _initialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onChallengeFinished() async {
    refreshStatistics(ref);
    final allowed = await SettingsRepository.instance.checkAndMarkReviewRequest();
    if (!allowed) return;
    final review = InAppReview.instance;
    if (await review.isAvailable()) review.requestReview();
  }

  Future<void> _startChallenge(BuildContext context, Challenge challenge) async {
    SoundService.playDing(enabled: ref.read(soundEffectsEnabledProvider));
    final result = await context.pushPriming(challenge);
    if (result != null) {
      _onChallengeFinished();
      // Force a rebuild on return. The ref.listener fired while we were
      // covered by the pushed route (isVisible=false → skipped), and when the
      // provider value doesn't change again no rebuild triggers the build()
      // fallback — without this setState, _displayAura stays at the
      // pre-challenge value and the counter never animates.
      if (mounted) setState(() {});
    }
  }

  void _onGiveMeOne(BuildContext context) {
    final list = ref.read(filteredChallengesProvider).value;
    if (list == null || list.isEmpty) {
      _showNoChallengesSnackBar(context);
      return;
    }

    final filters = ref.read(challengeFiltersProvider);
    final completedIds = ref.read(completedChallengeIdsProvider).valueOrNull ?? {};
    final candidates = list
        .where((c) => !filters.showOnlyNotDone || !completedIds.contains(c.id))
        .toList();

    if (candidates.isEmpty) {
      _showNoChallengesSnackBar(context);
      return;
    }

    _startChallenge(context, candidates[Random().nextInt(candidates.length)]);
  }

  void _showNoChallengesSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(S.of(context).noChallengesFound),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    ref.listen(challengesScrollToTopProvider, (prev, next) {
      if (next > 0 && _scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });

    final statsAsync = ref.watch(overviewStatsProvider);
    final s = statsAsync.valueOrNull;
    final weekStreak = s?['weekStreak'] ?? 0;
    final displayStreak = weekStreak > 0 ? weekStreak : (s?['pendingWeekStreak'] ?? 0);
    final availableXp = ref.watch(availableAuraProvider) ?? 0;
    final freezes = ref.watch(streakFreezesProvider);
    final currentWeekXp = ref.watch(currentWeekXpProvider).valueOrNull ?? 0;

    if (!_initialized) {
      _displayWeeklyXp = currentWeekXp;
      _displayAura = availableXp;
      _initialized = true;
    }

    ref.listen(currentWeekXpProvider, (prev, next) {
      final nextVal = next.valueOrNull ?? 0;
      if (nextVal > _displayWeeklyXp) {
        if (ModalRoute.of(context)?.isCurrent ?? false) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) setState(() => _displayWeeklyXp = nextVal);
          });
        }
      } else if (nextVal < _displayWeeklyXp) {
        setState(() => _displayWeeklyXp = nextVal);
      }
    });

    ref.listen<int?>(availableAuraProvider, (prev, next) {
      final nextVal = next ?? 0;
      if (nextVal > _displayAura) {
        if (ModalRoute.of(context)?.isCurrent ?? false) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && _displayAura < nextVal) setState(() => _displayAura = nextVal);
          });
        }
      } else if (nextVal < _displayAura) {
        setState(() => _displayAura = nextVal);
      }
    });

    // Catch pending increases when returning from a pushed route.
    final isCurrent = ModalRoute.of(context)?.isCurrent ?? false;
    if (isCurrent && (_displayAura < availableXp || _displayWeeklyXp < currentWeekXp)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          if (_displayAura < availableXp) setState(() => _displayAura = availableXp);
          if (_displayWeeklyXp < currentWeekXp) setState(() => _displayWeeklyXp = currentWeekXp);
        });
      });
    }

    final progress = (_displayWeeklyXp / kWeeklyXpThreshold).clamp(0.0, 1.0);
    final isWeekComplete = progress >= 1.0;
    final filterCount = ref.watch(challengeFiltersProvider).activeFilterCount;
    final double headerCollapseRange = isWeekComplete ? 56.0 : 84.0;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        physics: HeaderSnapPhysics(
          snapRange: headerCollapseRange,
          parent: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        ),
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: ChallengesHeaderDelegate(
              topPad: MediaQuery.paddingOf(context).top,
              isWeekComplete: isWeekComplete,
              displayStreak: displayStreak,
              availableXp: _displayAura,
              freezes: freezes,
              currentWeekXp: _displayWeeklyXp,
              progress: progress,
              filterCount: filterCount,
              onGiveMeOne: () => _onGiveMeOne(context),
              onFilterTap: () => ChallengesFilterBar.openSheet(context),
            ),
          ),
          ChallengeListSliver(onStart: _startChallenge),
          const SliverFillRemaining(hasScrollBody: false, child: SizedBox.shrink()),
          SliverToBoxAdapter(child: SizedBox(height: headerCollapseRange)),
        ],
      ),
    );
  }
}
