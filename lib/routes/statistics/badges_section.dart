import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../generated/l10n.dart';
import '../../logic/badges_logic.dart';
import '../../logic/comfort_zone_logic.dart';
import '../../providers/settings_providers.dart';
import '../../providers/statistics_providers.dart';
import '../../theme/app_spacing.dart';
class BadgesSection extends ConsumerWidget {
  const BadgesSection({super.key});

  String _badgeLabel(S l, String id) {
    final lvl = _levelFromId(id);
    if (lvl != null) return 'Level $lvl: ${ComfortZoneLogic.levelNames[lvl]}';
    return switch (id) {
      'first_step' => l.badgeFirstStep,
      'ten_challenges' => l.badgeTenChallenges,
      'fifty_challenges' => l.badgeFiftyChallenges,
      'three_week_streak' => l.badgeThreeWeekStreak,
      'seven_week_streak' => l.badgeSevenWeekStreak,
      'century_aura' => l.badgeCenturyAura,
      'five_hundred_aura' => l.badgeFiveHundredAura,
      'brave_minutes' => l.badgeBraveMinutes,
      String other => other,
    };
  }

  String _badgeDesc(S l, String id) {
    final lvl = _levelFromId(id);
    if (lvl != null) return 'Reach Level $lvl in your Comfort Zone journey.';
    return switch (id) {
      'first_step' => l.badgeFirstStepDesc,
      'ten_challenges' => l.badgeTenChallengesDesc,
      'fifty_challenges' => l.badgeFiftyChallengesDesc,
      'three_week_streak' => l.badgeThreeWeekStreakDesc,
      'seven_week_streak' => l.badgeSevenWeekStreakDesc,
      'century_aura' => l.badgeCenturyAuraDesc,
      'five_hundred_aura' => l.badgeFiveHundredAuraDesc,
      'brave_minutes' => l.badgeBraveMinutesDesc,
      String() => '',
    };
  }

  int? _levelFromId(String id) {
    if (!id.startsWith('level_')) return null;
    return int.tryParse(id.substring(6));
  }

  void _showBadgeInfo(
    BuildContext context,
    S l,
    AppBadge badge,
    bool isEarned,
  ) {
    final name = _badgeLabel(l, badge.id);
    final desc = _badgeDesc(l, badge.id);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        final tt = Theme.of(ctx).textTheme;
        return Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Handle ─────────────────────────────────────────────────
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
  
                // ── Badge icon ─────────────────────────────────────────────
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isEarned
                        ? badge.color.withValues(alpha: 0.15)
                        : cs.surfaceContainerHighest,
                    border: isEarned
                        ? Border.all(color: badge.color, width: 2.5)
                        : null,
                  ),
                  child: Icon(
                    badge.icon,
                    size: 44,
                    color: isEarned ? badge.color : cs.outlineVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
  
                // ── Name ───────────────────────────────────────────────────
                Text(
                  name,
                  style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
  
                // ── Status chip ────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 4),
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
                const SizedBox(height: AppSpacing.md),
  
                // ── Description ────────────────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Text(
                    desc,
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(overviewStatsProvider);
    final currentLevel = ref.watch(comfortZoneLevelProvider);
    final l = S.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return statsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, st) => const SizedBox.shrink(),
      data: (stats) {
        final enrichedStats = {...stats, 'czlLevel': currentLevel};
        final earned = BadgesLogic.computeEarned(enrichedStats, enrichedStats['weekStreak'] ?? 0);
        return Card(
          margin: EdgeInsets.zero,
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
