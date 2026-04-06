import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../generated/l10n.dart';
import '../../providers/statistics_providers.dart';
import '../../theme/app_spacing.dart';

class WeeklyGoalCard extends ConsumerWidget {
  const WeeklyGoalCard();

  static const _goals = [3, 5, 7];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = ref.watch(weeklyGoalProvider);
    final progressAsync = ref.watch(weeklyProgressProvider);
    final done = progressAsync.valueOrNull ?? 0;
    final progress = (done / goal).clamp(0.0, 1.0);
    final l = S.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flag_rounded, color: cs.primary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    l.weeklyGoalTitle,
                    style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l.weeklyGoalProgress(done, goal),
                  style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: cs.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  done >= goal ? const Color(0xFF43A047) : cs.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l.weeklyGoalSetLabel,
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: List.generate(_goals.length, (i) {
                final g = _goals[i];
                final selected = g == goal;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: i == 0 ? 0 : AppSpacing.xs / 2,
                        right: i == _goals.length - 1 ? 0 : AppSpacing.xs / 2),
                    child: GestureDetector(
                      onTap: () => ref.read(weeklyGoalProvider.notifier).setGoal(g),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? cs.primaryContainer : cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                          border: selected ? Border.all(color: cs.primary, width: 1.5) : null,
                        ),
                        child: Center(
                          child: Text(
                            '$g',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
