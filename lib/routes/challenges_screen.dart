import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syntra/challenge.dart';
import 'package:syntra/generated/l10n.dart';
import 'package:syntra/providers/challenge_providers.dart';
import 'package:syntra/providers/settings_providers.dart';
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
  @override
  bool get wantKeepAlive => true;

  void _onChallengeFinished() => refreshStatistics(ref);

  Future<void> _startChallenge(BuildContext context, Challenge challenge) async {
    SoundService.playDing(enabled: ref.read(soundEffectsEnabledProvider));
    final result = await context.pushPriming(challenge);
    if (result != null) _onChallengeFinished();
  }

  void _onGiveMeOne(BuildContext context) {
    final allAsync = ref.read(filteredChallengesProvider);
    final list = allAsync.value;
    if (list == null || list.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).noChallengesFound),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final filters = ref.read(challengeFiltersProvider);
    final completedIds =
        ref.read(completedChallengeIdsProvider).valueOrNull ?? {};

    final candidates = list
        .where((c) =>
            !filters.showOnlyNotDone || !completedIds.contains(c.id))
        .toList();

    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).noChallengesFound),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final pick = candidates[Random().nextInt(candidates.length)];
    _startChallenge(context, pick);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ChallengesHeader(),
            ChallengesFilterBar(onGiveMeOne: () => _onGiveMeOne(context)),
            Expanded(
              child: ChallengeList(onStart: _startChallenge),
            ),
          ],
        ),
      ),
    );
  }
}
