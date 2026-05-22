import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../generated/l10n.dart';
import '../../providers/statistics_providers.dart';
import '../../theme/app_spacing.dart';
import '../../theme/brand_colors.dart';

// ─── Weekly Aura chart ────────────────────────────────────────────────────────

class WeeklyXpChart extends ConsumerWidget {
  const WeeklyXpChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(weeklyAuraProvider);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).auraEarnedThisWeek,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 160,
              child: async.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
                data: (aura) => AuraBarChart(aura: aura),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuraBarChart extends StatelessWidget {
  final List<int> aura;
  const AuraBarChart({super.key, required this.aura});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    final days = [l.mon, l.tue, l.wed, l.thu, l.fri, l.sat, l.sun];
    final tt = Theme.of(context).textTheme;
    final restColor = SyntraSurface.of(context).bg3;

    final maxVal = aura.fold(0, (a, b) => a > b ? a : b);
    final maxY = maxVal == 0 ? 100.0 : maxVal * 1.2;

    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (int i = 0; i < aura.length; i++) ...[
                if (i > 0) const SizedBox(width: 4),
                Expanded(
                  child: FractionallySizedBox(
                    heightFactor: (aura[i] / maxY).clamp(0.04, 1.0),
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: aura[i] > 0
                            ? const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: BrandColors.auraWeekGradient,
                              )
                            : null,
                        color: aura[i] > 0 ? null : restColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            for (int i = 0; i < days.length; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              Expanded(
                child: Text(
                  days[i],
                  textAlign: TextAlign.center,
                  style: tt.labelSmall,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
