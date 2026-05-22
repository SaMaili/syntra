import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../generated/l10n.dart';
import '../providers/prediction_gap_providers.dart';
import '../theme/app_spacing.dart';
import '../routes/statistics/overall_prediction_card.dart';
import 'detail_card.dart';

/// Rich prediction-vs-reality card for the challenge detail sheet.
/// Uses the same dot-grid / hero-stat / legend / takeaway style as the
/// profile's OverallPredictionCard.
class PredictionGapCard extends ConsumerWidget {
  final String challengeId;

  const PredictionGapCard({super.key, required this.challengeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(perAttemptDirectionsForChallengeProvider(challengeId));

    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (attempts) {
        if (attempts.length < 3) return const SizedBox.shrink();

        final easier =
            attempts.where((d) => d == PredictionDirection.easier).length;
        final same =
            attempts.where((d) => d == PredictionDirection.same).length;
        final harder =
            attempts.where((d) => d == PredictionDirection.harder).length;
        final total = attempts.length;
        final pct = ((easier / total) * 100).round();

        return DetailCard(
          icon: Icons.psychology_rounded,
          title: S.of(context).predictionVsRealityTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PredictionHeroStat(easier: easier, total: total),
              const SizedBox(height: AppSpacing.md),
              PredictionDotGrid(attempts: attempts),
              const SizedBox(height: AppSpacing.md),
              PredictionLegend(easier: easier, same: same, harder: harder),
              const SizedBox(height: AppSpacing.md),
              PredictionTakeawayBox(pct: pct),
            ],
          ),
        );
      },
    );
  }
}
