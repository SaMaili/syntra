import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../generated/l10n.dart';
import '../../logic/badges_logic.dart';
import '../../providers/badges_providers.dart';
import '../../providers/settings_providers.dart';
import '../../providers/statistics_providers.dart';
import '../../router.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/badge_widgets.dart';

class BadgesSection extends ConsumerWidget {
  const BadgesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(overviewStatsProvider);
    final currentLevel = ref.watch(comfortZoneLevelProvider);
    final orderAsync = ref.watch(unlockedBadgesOrderProvider);
    final l = S.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return statsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (stats) {
        final enrichedStats = {...stats, 'czlLevel': currentLevel};
        final earned = BadgesLogic.computeEarned(
            enrichedStats, enrichedStats['weekStreak'] ?? 0);
        final order = orderAsync.maybeWhen(
          data: (v) => v,
          orElse: () => const <String>[],
        );
        final sorted = BadgesLogic.sortByDisplay(
          earned: earned,
          unlockedOrder: order,
        );

        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.workspace_premium_rounded,
                        color: cs.primary, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      l.badgesTitle,
                      style: tt.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Text(
                      '${earned.length}/${BadgesLogic.all.length}',
                      style: tt.labelSmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          const tileSize = 52.0;
                          const gap = AppSpacing.sm;
                          final available = constraints.maxWidth;
                          final count = ((available + gap) / (tileSize + gap))
                              .floor()
                              .clamp(1, sorted.length);
                          final visible = sorted.take(count).toList();
                          return Row(
                            children: [
                              for (int i = 0; i < visible.length; i++) ...[
                                BadgeTile(
                                  badge: visible[i],
                                  isEarned: earned.contains(visible[i].id),
                                  onTap: () => showBadgeInfoSheet(
                                      context, visible[i], earned.contains(visible[i].id)),
                                ),
                                if (i < visible.length - 1)
                                  const SizedBox(width: gap),
                              ],
                            ],
                          );
                        },
                      ),
                    ),
                    _SeeAllChevron(onTap: () => context.goAllBadges()),
                  ],
                ),
                if (earned.length < BadgesLogic.all.length) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l.badgesLocked,
                    style:
                        tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SeeAllChevron extends StatelessWidget {
  final VoidCallback onTap;
  const _SeeAllChevron({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = S.of(context);
    return Semantics(
      button: true,
      label: l.seeAllBadges,
      child: IconButton(
        onPressed: onTap,
        tooltip: l.seeAllBadges,
        icon: Icon(Icons.chevron_right_rounded, color: cs.primary, size: 32),
      ),
    );
  }
}
