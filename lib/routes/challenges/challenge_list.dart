import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syntra/challenge.dart';

import '../../generated/l10n.dart';
import '../../providers/challenge_providers.dart';
import '../../providers/statistics_providers.dart';
import '../../theme/app_spacing.dart';
import 'challenge_list_item.dart';

/// Sliver version of the challenge list — for use inside a [CustomScrollView].
class ChallengeListSliver extends ConsumerWidget {
  final void Function(BuildContext, Challenge) onStart;

  const ChallengeListSliver({required this.onStart});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredChallengesProvider);
    final filters = ref.watch(challengeFiltersProvider);
    final completedIds =
        ref.watch(completedChallengeIdsProvider).valueOrNull ?? {};
    final completionDates =
        ref.watch(latestCompletionDatesProvider).valueOrNull ?? {};

    return filteredAsync.when(
      loading: () => const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => SliverFillRemaining(
        child: Center(child: Text('Error: $e')),
      ),
      data: (list) {
        var filtered = List<Challenge>.from(list);

        // Completion filter
        switch (filters.completionFilter) {
          case CompletionFilter.notDone:
            filtered =
                filtered.where((c) => !completedIds.contains(c.id)).toList();
          case CompletionFilter.done:
            filtered =
                filtered.where((c) => completedIds.contains(c.id)).toList();
          case CompletionFilter.all:
            break;
        }

        // Sort: completion date takes precedence over aura when both are active
        if (filters.completionSortOrder != CompletionSortOrder.none) {
          filtered.sort((a, b) {
            final da = completionDates[a.id];
            final db = completionDates[b.id];
            if (da == null && db == null) return 0;
            if (da == null) return 1; // undone goes to end
            if (db == null) return -1;
            return filters.completionSortOrder == CompletionSortOrder.newestFirst
                ? db.compareTo(da)
                : da.compareTo(db);
          });
        } else if (filters.auraSortOrder != AuraSortOrder.none) {
          filtered.sort((a, b) => filters.auraSortOrder == AuraSortOrder.asc
              ? a.xp.compareTo(b.xp)
              : b.xp.compareTo(a.xp));
        }

        if (filtered.isEmpty) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: ChallengesEmptyState()),
          );
        }

        final bottomInset = MediaQuery.paddingOf(context).bottom;
        return SliverPadding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.xs, AppSpacing.md,
            AppSpacing.xl + bottomInset,
          ),
          sliver: SliverList.separated(
            itemCount: filtered.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, i) => ChallengeListItem(
              challenge: filtered[i],
              isDone: completedIds.contains(filtered[i].id),
              onStart: () => onStart(context, filtered[i]),
            ),
          ),
        );
      },
    );
  }
}

class ChallengesEmptyState extends StatelessWidget {
  const ChallengesEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            S.of(context).noChallengesFound,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
