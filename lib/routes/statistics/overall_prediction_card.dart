import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../generated/l10n.dart';
import '../../providers/prediction_gap_providers.dart';
import '../../theme/app_spacing.dart';
import '../../theme/brand_colors.dart';
import 'profile_section.dart';

/// "Prediction vs Reality" — the most insightful chart on the screen.
///
/// Replaces the old text card with a bespoke viz:
///   • Hero stat: `easier / total` in big pink gradient + plain-English line
///   • Dot grid: one dot per attempt (pink = easier, gray = same, orange = harder)
///   • Legend with counts
///   • Takeaway box: "Your brain says 'this will be awful' — and is wrong X% of the time."
class OverallPredictionCard extends ConsumerWidget {
  const OverallPredictionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(perAttemptPredictionDirectionsProvider);
    final l = S.of(context);

    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (attempts) {
        if (attempts.isEmpty) return const SizedBox.shrink();

        final easier =
            attempts.where((d) => d == PredictionDirection.easier).length;
        final same =
            attempts.where((d) => d == PredictionDirection.same).length;
        final harder =
            attempts.where((d) => d == PredictionDirection.harder).length;
        final total = attempts.length;
        final pct = total > 0 ? ((easier / total) * 100).round() : 0;

        return ProfileSection(
          title: l.predictionVsRealityTitle,
          right: l.predictionAttemptsCount(total),
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

class PredictionHeroStat extends StatelessWidget {
  final int easier;
  final int total;
  const PredictionHeroStat({super.key, required this.easier, required this.total});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emphasisColor = isDark ? Colors.white : cs.onSurface;
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 10),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (rect) => LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cs.primary.withValues(alpha: 0.85),
                cs.primary,
              ],
            ).createShader(rect),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: tt.displayLarge?.copyWith(
                  fontFamily: 'Octarine',
                  fontWeight: FontWeight.w700,
                  fontSize: 48,
                  height: 1,
                  letterSpacing: -1.5,
                  color: Colors.white,
                ),
                children: [
                  TextSpan(text: '$easier'),
                  TextSpan(
                    text: ' / $total',
                    style: TextStyle(
                      fontSize: 28,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.4,
              ),
              children: [
                TextSpan(text: S.of(context).predictionEasierBefore),
                TextSpan(
                  text: ' ${S.of(context).predictionEasierKey} ',
                  style: TextStyle(
                    color: emphasisColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: S.of(context).predictionEasierAfter),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PredictionDotGrid extends StatelessWidget {
  final List<PredictionDirection> attempts;
  const PredictionDotGrid({super.key, required this.attempts});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final s = SyntraSurface.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: s.bg3),
          bottom: BorderSide(color: s.bg3),
        ),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: attempts.length,
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 10,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          childAspectRatio: 1,
        ),
        itemBuilder: (_, i) {
          final d = attempts[i];
          Color dot;
          List<BoxShadow>? glow;
          switch (d) {
            case PredictionDirection.easier:
              dot = cs.primary;
              glow = [
                BoxShadow(
                    color: cs.primary.withValues(alpha: 0.55),
                    blurRadius: 6),
              ];
            case PredictionDirection.harder:
              dot = BrandColors.orange;
              glow = null;
            case PredictionDirection.same:
              dot = s.bg5;
              glow = null;
          }
          return Container(
            decoration: BoxDecoration(
              color: dot,
              shape: BoxShape.circle,
              boxShadow: glow,
            ),
          );
        },
      ),
    );
  }
}

class PredictionLegend extends StatelessWidget {
  final int easier;
  final int same;
  final int harder;
  const PredictionLegend({
    super.key,
    required this.easier,
    required this.same,
    required this.harder,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final s = SyntraSurface.of(context);
    final l = S.of(context);

    Widget item(Color color, String label, int count) => Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '$label · $count',
                  overflow: TextOverflow.ellipsis,
                  style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            ],
          ),
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        item(cs.primary, l.predictionEasier, easier),
        item(s.bg5, l.predictionSame, same),
        item(BrandColors.orange, l.predictionHarder, harder),
      ],
    );
  }
}

class PredictionTakeawayBox extends StatelessWidget {
  final int pct;
  const PredictionTakeawayBox({super.key, required this.pct});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = SyntraSurface.of(context);
    final valueColor = isDark ? Colors.white : cs.onSurface;
    final l = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: s.bg3, height: 1, thickness: 1),
        const SizedBox(height: 16),
        Text(
          l.predictionTakeawayBefore.toUpperCase(),
          style: tt.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '"${l.predictionTakeawayQuote}"',
          style: TextStyle(
            fontFamily: 'Octarine',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            height: 1.25,
            letterSpacing: -0.3,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          l.predictionTakeawayMiddle,
          style: tt.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        Text(
          '$pct%',
          style: TextStyle(
            fontFamily: 'Octarine',
            fontWeight: FontWeight.w700,
            fontSize: 38,
            letterSpacing: -1,
            height: 1.1,
            color: cs.primary,
          ),
        ),
        Text(
          l.predictionTakeawayAfter,
          style: tt.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
