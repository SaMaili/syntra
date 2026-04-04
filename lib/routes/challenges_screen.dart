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
  late PageController _pageController;
  ChallengeTypeFilter _lastType = ChallengeTypeFilter.solo;
  bool _isAnimating = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final filters = ref.read(challengeFiltersProvider);
      _lastType = filters.typeFilter;
      _pageController.jumpToPage(_indexFromFilter(_lastType));
    });
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _indexFromFilter(ChallengeTypeFilter filter) {
    switch (filter) {
      case ChallengeTypeFilter.solo:
        return 0;
      case ChallengeTypeFilter.group:
        return 1;
      case ChallengeTypeFilter.both:
        return 2;
    }
  }

  ChallengeTypeFilter _filterFromIndex(int index) {
    switch (index) {
      case 0:
        return ChallengeTypeFilter.solo;
      case 1:
        return ChallengeTypeFilter.group;
      default:
        return ChallengeTypeFilter.both;
    }
  }

  void _onFilterSelected(ChallengeTypeFilter filter) {
    if (_lastType == filter) return;
    _lastType = filter;
    ref.read(challengeFiltersProvider.notifier).setTypeFilter(filter);
    _isAnimating = true;
    _pageController
        .animateToPage(
          _indexFromFilter(filter),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
        )
        .whenComplete(() => _isAnimating = false);
  }

  void _onChallengeFinished() => refreshStatistics(ref);

  Future<void> _startChallenge(BuildContext context, Challenge challenge) async {
    SoundService.playDing(enabled: ref.read(soundEffectsEnabledProvider));
    final result = await context.pushPriming(challenge);
    if (result != null) _onChallengeFinished();
  }

  void _onGiveMeOne(BuildContext context) {
    final allAsync = ref.read(czlFilteredChallengesProvider);
    final list = allAsync.value;
    if (list == null || list.isEmpty) return;

    final filters = ref.read(challengeFiltersProvider);
    final completedIds =
        ref.read(completedChallengeIdsProvider).valueOrNull ?? {};

    final candidates = list.where((c) {
      final matchesType = (_lastType == ChallengeTypeFilter.both) ||
          (_lastType == ChallengeTypeFilter.solo && c.type != 'group') ||
          (_lastType == ChallengeTypeFilter.group && c.type == 'group');
      final matchesFlirt = switch (filters.flirtFilter) {
        FlirtFilter.showOnly => c.flirt,
        FlirtFilter.exclude => !c.flirt,
        FlirtFilter.all => true,
      };
      final matchesNotDone =
          !filters.showOnlyNotDone || !completedIds.contains(c.id);
      return matchesType && matchesFlirt && matchesNotDone;
    }).toList();

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

    final completedIds =
        ref.watch(completedChallengeIdsProvider).valueOrNull ?? {};

    ref.listen(challengeFiltersProvider.select((f) => f.typeFilter), (_, next) {
      if (next != _lastType) {
        _lastType = next;
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _indexFromFilter(next),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
          );
        }
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(),
            _FilterBar(
              onTypeSelected: _onFilterSelected,
              onGiveMeOne: () => _onGiveMeOne(context),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) {
                  if (_isAnimating) return;
                  final newFilter = _filterFromIndex(i);
                  if (_lastType != newFilter) {
                    _lastType = newFilter;
                    ref
                        .read(challengeFiltersProvider.notifier)
                        .setTypeFilter(newFilter);
                  }
                },
                children: [
                  _ChallengeList(
                    type: ChallengeTypeFilter.solo,
                    completedIds: completedIds,
                    onStart: _startChallenge,
                  ),
                  _ChallengeList(
                    type: ChallengeTypeFilter.group,
                    completedIds: completedIds,
                    onStart: _startChallenge,
                  ),
                  _ChallengeList(
                    type: ChallengeTypeFilter.both,
                    completedIds: completedIds,
                    onStart: _startChallenge,
                  ),
                ],
              ),
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
          // Streak badge — greyed out when no active streak.
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
                  color: streak > 0 && isStreakActiveToday ? cs.tertiary : cs.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  '$streak',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: streak > 0 && isStreakActiveToday ? cs.tertiary : cs.outline,
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
  final ValueChanged<ChallengeTypeFilter> onTypeSelected;
  final VoidCallback onGiveMeOne;
  const _FilterBar({required this.onTypeSelected, required this.onGiveMeOne});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(challengeFiltersProvider);
    final badgeCount = filters.activeFilterCount;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: Row(
        children: [
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
                  value: ChallengeTypeFilter.group,
                  icon: const Icon(Icons.group, size: 18),
                  label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(S.of(context).group)),
                ),
                ButtonSegment(
                  value: ChallengeTypeFilter.both,
                  icon: const Icon(Icons.all_inclusive, size: 18),
                  label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(S.of(context).filterAll)),
                ),
              ],
              selected: {filters.typeFilter},
              onSelectionChanged: (s) => onTypeSelected(s.first),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Advanced filter button with badge.
          Badge(
            isLabelVisible: badgeCount > 0,
            label: Text('$badgeCount'),
            child: IconButton(
              icon: const Icon(Icons.tune_rounded),
              tooltip: S.of(context).filterTitle,
              onPressed: () => _openFilterSheet(context, ref),
            ),
          ),
          // "Give me one" — random brave challenge pick.
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

    return Padding(
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

          // ── Flirt filter ─────────────────────────────────────────────────
          Text(l.filterFlirtLabel,
              style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<FlirtFilter>(
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 13)),
            segments: [
              ButtonSegment(
                value: FlirtFilter.all,
                label: Text(l.filterAll),
                icon: const Icon(Icons.apps_rounded, size: 16),
              ),
              ButtonSegment(
                value: FlirtFilter.showOnly,
                label: Text(l.filterFlirtOnly),
                icon: const Icon(Icons.favorite_rounded, size: 16),
              ),
              ButtonSegment(
                value: FlirtFilter.exclude,
                label: Text(l.filterFlirtExclude),
                icon: const Icon(Icons.heart_broken_rounded, size: 16),
              ),
            ],
            selected: {filters.flirtFilter},
            onSelectionChanged: (s) => notifier.setFlirtFilter(s.first),
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
                        style:
                            tt.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
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
          const SizedBox(height: AppSpacing.lg),

          // ── Sort by ───────────────────────────────────────────────────────
          Text(l.filterSortBy,
              style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<SortMode>(
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 13)),
            segments: [
              ButtonSegment(
                value: SortMode.frequency,
                label: Text(l.filterSortPopular),
                icon: const Icon(Icons.trending_up_rounded, size: 16),
              ),
              ButtonSegment(
                value: SortMode.difficulty,
                label: Text(l.filterSortEasiest),
                icon: const Icon(Icons.signal_cellular_alt_rounded, size: 16),
              ),
            ],
            selected: {filters.sortBy},
            onSelectionChanged: (s) => notifier.setSortBy(s.first),
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

// ─── Challenge list ───────────────────────────────────────────────────────────

class _ChallengeList extends ConsumerWidget {
  final ChallengeTypeFilter type;
  final Set<String> completedIds;
  final void Function(BuildContext, Challenge) onStart;

  const _ChallengeList({
    required this.type,
    required this.completedIds,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allChallenges = ref.watch(czlFilteredChallengesProvider);
    final filters = ref.watch(challengeFiltersProvider);

    return allChallenges.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (list) {
        var filtered = list.where((c) {
          // Type
          final matchesType = (type == ChallengeTypeFilter.both) ||
              (type == ChallengeTypeFilter.solo && c.type != 'group') ||
              (type == ChallengeTypeFilter.group && c.type == 'group');
          // Flirt
          final matchesFlirt = switch (filters.flirtFilter) {
            FlirtFilter.showOnly => c.flirt,
            FlirtFilter.exclude => !c.flirt,
            FlirtFilter.all => true,
          };
          // Not-done
          final matchesNotDone =
              !filters.showOnlyNotDone || !completedIds.contains(c.id);
          return matchesType && matchesFlirt && matchesNotDone;
        }).toList();

        // Sort
        switch (filters.sortBy) {
          case SortMode.frequency:
            filtered.sort((a, b) => b.frequency.compareTo(a.frequency));
          case SortMode.difficulty:
            filtered.sort((a, b) => a.xp.compareTo(b.xp));
        }

        if (filtered.isEmpty) {
          return _EmptyState();
        }
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
                  icon: challenge.type == 'group'
                      ? Icons.group_outlined
                      : Icons.person_outlined,
                  label: challenge.type == 'group'
                      ? S.of(context).group
                      : S.of(context).solo,
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

