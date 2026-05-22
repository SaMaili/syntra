import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../generated/l10n.dart';
import '../../providers/challenge_providers.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/syntra_sheet.dart';
import 'filter_sheet.dart';

class ChallengesFilterBar extends ConsumerWidget {
  const ChallengesFilterBar({super.key});

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
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: TypeSelector(
              selected: filters.typeFilter,
              onChanged: notifier.setTypeFilter,
              labels: [S.of(context).solo, S.of(context).filterAll],
            ),
          ),
          IconButton(
            icon: Icon(flirtIcon, color: flirtColor),
            tooltip: S.of(context).filterFlirtLabel,
            onPressed: () {
              final next =
                  FlirtFilter.values[(filters.flirtFilter.index + 1) %
                      FlirtFilter.values.length];
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
        ],
      ),
    );
  }

  static void openSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      constraints: const BoxConstraints(maxWidth: double.infinity),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 1.0,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: syntraSheetDecoration(context),
          clipBehavior: Clip.antiAlias,
          child: ChallengesFilterSheet(scrollController: scrollController),
        ),
      ),
    );
  }

  void _openFilterSheet(BuildContext context) => openSheet(context);
}

/// Three-tab bar (Solo | All) with a sliding pill indicator.
class TypeSelector extends StatelessWidget {
  static const _mainBarValues = [
    ChallengeTypeFilter.solo,
    ChallengeTypeFilter.all,
  ];
  static const _icons = [Icons.person_rounded, Icons.all_inclusive_rounded];

  final ChallengeTypeFilter selected;
  final ValueChanged<ChallengeTypeFilter> onChanged;
  final List<String> labels;

  const TypeSelector({
    super.key,
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

    if (Platform.isIOS) {
      return SizedBox(
        height: 36,
        child: CupertinoSlidingSegmentedControl<ChallengeTypeFilter>(
          groupValue: display,
          onValueChanged: (v) {
            if (v != null) onChanged(v);
          },
          children: {
            for (int i = 0; i < _mainBarValues.length; i++)
              _mainBarValues[i]: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _icons[i],
                    size: 14,
                    color: _mainBarValues[i] == display
                        ? cs.onSurface
                        : cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    labels[i],
                    style: tt.labelSmall?.copyWith(
                      fontSize: 11,
                      fontWeight: _mainBarValues[i] == display
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: _mainBarValues[i] == display
                          ? cs.onSurface
                          : cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
          },
        ),
      );
    }

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
                    color: cs.primaryContainer,
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
                                  ? cs.onPrimaryContainer
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
                                    ? cs.onPrimaryContainer
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
