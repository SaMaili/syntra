import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../generated/l10n.dart';
import '../../providers/statistics_providers.dart';
import '../../theme/app_spacing.dart';

/// Scrollable hero header shown at the top of the challenges screen.
/// Contains the screen title, weekly streak badge, and aura badge.
/// Scrolls away with the list; only the filter bar below stays pinned.
class ChallengesHeroHeader extends ConsumerWidget {
  const ChallengesHeroHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(overviewStatsProvider);
    final totalXp = stats.whenOrNull(data: (s) => s['totalXp']) ?? 0;
    final weekStreak = stats.whenOrNull(data: (s) => s['weekStreak']) ?? 0;
    final pendingWeekStreak =
        stats.whenOrNull(data: (s) => s['pendingWeekStreak']) ?? 0;
    final isStreakActive = weekStreak > 0;
    final displayStreak = weekStreak > 0 ? weekStreak : pendingWeekStreak;

    final cs = Theme.of(context).colorScheme;
    final l = S.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Streak badge ──────────────────────────────────────────────────
          _StatBadge(
            icon: Icons.local_fire_department_rounded,
            label: '$displayStreak ${l.weeksShort}',
            active: isStreakActive,
            activeColor: cs.tertiary,
            inactiveColor: cs.outline,
            inactiveBg: cs.surfaceContainerHighest,
          ),

          const Spacer(),

          // ── Aura badge ────────────────────────────────────────────────────
          _StatBadge(
            icon: Icons.emoji_events,
            label: '$totalXp ${l.auraPoints}',
            active: true,
            activeColor: cs.onPrimaryContainer,
            inactiveColor: cs.onPrimaryContainer,
            inactiveBg: cs.primaryContainer,
            activeBg: cs.primaryContainer,
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color activeColor;
  final Color inactiveColor;
  final Color? activeBg;
  final Color inactiveBg;

  const _StatBadge({
    required this.icon,
    required this.label,
    required this.active,
    required this.activeColor,
    required this.inactiveColor,
    required this.inactiveBg,
    this.activeBg,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : inactiveColor;
    final bg = active ? (activeBg ?? Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.12)) : inactiveBg;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}
