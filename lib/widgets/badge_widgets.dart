import 'package:flutter/material.dart';

import '../generated/l10n.dart';
import '../logic/badges_logic.dart';
import '../logic/comfort_zone_logic.dart';
import '../theme/app_spacing.dart';

String badgeLabel(S l, String id) {
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

String badgeDesc(S l, String id) {
  final lvl = _levelFromId(id);
  if (lvl != null) return l.badgeLevelDesc(lvl);
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

class BadgeTile extends StatelessWidget {
  final AppBadge badge;
  final bool isEarned;
  final double size;
  final VoidCallback? onTap;

  const BadgeTile({
    super.key,
    required this.badge,
    required this.isEarned,
    this.size = 52,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
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
          size: size * 0.5,
        ),
      ),
    );
  }
}

void showBadgeInfoSheet(
  BuildContext context,
  AppBadge badge,
  bool isEarned,
) {
  final l = S.of(context);
  final name = badgeLabel(l, badge.id);
  final desc = badgeDesc(l, badge.id);

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
              Text(
                name,
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
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
                  isEarned ? '✓ ${l.badgeOpted}' : l.badgeLocked,
                  style: tt.labelSmall?.copyWith(
                    color: isEarned ? badge.color : cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
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
