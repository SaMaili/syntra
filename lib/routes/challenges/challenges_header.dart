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
    final streak = stats.whenOrNull(data: (s) => s['streak']) ?? 0;
    final completedToday = stats.whenOrNull(data: (s) => s['completedToday']) ?? 0;
    final isStreakActiveToday = completedToday > 0;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              S.of(context).navChallenge,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          // Streak badge
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: streak > 0 && isStreakActiveToday
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
                  color: streak > 0 && isStreakActiveToday ? cs.tertiary : cs.outline,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '$streak',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: streak > 0 && isStreakActiveToday
                            ? cs.tertiary
                            : cs.outline,
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
