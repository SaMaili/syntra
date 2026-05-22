import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/logbook_repository.dart';
import '../logic/prediction_gap_logic.dart';
import 'statistics_providers.dart';

/// Per-challenge prediction-reality gap insights.
/// Returns null if fewer than [PredictionGapLogic.minAttempts] valid entries.
final predictionGapProvider =
    FutureProvider.family<ChallengeGapInsight?, String>((
      ref,
      challengeId,
    ) async {
      ref.watch(statisticsRefreshProvider);
      final entries = await LogbookRepository.instance.entriesForChallenge(
        challengeId,
      );
      return PredictionGapLogic.compute(entries);
    });

/// Aggregate prediction-reality gap insight across all challenges.
/// Returns null if fewer than [PredictionGapLogic.minAttempts] valid entries.
final overallPredictionGapProvider = FutureProvider<ChallengeGapInsight?>((
  ref,
) async {
  ref.watch(statisticsRefreshProvider);
  final entries = await LogbookRepository.instance.allEntriesForGap();
  return PredictionGapLogic.compute(entries);
});

/// Direction of the prediction-reality gap for a single attempt.
enum PredictionDirection { easier, same, harder }

/// How many recent attempts the prediction dot-grid shows at most.
const int kPredictionGridMaxAttempts = 50;

/// Per-attempt classifications, oldest → newest (matches the dot-grid layout
/// on the Profile redesign), capped to the most recent
/// [kPredictionGridMaxAttempts]. Positive gap = easier (felt calmer than
/// predicted), zero = same, negative = harder.
final perAttemptPredictionDirectionsProvider =
    FutureProvider<List<PredictionDirection>>((ref) async {
      ref.watch(statisticsRefreshProvider);
      final entries = await LogbookRepository.instance.allEntriesForGap();
      final all = entries
          .where((e) => e['pre_anxiety'] is int && e['feeling'] is int)
          .map((e) {
            final preAnxiety = (e['pre_anxiety'] as int).clamp(1, 5);
            final actualAnxiety = 5 - (e['feeling'] as int).clamp(0, 4);
            final gap = preAnxiety - actualAnxiety;
            if (gap > 0) return PredictionDirection.easier;
            if (gap < 0) return PredictionDirection.harder;
            return PredictionDirection.same;
          })
          .toList();
      // Keep only the last N (entries are already oldest → newest).
      if (all.length > kPredictionGridMaxAttempts) {
        return all.sublist(all.length - kPredictionGridMaxAttempts);
      }
      return all;
    });

/// Per-attempt prediction directions for a single challenge, oldest → newest.
final perAttemptDirectionsForChallengeProvider =
    FutureProvider.family<List<PredictionDirection>, String>((
  ref,
  challengeId,
) async {
  ref.watch(statisticsRefreshProvider);
  final entries =
      await LogbookRepository.instance.entriesForChallenge(challengeId);
  final all = entries
      .where((e) => e['pre_anxiety'] is int && e['feeling'] is int)
      .map((e) {
        final preAnxiety = (e['pre_anxiety'] as int).clamp(1, 5);
        final actualAnxiety = 5 - (e['feeling'] as int).clamp(0, 4);
        final gap = preAnxiety - actualAnxiety;
        if (gap > 0) return PredictionDirection.easier;
        if (gap < 0) return PredictionDirection.harder;
        return PredictionDirection.same;
      })
      .toList();
  if (all.length > kPredictionGridMaxAttempts) {
    return all.sublist(all.length - kPredictionGridMaxAttempts);
  }
  return all;
});
