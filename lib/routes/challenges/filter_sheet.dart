import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../generated/l10n.dart';
import '../../providers/challenge_providers.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/syntra_button.dart';

class ChallengesFilterSheet extends ConsumerWidget {
  const ChallengesFilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(challengeFiltersProvider);
    final notifier = ref.read(challengeFiltersProvider.notifier);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);
    
    final hasResettableFilters = filters.environmentFilter != EnvironmentFilter.all ||
        filters.completionFilter != CompletionFilter.all ||
        filters.auraSortOrder != AuraSortOrder.none ||
        filters.completionSortOrder != CompletionSortOrder.none ||
        filters.flirtFilter != FlirtFilter.all;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg + MediaQuery.paddingOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              Text(l.filterTitle,
                  style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              if (hasResettableFilters)
                TextButton(
                  onPressed: notifier.resetAdvancedFilters,
                  child: Text(l.filterReset),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Scrollable area for filters
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.sm),

                  // ── Sorting ───────────────────────────────────────────────────
                  Text(l.filterOrderLabel,
                      style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Expanded(
                        child: _OrderButton(
                          categoryIcon: Icons.emoji_events_outlined,
                          categoryLabel: l.filterAuraLabel,
                          stateIcon: switch (filters.auraSortOrder) {
                            AuraSortOrder.none => Icons.remove_rounded,
                            AuraSortOrder.asc => Icons.arrow_upward_rounded,
                            AuraSortOrder.desc => Icons.arrow_downward_rounded,
                          },
                          active: filters.auraSortOrder != AuraSortOrder.none,
                          onTap: () => notifier.setAuraSortOrder(
                            AuraSortOrder.values[
                                (filters.auraSortOrder.index + 1) % AuraSortOrder.values.length],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _OrderButton(
                          categoryIcon: Icons.check_circle_outline_rounded,
                          categoryLabel: l.filterOrderCompletionLabel,
                          stateIcon: switch (filters.completionSortOrder) {
                            CompletionSortOrder.none => Icons.remove_rounded,
                            CompletionSortOrder.newestFirst => Icons.update_rounded,
                            CompletionSortOrder.oldestFirst => Icons.history_rounded,
                          },
                          active: filters.completionSortOrder != CompletionSortOrder.none,
                          onTap: () => notifier.setCompletionSortOrder(
                            CompletionSortOrder.values[
                                (filters.completionSortOrder.index + 1) %
                                    CompletionSortOrder.values.length],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── Challenge type ────────────────────────────────────────────────
                  Text(l.filterTypeLabel,
                      style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSpacing.xs),
                  if (Platform.isIOS)
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoSlidingSegmentedControl<ChallengeTypeFilter>(
                        groupValue: filters.typeFilter,
                        onValueChanged: (v) {
                          if (v != null) notifier.setTypeFilter(v);
                        },
                        children: {
                          for (final t in ChallengeTypeFilter.values)
                            t: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    switch (t) {
                                      ChallengeTypeFilter.solo =>
                                        Icons.person_rounded,
                                      ChallengeTypeFilter.group =>
                                        Icons.group_rounded,
                                      ChallengeTypeFilter.coop =>
                                        Icons.people_alt_rounded,
                                      ChallengeTypeFilter.dare =>
                                        Icons.bolt_rounded,
                                      ChallengeTypeFilter.all =>
                                        Icons.all_inclusive_rounded,
                                    },
                                    size: 14,
                                    color: filters.typeFilter == t
                                        ? cs.onSurface
                                        : cs.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    switch (t) {
                                      ChallengeTypeFilter.solo => l.solo,
                                      ChallengeTypeFilter.group => l.group,
                                      ChallengeTypeFilter.coop => l.coop,
                                      ChallengeTypeFilter.dare => l.dare,
                                      ChallengeTypeFilter.all => l.filterAll,
                                    },
                                    style: tt.labelSmall?.copyWith(
                                      fontSize: 11,
                                      fontWeight: filters.typeFilter == t
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: filters.typeFilter == t
                                          ? cs.onSurface
                                          : cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        },
                      ),
                    )
                  else
                    AnimatedChipRow<ChallengeTypeFilter>(
                      items: ChallengeTypeFilter.values,
                      selected: filters.typeFilter,
                      label: (t) => switch (t) {
                        ChallengeTypeFilter.solo => l.solo,
                        ChallengeTypeFilter.group => l.group,
                        ChallengeTypeFilter.coop => l.coop,
                        ChallengeTypeFilter.dare => l.dare,
                        ChallengeTypeFilter.all => l.filterAll,
                      },
                      icon: (t) => switch (t) {
                        ChallengeTypeFilter.solo => Icons.person_rounded,
                        ChallengeTypeFilter.group => Icons.group_rounded,
                        ChallengeTypeFilter.coop => Icons.people_alt_rounded,
                        ChallengeTypeFilter.dare => Icons.bolt_rounded,
                        ChallengeTypeFilter.all => Icons.all_inclusive_rounded,
                      },
                      onSelected: notifier.setTypeFilter,
                    ),
                  const SizedBox(height: AppSpacing.md),

                  // ── Environment ───────────────────────────────────────────────────
                  Text(l.filterEnvLabel,
                      style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSpacing.xs),
                  AnimatedChipRow<EnvironmentFilter>(
                    items: EnvironmentFilter.values,
                    selected: filters.environmentFilter,
                    label: (e) => switch (e) {
                      EnvironmentFilter.all => l.filterAll,
                      EnvironmentFilter.street => l.filterEnvStreet,
                      EnvironmentFilter.transit => l.filterEnvTransit,
                      EnvironmentFilter.cafe => l.filterEnvCafe,
                      EnvironmentFilter.event => l.filterEnvEvent,
                    },
                    icon: (_) => null,
                    onSelected: notifier.setEnvironmentFilter,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── Flirt filter ──────────────────────────────────────────────────
                  Text(l.filterFlirtLabel,
                      style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSpacing.xs),
                  AnimatedChipRow<FlirtFilter>(
                    items: FlirtFilter.values,
                    selected: filters.flirtFilter,
                    label: (f) => switch (f) {
                      FlirtFilter.all => l.filterAll,
                      FlirtFilter.showOnly => l.filterFlirtOnly,
                      FlirtFilter.exclude => l.filterFlirtExclude,
                    },
                    icon: (f) => switch (f) {
                      FlirtFilter.all => Icons.apps_rounded,
                      FlirtFilter.showOnly => Icons.favorite_rounded,
                      FlirtFilter.exclude => Icons.heart_broken_rounded,
                    },
                    onSelected: notifier.setFlirtFilter,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── Completion filter ─────────────────────────────────────────────
                  Text(l.filterCompletionLabel,
                      style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSpacing.xs),
                  AnimatedChipRow<CompletionFilter>(
                    items: CompletionFilter.values,
                    selected: filters.completionFilter,
                    label: (c) => switch (c) {
                      CompletionFilter.all => l.filterCompletionAll,
                      CompletionFilter.done => l.filterCompletionDone,
                      CompletionFilter.notDone => l.filterCompletionNotDone,
                    },
                    icon: (c) => switch (c) {
                      CompletionFilter.all => Icons.apps_rounded,
                      CompletionFilter.done => Icons.check_circle_rounded,
                      CompletionFilter.notDone => Icons.radio_button_unchecked_rounded,
                    },
                    onSelected: notifier.setCompletionFilter,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          SyntraButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.done),
          ),
        ],
      ),
    );
  }
}

/// Generic animated chip row used inside the filter sheet.
class AnimatedChipRow<T> extends StatelessWidget {
  final List<T> items;
  final T selected;
  final String Function(T) label;
  final IconData? Function(T) icon;
  final ValueChanged<T> onSelected;

  const AnimatedChipRow({
    super.key,
    required this.items,
    required this.selected,
    required this.label,
    required this.icon,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: items.map((item) {
        final isSelected = item == selected;
        final chipIcon = icon(item);
        return GestureDetector(
          onTap: () => onSelected(item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: isSelected
                  ? Color.lerp(cs.primary, Colors.grey, 0.45)
                  : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
              border: isSelected
                  ? null
                  : Border.all(color: cs.outlineVariant, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (chipIcon != null) ...[
                  Icon(
                    chipIcon,
                    size: 14,
                    color: isSelected ? Colors.white : cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  label(item),
                  style: tt.labelMedium?.copyWith(
                    color: isSelected ? Colors.white : cs.onSurfaceVariant,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// A single tappable button in the Order section.
/// The button cycles through sort states on each tap.
class _OrderButton extends StatelessWidget {
  final IconData categoryIcon;
  final String categoryLabel;
  final IconData stateIcon;
  final bool active;
  final VoidCallback onTap;

  const _OrderButton({
    required this.categoryIcon,
    required this.categoryLabel,
    required this.stateIcon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final activeColor = Color.lerp(cs.primary, Colors.grey, 0.45)!;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: active ? activeColor : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
          border: active ? null : Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(categoryIcon,
                size: 16, color: active ? Colors.white : cs.onSurfaceVariant),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                categoryLabel,
                style: tt.labelMedium?.copyWith(
                  color: active ? Colors.white : cs.onSurfaceVariant,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(
                stateIcon,
                key: ValueKey(stateIcon),
                size: 18,
                color: active ? Colors.white : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
