/// Categorizes the prediction-reality gap so the UI can pick a matching message.
enum PredictionGapTone {
  veryCalm,
  calm,
  accurate,
  nervous,
  tough,
}

/// Aggregate stats for prediction-reality gap insights.
class ChallengeGapInsight {
  final int attempts;
  final double averageGap;
  final int calmThanPredicted;

  const ChallengeGapInsight({
    required this.attempts,
    required this.averageGap,
    required this.calmThanPredicted,
  });

  /// Categorize the gap into a tone for UI rendering.
  PredictionGapTone get tone {
    if (averageGap > 1.5) return PredictionGapTone.veryCalm;
    if (averageGap > 0.5) return PredictionGapTone.calm;
    if (averageGap.abs() < 0.5) return PredictionGapTone.accurate;
    if (averageGap < -1.5) return PredictionGapTone.tough;
    return PredictionGapTone.nervous;
  }
}

/// Logic for computing prediction-reality gap insights.
///
/// pre_anxiety is on a 1-5 scale where 5 = very nervous.
/// feeling is on a 0-4 scale where 4 = very satisfied/calm (inverted from anxiety).
/// We convert feeling to an anxiety-equivalent (5 - feeling) so both are on the
/// same 1-5 scale where higher = more nervous.
/// Positive gap = user felt calmer than predicted (confidence builder).
/// Negative gap = user felt more nervous than predicted (reality check).
class PredictionGapLogic {
  /// Minimum number of attempts required to show meaningful insights.
  static const int minAttempts = 3;

  /// Compute average gap and confidence metric for a challenge.
  /// Returns null if fewer than [minAttempts] valid entries exist.
  static ChallengeGapInsight? compute(List<Map<String, dynamic>> entries) {
    final validEntries = entries
        .where((e) =>
            e['pre_anxiety'] is int &&
            e['feeling'] is int)
        .toList();

    if (validEntries.length < minAttempts) return null;

    final gaps = validEntries.map((e) {
      final preAnxiety = (e['pre_anxiety'] as int).clamp(1, 5);
      // Convert feeling (0-4, high=calm) to anxiety scale (1-5, high=nervous).
      final actualAnxiety = 5 - (e['feeling'] as int).clamp(0, 4);
      return preAnxiety - actualAnxiety;
    }).toList();

    return ChallengeGapInsight(
      attempts: validEntries.length,
      averageGap: gaps.reduce((a, b) => a + b) / gaps.length,
      calmThanPredicted: gaps.where((g) => g > 0).length,
    );
  }
}
