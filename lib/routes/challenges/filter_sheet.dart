// filter_sheet.dart — V2.
//
// Sliding bottom panel for filters + sort, styled with the Syntra design
// tokens (SyntraSurface tiers, BrandColors, SyntraChip). Sections, top → bottom:
//   1. Drag handle + title "Filter & Sort" + Reset link
//   2. Sort by — single-select pills driving challengeSortModeProvider
//   3. Type — solo / group / coop / dare / all
//   4. Environment — all / street / transit / cafe / event
//   5. Flirt — all / show only / exclude
//   6. Level — multi-select pills L1..L{currentZone}
//   7. Completion — all / done / not done
// Footer: legacy Aura / Recency Order rows (kept for users who used them) +
// big "Done" button.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../generated/l10n.dart';
import '../../providers/challenge_providers.dart';
import '../../providers/settings_providers.dart';
import '../../theme/app_spacing.dart';
import '../../theme/brand_colors.dart';
import '../../widgets/syntra_button.dart';
import '../../widgets/syntra_chip.dart';

class ChallengesFilterSheet extends ConsumerWidget {
  final ScrollController? scrollController;
  const ChallengesFilterSheet({super.key, this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = SyntraSurface.of(context);
    final l = S.of(context);

    final filters = ref.watch(challengeFiltersProvider);
    final notifier = ref.read(challengeFiltersProvider.notifier);
    final sortMode = ref.watch(challengeSortModeProvider);
    final currentCzl = ref.watch(comfortZoneLevelProvider);

    final hasResettable = sortMode != ChallengeSortMode.recommended ||
        filters.environmentFilter != EnvironmentFilter.all ||
        filters.completionFilter != CompletionFilter.all ||
        filters.auraSortOrder != AuraSortOrder.none ||
        filters.completionSortOrder != CompletionSortOrder.none ||
        filters.flirtFilter != FlirtFilter.all ||
        filters.typeFilter != ChallengeTypeFilter.all ||
        filters.levelFilter.isNotEmpty;

    final titleColor = isDark ? Colors.white : cs.onSurface;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ──────────────────────────────────────────────
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: s.bg4,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // ── Title row ────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                l.filterTitle,
                style: tt.titleLarge?.copyWith(
                  fontFamily: 'Octarine',
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  letterSpacing: -0.2,
                  color: titleColor,
                ),
              ),
              const Spacer(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: hasResettable
                    ? TextButton(
                        key: const ValueKey('reset-on'),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          ref.read(challengeSortModeProvider.notifier).state =
                              ChallengeSortMode.recommended;
                          notifier.resetAdvancedFilters();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: cs.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          l.filterReset,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : const SizedBox(key: ValueKey('reset-off')),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Scrollable content ───────────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sort by
                  _SectionLabel(label: l.filterOrderLabel),
                  _ChipWrap(
                    children: [
                      for (final (mode, label) in [
                        (ChallengeSortMode.recommended, l.sortRecommended),
                        (ChallengeSortMode.levelAsc, l.sortLevelAsc),
                        (ChallengeSortMode.levelDesc, l.sortLevelDesc),
                        (ChallengeSortMode.auraDesc, l.sortAuraDesc),
                      ])
                        SyntraChip(
                          active: sortMode == mode,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            ref
                                .read(challengeSortModeProvider.notifier)
                                .state = mode;
                          },
                          label: label,
                          size: SyntraChipSize.sm,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Type
                  _SectionLabel(label: l.filterTypeLabel),
                  _ChipWrap(
                    children: [
                      for (final t in ChallengeTypeFilter.values)
                        SyntraChip(
                          active: filters.typeFilter == t,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            notifier.setTypeFilter(t);
                          },
                          label: switch (t) {
                            ChallengeTypeFilter.solo => l.solo,
                            ChallengeTypeFilter.group => l.group,
                            ChallengeTypeFilter.coop => l.coop,
                            ChallengeTypeFilter.dare => l.dare,
                            ChallengeTypeFilter.all => l.filterAll,
                          },
                          icon: switch (t) {
                            ChallengeTypeFilter.solo => Icons.person_rounded,
                            ChallengeTypeFilter.group => Icons.group_rounded,
                            ChallengeTypeFilter.coop =>
                              Icons.people_alt_rounded,
                            ChallengeTypeFilter.dare => Icons.bolt_rounded,
                            ChallengeTypeFilter.all =>
                              Icons.all_inclusive_rounded,
                          },
                          size: SyntraChipSize.sm,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Environment
                  _SectionLabel(label: l.filterEnvLabel),
                  _ChipWrap(
                    children: [
                      for (final e in EnvironmentFilter.values)
                        SyntraChip(
                          active: filters.environmentFilter == e,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            notifier.setEnvironmentFilter(e);
                          },
                          label: switch (e) {
                            EnvironmentFilter.all => l.filterAll,
                            EnvironmentFilter.street => l.filterEnvStreet,
                            EnvironmentFilter.transit => l.filterEnvTransit,
                            EnvironmentFilter.cafe => l.filterEnvCafe,
                            EnvironmentFilter.event => l.filterEnvEvent,
                          },
                          size: SyntraChipSize.sm,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Flirt
                  _SectionLabel(label: l.filterFlirtLabel),
                  _ChipWrap(
                    children: [
                      for (final f in FlirtFilter.values)
                        SyntraChip(
                          active: filters.flirtFilter == f,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            notifier.setFlirtFilter(f);
                          },
                          label: switch (f) {
                            FlirtFilter.all => l.filterAll,
                            FlirtFilter.showOnly => l.filterFlirtOnly,
                            FlirtFilter.exclude => l.filterFlirtExclude,
                          },
                          icon: switch (f) {
                            FlirtFilter.all => Icons.apps_rounded,
                            FlirtFilter.showOnly => Icons.favorite_rounded,
                            FlirtFilter.exclude =>
                              Icons.heart_broken_rounded,
                          },
                          size: SyntraChipSize.sm,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Level (multi-select up to current zone)
                  if (currentCzl >= 1) ...[
                    const _SectionLabel(label: 'Level'),
                    _ChipWrap(
                      children: [
                        for (var lvl = 1; lvl <= currentCzl; lvl++)
                          SyntraChip(
                            active: filters.levelFilter.contains(lvl),
                            onTap: () {
                              HapticFeedback.selectionClick();
                              notifier.toggleLevelFilter(lvl);
                            },
                            label: 'L$lvl',
                            size: SyntraChipSize.sm,
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // Completion
                  _SectionLabel(label: l.filterCompletionLabel),
                  _ChipWrap(
                    children: [
                      for (final c in CompletionFilter.values)
                        SyntraChip(
                          active: filters.completionFilter == c,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            notifier.setCompletionFilter(c);
                          },
                          label: switch (c) {
                            CompletionFilter.all => l.filterCompletionAll,
                            CompletionFilter.done => l.filterCompletionDone,
                            CompletionFilter.notDone =>
                              l.filterCompletionNotDone,
                          },
                          icon: switch (c) {
                            CompletionFilter.all => Icons.apps_rounded,
                            CompletionFilter.done =>
                              Icons.check_circle_rounded,
                            CompletionFilter.notDone =>
                              Icons.radio_button_unchecked_rounded,
                          },
                          size: SyntraChipSize.sm,
                        ),
                    ],
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

// ─── Small uppercase section label ──────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
          color: cs.outline,
        ),
      ),
    );
  }
}

// ─── Tight 8/8 chip wrap used by every section ──────────────────────────────

class _ChipWrap extends StatelessWidget {
  final List<Widget> children;
  const _ChipWrap({required this.children});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs + 2,
      runSpacing: AppSpacing.xs + 2,
      children: children,
    );
  }
}
