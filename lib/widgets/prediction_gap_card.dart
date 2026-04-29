import 'package:flutter/material.dart';

import '../generated/l10n.dart';
import '../logic/prediction_gap_logic.dart';
import '../theme/app_spacing.dart';
import 'detail_card.dart';

/// Displays prediction-reality gap insights for a challenge.
class PredictionGapCard extends StatelessWidget {
  final ChallengeGapInsight insight;

  const PredictionGapCard({super.key, required this.insight});

  String _toneMessage(S l) {
    switch (insight.tone) {
      case PredictionGapTone.veryCalm:
        return l.predictionInsightVeryCalm;
      case PredictionGapTone.calm:
        return l.predictionInsightCalm;
      case PredictionGapTone.accurate:
        return l.predictionInsightAccurate;
      case PredictionGapTone.tough:
        return l.predictionInsightTough;
      case PredictionGapTone.nervous:
        return l.predictionInsightNervous;
    }
  }

  String _formatGap(double gap) =>
      gap >= 0 ? '+${gap.toStringAsFixed(1)}' : gap.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);

    return DetailCard(
      icon: Icons.psychology_rounded,
      title: l.predictionVsRealityTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _toneMessage(l),
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _StatBlock(label: l.predictionAttempts, value: '${insight.attempts}'),
              const SizedBox(width: AppSpacing.lg),
              _StatBlock(label: l.predictionAvgGap, value: _formatGap(insight.averageGap)),
              const SizedBox(width: AppSpacing.lg),
              _StatBlock(
                label: l.predictionCalmer,
                value: '${insight.calmThanPredicted}/${insight.attempts}',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l.predictionVsRealitySubtitle,
            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String label;
  final String value;

  const _StatBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: tt.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.primary,
          ),
        ),
        Text(
          label,
          style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}
