import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../generated/l10n.dart';
import '../../logic/badges_logic.dart';
import '../../providers/statistics_providers.dart';
import '../../theme/app_spacing.dart';

class BadgesSection extends ConsumerWidget {
  const BadgesSection();

  String _badgeLabel(S l, String id) => switch (id) {
        'first_step' => l.badgeFirstStep,
        'ten_challenges' => l.badgeTenChallenges,
        'fifty_challenges' => l.badgeFiftyChallenges,
        'three_day_streak' => l.badgeThreeDayStreak,
        'seven_day_streak' => l.badgeSevenDayStreak,
        'century_xp' => l.badgeCenturyXp,
        'five_hundred_xp' => l.badgeFiveHundredXp,
        'brave_minutes' => l.badgeBraveMinutes,
        _ => id,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(overviewStatsProvider);
    final l = S.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return statsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (stats) {
        final earned = BadgesLogic.computeEarned(stats, stats['streak'] ?? 0);
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.workspace_premium_rounded, color: cs.primary, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      l.badgesTitle,
                      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Text(
                      '${earned.length}/${BadgesLogic.all.length}',
                      style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: BadgesLogic.all.map((badge) {
                    final isEarned = earned.contains(badge.id);
                    return Tooltip(
                      message: _badgeLabel(l, badge.id),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isEarned
                              ? badge.color.withValues(alpha: 0.15)
                              : cs.surfaceContainerHighest,
                          shape: BoxShape.circle,
                          border: isEarned
                              ? Border.all(color: badge.color, width: 2)
                              : null,
                        ),
                        child: Icon(
                          badge.icon,
                          color: isEarned ? badge.color : cs.outlineVariant,
                          size: 26,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (earned.length < BadgesLogic.all.length) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l.badgesLocked,
                    style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
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
