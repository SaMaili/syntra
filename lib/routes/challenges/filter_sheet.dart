import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../generated/l10n.dart';
import '../../providers/challenge_providers.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/syntra_button.dart';

class ChallengesFilterSheet extends ConsumerWidget {
  const ChallengesFilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(challengeFiltersProvider);
    final notifier = ref.read(challengeFiltersProvider.notifier);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
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
              if (filters.activeFilterCount > 0)
                TextButton(
                  onPressed: notifier.resetAdvancedFilters,
                  child: Text(l.filterReset),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Challenge type ────────────────────────────────────────────────
          Text(l.filterTypeLabel,
              style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.sm),
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
          const SizedBox(height: AppSpacing.lg),

          // ── Environment ───────────────────────────────────────────────────
          Text(l.filterEnvLabel,
              style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.sm),
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
          const SizedBox(height: AppSpacing.lg),

          // ── Flirt filter ──────────────────────────────────────────────────
          Text(l.filterFlirtLabel,
              style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.sm),
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
          const SizedBox(height: AppSpacing.lg),

          // ── Not done toggle ───────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.filterNewOnly,
                        style: tt.labelLarge
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    Text(l.filterNewOnlySubtitle,
                        style: tt.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              Switch(
                value: filters.showOnlyNotDone,
                onChanged: notifier.setShowOnlyNotDone,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

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
              color: isSelected ? cs.primary : cs.surfaceContainerHighest,
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
                    color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  label(item),
                  style: tt.labelMedium?.copyWith(
                    color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
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
