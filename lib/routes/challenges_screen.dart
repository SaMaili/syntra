import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syntra/challenge.dart';
import 'package:syntra/generated/l10n.dart';
import 'package:syntra/providers/challenge_providers.dart';
import 'package:syntra/providers/settings_providers.dart';
import 'package:syntra/providers/statistics_providers.dart';
import 'package:syntra/router.dart';
import 'package:syntra/routes/challenge_detail_screen.dart';
import 'package:syntra/routes/challenge_done_screen.dart' show socialProofCount;
import 'package:syntra/services/sound_service.dart';
import 'package:syntra/theme/app_spacing.dart';
import 'package:syntra/widgets/syntra_button.dart';

class ChallengesScreen extends ConsumerStatefulWidget {
  const ChallengesScreen({super.key});

  @override
  ConsumerState<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends ConsumerState<ChallengesScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void _onChallengeFinished() => refreshStatistics(ref);

  Future<void> _startChallenge(BuildContext context, Challenge challenge) async {
    SoundService.playDing(enabled: ref.read(soundEffectsEnabledProvider));
    final result = await context.pushPriming(challenge);
    if (result != null) _onChallengeFinished();
  }

  void _onGiveMeOne(BuildContext context) {
    final allAsync = ref.read(filteredChallengesProvider);
    final list = allAsync.value;
    if (list == null || list.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).noChalllengesFound),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final filters = ref.read(challengeFiltersProvider);
    final completedIds =
        ref.read(completedChallengeIdsProvider).valueOrNull ?? {};

    final candidates = list
        .where((c) =>
            !filters.showOnlyNotDone || !completedIds.contains(c.id))
        .toList();

    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).noChalllengesFound),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final pick = candidates[Random().nextInt(candidates.length)];
    _startChallenge(context, pick);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(),
            _FilterBar(onGiveMeOne: () => _onGiveMeOne(context)),
            Expanded(
              child: _ChallengeList(onStart: _startChallenge),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(overviewStatsProvider);
    final totalXp = stats.whenOrNull(data: (s) => s['totalXp']) ?? 0;
    final streak = stats.whenOrNull(data: (s) => s['streak']) ?? 0;
    final completedToday =
        stats.whenOrNull(data: (s) => s['completedToday']) ?? 0;
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
                horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
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
                  size: 16,
                  color: streak > 0 && isStreakActiveToday
                      ? cs.tertiary
                      : cs.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  '$streak',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
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
                  '$totalXp XP',
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

// ─── Filter bar ───────────────────────────────────────────────────────────────

class _FilterBar extends ConsumerWidget {
  final VoidCallback onGiveMeOne;
  const _FilterBar({required this.onGiveMeOne});

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
          // ── Type segments: Solo | Coop | All ────────────────────────────
          Expanded(
            child: SegmentedButton<ChallengeTypeFilter>(
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 13),
              ),
              segments: [
                ButtonSegment(
                  value: ChallengeTypeFilter.solo,
                  icon: const Icon(Icons.person, size: 18),
                  label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(S.of(context).solo)),
                ),
                ButtonSegment(
                  value: ChallengeTypeFilter.coop,
                  icon: const Icon(Icons.people_alt_rounded, size: 18),
                  label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(S.of(context).coop)),
                ),
                ButtonSegment(
                  value: ChallengeTypeFilter.all,
                  icon: const Icon(Icons.all_inclusive, size: 18),
                  label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(S.of(context).filterAll)),
                ),
              ],
              selected: {
                // If current filter isn't in main bar, show All as selected
                const {
                      ChallengeTypeFilter.solo,
                      ChallengeTypeFilter.coop,
                      ChallengeTypeFilter.all,
                    }.contains(filters.typeFilter)
                    ? filters.typeFilter
                    : ChallengeTypeFilter.all,
              },
              onSelectionChanged: (s) =>
                  notifier.setTypeFilter(s.first),
            ),
          ),
          // ── Flirt cycle button ───────────────────────────────────────────
          IconButton(
            icon: Icon(flirtIcon, color: flirtColor),
            tooltip: S.of(context).filterFlirtLabel,
            onPressed: () {
              final next = FlirtFilter
                  .values[(filters.flirtFilter.index + 1) % FlirtFilter.values.length];
              notifier.setFlirtFilter(next);
            },
          ),
          // ── Advanced filter button with badge ────────────────────────────
          Badge(
            isLabelVisible: badgeCount > 0,
            label: Text('$badgeCount'),
            child: IconButton(
              icon: const Icon(Icons.tune_rounded),
              tooltip: S.of(context).filterTitle,
              onPressed: () => _openFilterSheet(context, ref),
            ),
          ),
          // ── Give me one ──────────────────────────────────────────────────
          IconButton(
            icon: const Icon(Icons.casino_rounded),
            tooltip: S.of(context).giveMeOneTooltip,
            onPressed: onGiveMeOne,
          ),
        ],
      ),
    );
  }

  void _openFilterSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _FilterSheet(),
    );
  }
}

