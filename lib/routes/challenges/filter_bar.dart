import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../generated/l10n.dart';
import '../../providers/challenge_providers.dart';
import '../../theme/app_spacing.dart';
import 'filter_sheet.dart';

class ChallengesFilterBar extends ConsumerWidget {
  final VoidCallback onGiveMeOne;
  const ChallengesFilterBar({required this.onGiveMeOne});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(challengeFiltersProvider);
    final notifier = ref.read(challengeFiltersProvider.notifier);
    final badgeCount = filters.activeFilterCount;
    final cs = Theme.of(context).colorScheme;

    // Flirt icon cycles: all → showOnly → exclude → all
    final (flirtIcon, flirtColor) = switch (filters.flirtFilter) {
      FlirtFilter.all => (Icons.favorite_border_rounded, cs.onSurfaceVariant),
      FlirtFilter.showOnly => (Icons.favorite_rounded, cs.secondary),
      FlirtFilter.exclude => (Icons.heart_broken_rounded, cs.error),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: TypeSelector(
              selected: filters.typeFilter,
              onChanged: notifier.setTypeFilter,
              labels: [
                S.of(context).solo,
                S.of(context).coop,
                S.of(context).filterAll,
              ],
            ),
          ),
          IconButton(
            icon: Icon(flirtIcon, color: flirtColor),
            tooltip: S.of(context).filterFlirtLabel,
            onPressed: () {
              final next = FlirtFilter
                  .values[(filters.flirtFilter.index + 1) % FlirtFilter.values.length];
              notifier.setFlirtFilter(next);
            },
          ),
          Badge(
            isLabelVisible: badgeCount > 0,
            label: Text('$badgeCount'),
            child: IconButton(
              icon: const Icon(Icons.tune_rounded),
              tooltip: S.of(context).filterTitle,
              onPressed: () => _openFilterSheet(context),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.casino_rounded),
            tooltip: S.of(context).giveMeOneTooltip,
            onPressed: onGiveMeOne,
          ),
        ],
      ),
    );
  }

  void _openFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const ChallengesFilterSheet(),
    );
  }
}

/// Three-tab bar (Solo | Coop | All) with a sliding pill indicator.
class TypeSelector extends StatelessWidget {
  static const _mainBarValues = [
    ChallengeTypeFilter.solo,
    ChallengeTypeFilter.coop,
    ChallengeTypeFilter.all,
  ];
  static const _icons = [
    Icons.person_rounded,
    Icons.people_alt_rounded,
    Icons.all_inclusive_rounded,
  ];

  final ChallengeTypeFilter selected;
  final ValueChanged<ChallengeTypeFilter> onChanged;
  final List<String> labels;

  const TypeSelector({
    required this.selected,
    required this.onChanged,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final display = _mainBarValues.contains(selected)
        ? selected
        : ChallengeTypeFilter.all;
    final selectedIdx = _mainBarValues.indexOf(display);

    return LayoutBuilder(
      builder: (context, constraints) {
        final tabW = constraints.maxWidth / _mainBarValues.length;
        return Container(
          height: 36,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOutCubicEmphasized,
                left: selectedIdx * tabW + 3,
                top: 3,
                bottom: 3,
                width: tabW - 6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color.lerp(cs.secondary, Colors.grey, 0.45),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              Row(
                children: List.generate(_mainBarValues.length, (i) {
                  final isSelected = i == selectedIdx;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onChanged(_mainBarValues[i]),
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _icons[i],
                              size: 13,
                              color: isSelected
                                  ? Colors.white
                                  : cs.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              labels[i],
                              style: tt.labelSmall?.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Colors.white
                                    : cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
