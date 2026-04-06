import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syntra/challenge.dart';

import '../../generated/l10n.dart';
import '../../providers/challenge_providers.dart';
import '../../providers/statistics_providers.dart';
import '../../theme/app_spacing.dart';
import 'challenge_list_item.dart';

class ChallengeList extends ConsumerWidget {
  final void Function(BuildContext, Challenge) onStart;

  const ChallengeList({required this.onStart});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredChallengesProvider);
    final filters = ref.watch(challengeFiltersProvider);
    final completedIds =
        ref.watch(completedChallengeIdsProvider).valueOrNull ?? {};

    return filteredAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (list) {
        final filtered = filters.showOnlyNotDone
            ? list.where((c) => !completedIds.contains(c.id)).toList()
            : list;

        if (filtered.isEmpty) return const ChallengesEmptyState();

        return ListView.separated(
          padding: const EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: AppSpacing.xl,
          ),
          itemCount: filtered.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, i) => ChallengeListItem(
            challenge: filtered[i],
            isDone: completedIds.contains(filtered[i].id),
            onStart: () => onStart(context, filtered[i]),
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
