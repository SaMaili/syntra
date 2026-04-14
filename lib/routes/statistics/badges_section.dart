import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../generated/l10n.dart';
import '../../logic/badges_logic.dart';
import '../../providers/statistics_providers.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/syntra_button.dart';

class BadgesSection extends ConsumerWidget {
  const BadgesSection();

  String _badgeLabel(S l, String id) => switch (id) {
        'first_step' => l.badgeFirstStep,
        'ten_challenges' => l.badgeTenChallenges,
        'fifty_challenges' => l.badgeFiftyChallenges,
        'three_week_streak' => l.badgeThreeWeekStreak,
        'seven_week_streak' => l.badgeSevenWeekStreak,
        'century_xp' => l.badgeCenturyXp,
        'five_hundred_xp' => l.badgeFiveHundredXp,
        'brave_minutes' => l.badgeBraveMinutes,
        String other => other,
      };

  String _badgeDesc(S l, String id) => switch (id) {
        'first_step' => l.badgeFirstStepDesc,
        'ten_challenges' => l.badgeTenChallengesDesc,
        'fifty_challenges' => l.badgeFiftyChallengesDesc,
        'three_week_streak' => l.badgeThreeWeekStreakDesc,
        'seven_week_streak' => l.badgeSevenWeekStreakDesc,
        'century_xp' => l.badgeCenturyXpDesc,
        'five_hundred_xp' => l.badgeFiveHundredXpDesc,
        'brave_minutes' => l.badgeBraveMinutesDesc,
        String() => '',
      };

  void _showBadgeInfo(
    BuildContext context,
    S l,
    AppBadge badge,
    bool isEarned,
  ) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final name = _badgeLabel(l, badge.id);
    final desc = _badgeDesc(l, badge.id);

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius * 2),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Badge icon ────────────────────────────────────────────────
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isEarned
                    ? badge.color.withValues(alpha: 0.15)
                    : cs.surfaceContainerHighest,
                border: isEarned
                    ? Border.all(color: badge.color, width: 2)
                    : null,
              ),
              child: Icon(
                badge.icon,
                size: 36,
                color: isEarned ? badge.color : cs.outlineVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Name ──────────────────────────────────────────────────────
            Text(
              name,
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),

            // ── Status chip ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: isEarned
                    ? badge.color.withValues(alpha: 0.12)
                    : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
              ),
              child: Text(
                isEarned ? '✓ ${l.badgesTitle}' : l.badgeLocked,
                style: tt.labelSmall?.copyWith(
                  color: isEarned ? badge.color : cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── Description ───────────────────────────────────────────────
            Text(
              desc,
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SyntraButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.letsGoButton),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(overviewStatsProvider);
    final l = S.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return statsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, st) => const SizedBox.shrink(),
      data: (stats) {
        final earned = BadgesLogic.computeEarned(stats, stats['weekStreak'] ?? 0);
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
                    return GestureDetector(
                      onTap: () => _showBadgeInfo(context, l, badge, isEarned),
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
