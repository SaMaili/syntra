import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/prediction_gap_providers.dart';
import '../../widgets/prediction_gap_card.dart';

/// Aggregate prediction-reality gap insight across all challenges.
/// Renders nothing until the user has enough data to compute a meaningful gap.
class OverallPredictionCard extends ConsumerWidget {
  const OverallPredictionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(overallPredictionGapProvider).when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (insight) {
        if (insight == null) return const SizedBox.shrink();
        return PredictionGapCard(insight: insight);
      },
    );
  }
}
