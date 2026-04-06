import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../generated/l10n.dart';
import '../../providers/statistics_providers.dart';
import '../../theme/app_spacing.dart';

class ChallengesHeader extends ConsumerWidget {
  const ChallengesHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(overviewStatsProvider);
    final totalXp = stats.whenOrNull(data: (s) => s['totalXp']) ?? 0;
    final weekStreak = stats.whenOrNull(data: (s) => s['weekStreak']) ?? 0;
    final pendingWeekStreak =
        stats.whenOrNull(data: (s) => s['pendingWeekStreak']) ?? 0;
    // Active (orange): current week already hit the threshold.
    // Pending (grey with count): last week qualified but current week not yet —
    //   one-week grace period, shows previous streak as motivational cue.
    // Reset (grey 0): two or more consecutive weeks missed.
    final isStreakActive = weekStreak > 0;
    final displayStreak = weekStreak > 0 ? weekStreak : pendingWeekStreak;
    final cs = Theme.of(context).colorScheme;
    final l = S.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l.navChallenge,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          // Weekly streak badge
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: isStreakActive
                  ? cs.tertiary.withValues(alpha: 0.12)
                  : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  size: 18,
                  color: isStreakActive ? cs.tertiary : cs.outline,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '$displayStreak ${l.weeksShort}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isStreakActive ? cs.tertiary : cs.outline,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Aura badge
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.emoji_events, size: 18, color: cs.onPrimaryContainer),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '$totalXp ${S.of(context).auraPoints}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onPrimaryContainer,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
