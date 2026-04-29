import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/logbook_repository.dart';
import '../logic/prediction_gap_logic.dart';
import 'statistics_providers.dart';

/// Per-challenge prediction-reality gap insights.
/// Returns null if fewer than [PredictionGapLogic.minAttempts] valid entries.
final predictionGapProvider =
    FutureProvider.family<ChallengeGapInsight?, String>(
  (ref, challengeId) async {
    ref.watch(statisticsRefreshProvider);
    final entries =
        await LogbookRepository.instance.entriesForChallenge(challengeId);
    return PredictionGapLogic.compute(entries);
  },
);

/// Aggregate prediction-reality gap insight across all challenges.
/// Returns null if fewer than [PredictionGapLogic.minAttempts] valid entries.
final overallPredictionGapProvider = FutureProvider<ChallengeGapInsight?>(
  (ref) async {
    ref.watch(statisticsRefreshProvider);
    final entries = await LogbookRepository.instance.allEntriesForGap();
    return PredictionGapLogic.compute(entries);
  },
);
