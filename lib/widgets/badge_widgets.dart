import 'package:flutter/material.dart';

import '../generated/l10n.dart';
import '../logic/badges_logic.dart';
import '../logic/comfort_zone_logic.dart';
import '../theme/brand_colors.dart';
import 'syntra_sheet.dart';

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

/// Circular badge medallion in the brand language: a radial tint glow + thin
/// accent ring for earned badges (1:1 with the `OnbDisc` treatment), a flat
/// muted surface for locked ones.
class _BadgeDisc extends StatelessWidget {
  final Color color;
  final IconData icon;
  final bool earned;
  final double size;
  final bool glow;

  const _BadgeDisc({
    required this.color,
    required this.icon,
    required this.earned,
    required this.size,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = SyntraSurface.of(context);
    final core = isDark
        ? const Color(0xFF0A0A0A)
        : Theme.of(context).scaffoldBackgroundColor;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: earned
            ? RadialGradient(
                center: const Alignment(-0.4, -0.4),
                radius: 0.95,
                colors: [
                  color.withValues(alpha: 0.22),
                  color.withValues(alpha: 0.07),
                  core,
                ],
                stops: const [0.0, 0.6, 1.0],
              )
            : null,
        color: earned ? null : s.bg2,
        border: Border.all(
          color: earned ? color.withValues(alpha: 0.40) : s.bg3,
          width: earned ? 1.5 : 1,
        ),
        boxShadow: earned && glow
            ? [BoxShadow(color: color.withValues(alpha: 0.22), blurRadius: 36)]
            : null,
      ),
      child: Icon(
        icon,
        size: size * 0.46,
        color: earned ? color : cs.onSurfaceVariant,
      ),
    );
  }
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: _BadgeDisc(
        color: badge.color,
        icon: badge.icon,
        earned: isEarned,
        size: size,
      ),
    );
  }
}

/// The badge detail sheet — rebuilt in the design language: a dark glass panel
/// with an accent halo, the medallion as hero, Octarine title, an uppercase
/// status pill, and muted body copy.
void showBadgeInfoSheet(BuildContext context, AppBadge badge, bool isEarned) {
  final l = S.of(context);
  final name = badgeLabel(l, badge.id);
  final desc = badgeDesc(l, badge.id);

  showSyntraSheet<void>(
    context,
    accent: isEarned ? badge.color : null,
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      final isDark = Theme.of(ctx).brightness == Brightness.dark;
      final s = SyntraSurface.of(ctx);
      final fg = isDark ? Colors.white : cs.onSurface;
      final accent = isEarned ? badge.color : cs.onSurfaceVariant;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.6, end: 1.0),
            duration: const Duration(milliseconds: 520),
            curve: const Cubic(0.34, 1.56, 0.64, 1),
            builder: (_, v, child) => Transform.scale(scale: v, child: child),
            child: _BadgeDisc(
              color: badge.color,
              icon: badge.icon,
              earned: isEarned,
              size: 104,
              glow: true,
            ),
          ),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Octarine',
                fontWeight: FontWeight.w700,
                fontSize: 26,
                height: 1.15,
                letterSpacing: -0.4,
                color: fg,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isEarned ? badge.color.withValues(alpha: 0.12) : s.bg2,
              border: Border.all(
                color: isEarned ? badge.color.withValues(alpha: 0.30) : s.bg3,
              ),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isEarned ? Icons.check_rounded : Icons.lock_rounded,
                  size: 13,
                  color: accent,
                ),
                const SizedBox(width: 6),
                Text(
                  (isEarned ? l.badgeOpted : l.badgeLocked).toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              desc,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14.5,
                height: 1.55,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      );
    },
  );
}