// ─── Advanced filter bottom sheet ────────────────────────────────────────────

class _FilterSheet extends ConsumerWidget {
  const _FilterSheet();

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
          _AnimatedChipRow<ChallengeTypeFilter>(
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
          _AnimatedChipRow<EnvironmentFilter>(
            items: EnvironmentFilter.values,
            selected: filters.environmentFilter,
            label: (e) => switch (e) {
              EnvironmentFilter.all => l.filterAll,
              EnvironmentFilter.street => '🚶 Street',
              EnvironmentFilter.transit => '🚌 Transit',
              EnvironmentFilter.cafe => '☕ Café',
              EnvironmentFilter.event => '🎉 Event',
            },
            icon: (_) => null,
            onSelected: notifier.setEnvironmentFilter,
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Flirt filter ──────────────────────────────────────────────────
          Text(l.filterFlirtLabel,
              style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.sm),
          _AnimatedChipRow<FlirtFilter>(
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

          // ── Done ─────────────────────────────────────────────────────────
          SyntraButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.done),
          ),
        ],
      ),
    );
  }
}

// ─── Animated chip row ────────────────────────────────────────────────────────

class _AnimatedChipRow<T> extends StatelessWidget {
  final List<T> items;
  final T selected;
  final String Function(T) label;
  final IconData? Function(T) icon;
  final ValueChanged<T> onSelected;

  const _AnimatedChipRow({
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

// ─── Challenge list ───────────────────────────────────────────────────────────

class _ChallengeList extends ConsumerWidget {
  final void Function(BuildContext, Challenge) onStart;

  const _ChallengeList({required this.onStart});

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
        // Apply showOnlyNotDone here since we need completedIds
        final filtered = filters.showOnlyNotDone
            ? list.where((c) => !completedIds.contains(c.id)).toList()
            : list;

        if (filtered.isEmpty) return _EmptyState();

        return ListView.separated(
          padding: const EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: AppSpacing.xl,
          ),
          itemCount: filtered.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, i) => _ChallengeListItem(
            challenge: filtered[i],
            isDone: completedIds.contains(filtered[i].id),
            onStart: () => onStart(context, filtered[i]),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
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
            S.of(context).noChalllengesFound,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Individual list item ─────────────────────────────────────────────────────

class _ChallengeListItem extends StatelessWidget {
  final Challenge challenge;
  final bool isDone;
  final VoidCallback onStart;

  const _ChallengeListItem({
    required this.challenge,
    required this.isDone,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final cardColor = isDone
        ? Color.lerp(
            Theme.of(context).cardTheme.color ?? cs.surfaceContainer,
            const Color(0xFF4CAF50),
            0.12,
          )
        : null;

    return Card(
      color: cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.cardRadius),
            ),
            onTap: () => _onInfoTap(context),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          challenge.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (isDone)
                        Padding(
                          padding: const EdgeInsets.only(left: AppSpacing.xs),
                          child: Icon(Icons.check_circle_rounded,
                              size: 16, color: const Color(0xFF4CAF50)),
                        ),
                      if (challenge.flirt)
                        Padding(
                          padding: const EdgeInsets.only(left: AppSpacing.xs),
                          child: Icon(Icons.favorite,
                              size: 16, color: cs.secondary),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    challenge.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '~${socialProofCount(challenge.id)} people in this community have tried this',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant.withAlpha(160),
                        ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
            child: Row(
              children: [
                _MetaChip(
                  icon: Icons.timer_outlined,
                  label: _formatTime(challenge.time),
                ),
                const SizedBox(width: AppSpacing.sm),
                _MetaChip(
                  icon: Icons.emoji_events_outlined,
                  label: '${challenge.xp} XP',
                ),
                const SizedBox(width: AppSpacing.sm),
                _MetaChip(
                  icon: _typeIcon(challenge.type),
                  label: _typeLabel(context, challenge.type),
                ),
                const Spacer(),
                SyntraButton.small(
                  onPressed: onStart,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(S.of(context).letsGo),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _typeIcon(String type) => switch (type) {
        'group' => Icons.group_outlined,
        'coop' => Icons.people_alt_outlined,
        'dare' => Icons.bolt_outlined,
        _ => Icons.person_outlined,
      };

  String _typeLabel(BuildContext context, String type) {
    final l = S.of(context);
    return switch (type) {
      'group' => l.group,
      'coop' => l.coop,
      'dare' => l.dare,
      _ => l.solo,
    };
  }

  String _formatTime(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return s == 0 ? '${m}m' : '${m}m ${s}s';
  }

  Future<void> _onInfoTap(BuildContext context) async {
    final start = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ChallengeDetailScreen(challenge: challenge),
      ),
    );
    if (start == true) onStart();
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: cs.outline),
        const SizedBox(width: 3),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: cs.outline),
        ),
      ],
    );
  }
}
