// challenges_screen.dart — V2 layout (1:1 with design doc).
//
// The screen has no Material AppBar. The header is rendered inline so the
// designed title↔search crossfade, icon-pill row, stat row, sort sheet, and
// tab pills line up exactly with the prototype.
import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';

import '../challenge.dart';
import '../data/settings_repository.dart';
import '../generated/l10n.dart';
import '../logic/comfort_zone_logic.dart';
import '../providers/challenge_providers.dart';
import '../providers/scroll_providers.dart';
import '../providers/settings_providers.dart';
import '../providers/shop_providers.dart';
import '../providers/statistics_providers.dart';
import '../router.dart';
import '../services/sound_service.dart';
import '../theme/app_spacing.dart';
import '../theme/brand_colors.dart';
import '../widgets/syntra_chip.dart';
import '../widgets/syntra_sheet.dart';

import 'challenges/challenge_list.dart';
import 'challenges/filter_sheet.dart';

class ChallengesScreen extends ConsumerStatefulWidget {
  const ChallengesScreen({super.key});

  @override
  ConsumerState<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends ConsumerState<ChallengesScreen>
    with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onChallengeFinished() async {
    refreshStatistics(ref);
    final allowed = await SettingsRepository.instance
        .checkAndMarkReviewRequest();
    if (!allowed) return;
    final review = InAppReview.instance;
    if (await review.isAvailable()) review.requestReview();
  }

  Future<void> _startChallenge(
    BuildContext context,
    Challenge challenge,
  ) async {
    SoundService.playDing(enabled: ref.read(soundEffectsEnabledProvider));
    final result = await context.pushActiveChallenge(challenge);
    if (result != null) {
      _onChallengeFinished();
      if (mounted) setState(() {});
    }
  }

  void _onGiveMeOne(BuildContext context) {
    final list = ref.read(filteredChallengesProvider).value;
    if (list == null || list.isEmpty) {
      _showNoChallengesSnackBar(context);
      return;
    }
    final filters = ref.read(challengeFiltersProvider);
    final completedIds =
        ref.read(completedChallengeIdsProvider).valueOrNull ?? {};
    final candidates = list
        .where((c) => !filters.showOnlyNotDone || !completedIds.contains(c.id))
        .toList();
    if (candidates.isEmpty) {
      _showNoChallengesSnackBar(context);
      return;
    }
    _startChallenge(context, candidates[Random().nextInt(candidates.length)]);
  }

  void _showNoChallengesSnackBar(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(S.of(context).noChallengesFound),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    ref.listen(challengesScrollToTopProvider, (prev, next) {
      if (next > 0 && _scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              const SliverToBoxAdapter(child: _ChallengeHeader()),
              ChallengeListSliver(onStart: _startChallenge),
              const SliverFillRemaining(
                hasScrollBody: false,
                child: SizedBox.shrink(),
              ),
            ],
          ),
          // Designed FAB — pink disc with scaffold-color ring, fixed offset
          // from the bottom edge of the body. The parent shell uses
          // `extendBody: true`, so MediaQuery.padding.bottom here already
          // covers safe area + nav bar.
          Positioned(
            right: AppSpacing.md,
            bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.sm,
            child: _SurpriseMeFab(onTap: () => _onGiveMeOne(context)),
          ),
        ],
      ),
    );
  }
}

// ─── Header (title↔search + stat row + sort sheet + tab pills) ──────────────

class _ChallengeHeader extends ConsumerStatefulWidget {
  const _ChallengeHeader();

  @override
  ConsumerState<_ChallengeHeader> createState() => _ChallengeHeaderState();
}

class _ChallengeHeaderState extends ConsumerState<_ChallengeHeader> {
  bool _searching = false;
  late final TextEditingController _searchCtrl;
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(
      text: ref.read(challengeSearchQueryProvider),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searching = !_searching;
      if (!_searching) {
        _searchCtrl.clear();
        ref.read(challengeSearchQueryProvider.notifier).state = '';
        _searchFocus.unfocus();
      }
    });
    if (_searching) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocus.requestFocus();
      });
    }
  }

  void _openFilters() {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      constraints: const BoxConstraints(maxWidth: double.infinity),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.78,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: syntraSheetDecoration(context),
          clipBehavior: Clip.antiAlias,
          child: ChallengesFilterSheet(scrollController: scrollController),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;

    return Padding(
      // Design: 8 top, 20 left/right, 4 bottom — preserved verbatim.
      padding: EdgeInsets.fromLTRB(20, topPad + 8, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TitleRow(
            searching: _searching,
            searchCtrl: _searchCtrl,
            searchFocus: _searchFocus,
            onToggleSearch: _toggleSearch,
            onOpenFilters: _openFilters,
          ),
          _StatRow(collapsed: _searching),
          const SizedBox(height: 12),
          const _TabPills(),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ─── Title row: Octarine "Challenge" ↔ search input + 2 icon pills ──────────

class _TitleRow extends ConsumerWidget {
  final bool searching;
  final TextEditingController searchCtrl;
  final FocusNode searchFocus;
  final VoidCallback onToggleSearch;
  final VoidCallback onOpenFilters;

  const _TitleRow({
    required this.searching,
    required this.searchCtrl,
    required this.searchFocus,
    required this.onToggleSearch,
    required this.onOpenFilters,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = SyntraSurface.of(context);
    final l = S.of(context);
    final sortMode = ref.watch(challengeSortModeProvider);
    final filterCount = ref.watch(challengeFiltersProvider).activeFilterCount;
    final activeBadge =
        filterCount + (sortMode != ChallengeSortMode.recommended ? 1 : 0);
    final filterActive = activeBadge > 0;
    final titleColor = isDark ? Colors.white : cs.onSurface;

    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Expanded(
            child: ClipRect(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Title — slides up & fades out when search opens.
                  AnimatedPositioned(
                    duration: Duration(milliseconds: searching ? 220 : 280),
                    curve: const Cubic(.16, 1, .3, 1),
                    left: 0,
                    right: 0,
                    top: searching ? -10 : 4,
                    child: AnimatedOpacity(
                      duration: Duration(milliseconds: searching ? 160 : 240),
                      opacity: searching ? 0 : 1,
                      child: IgnorePointer(
                        ignoring: searching,
                        child: Text(
                          l.navChallenge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Octarine',
                            fontWeight: FontWeight.w700,
                            fontSize: 32,
                            height: 1.1,
                            letterSpacing: -0.4,
                            color: titleColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Search field — slides down & fades in when active.
                  AnimatedPositioned(
                    duration: Duration(milliseconds: searching ? 320 : 200),
                    curve: const Cubic(.16, 1, .3, 1),
                    left: 0,
                    right: 0,
                    top: searching ? 2 : 12,
                    child: AnimatedOpacity(
                      duration: Duration(milliseconds: searching ? 260 : 160),
                      opacity: searching ? 1 : 0,
                      child: IgnorePointer(
                        ignoring: !searching,
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: s.bg1,
                            border: Border.all(color: s.bg4, width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          alignment: Alignment.center,
                          child: TextField(
                            controller: searchCtrl,
                            focusNode: searchFocus,
                            onChanged: (v) =>
                                ref
                                        .read(
                                          challengeSearchQueryProvider.notifier,
                                        )
                                        .state =
                                    v,
                            cursorColor: cs.primary,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              color: isDark ? Colors.white : cs.onSurface,
                            ),
                            decoration: InputDecoration(
                              isCollapsed: true,
                              border: InputBorder.none,
                              hintText: l.searchChallengesHint,
                              hintStyle: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          _IconPillButton(
            // Morphs between search and close (X).
            onTap: onToggleSearch,
            child: _MorphingIcon(
              showingFirst: !searching,
              first: Icon(Icons.search_rounded, size: 18, color: s.muted),
              second: Icon(Icons.close_rounded, size: 18, color: s.muted),
            ),
          ),
          const SizedBox(width: 6),
          Stack(
            clipBehavior: Clip.none,
            children: [
              _IconPillButton(
                active: filterActive,
                onTap: onOpenFilters,
                child: Icon(
                  Icons.tune_rounded,
                  size: 18,
                  color: filterActive ? cs.primary : s.muted,
                ),
              ),
              if (activeBadge > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 16,
                    height: 16,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      '$activeBadge',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── 36×36 rounded icon pill button (dark surface, pink-tinted when active)─

class _IconPillButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool active;

  const _IconPillButton({
    required this.child,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final s = SyntraSurface.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        customBorder: const CircleBorder(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? cs.primary.withValues(alpha: 0.14) : s.bg2,
            border: Border.all(
              color: active ? cs.primary.withValues(alpha: 0.40) : s.bg4,
              width: 1,
            ),
            shape: BoxShape.circle,
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─── Rotate-and-fade swap between two icons ─────────────────────────────────

class _MorphingIcon extends StatelessWidget {
  final bool showingFirst;
  final Widget first;
  final Widget second;
  const _MorphingIcon({
    required this.showingFirst,
    required this.first,
    required this.second,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedRotation(
          duration: const Duration(milliseconds: 240),
          curve: const Cubic(.16, 1, .3, 1),
          turns: showingFirst ? 0 : -0.25,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: showingFirst ? 1 : 0,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 240),
              scale: showingFirst ? 1.0 : 0.6,
              child: first,
            ),
          ),
        ),
        AnimatedRotation(
          duration: const Duration(milliseconds: 240),
          curve: const Cubic(.16, 1, .3, 1),
          turns: showingFirst ? 0.25 : 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: showingFirst ? 0 : 1,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 240),
              scale: showingFirst ? 0.6 : 1.0,
              child: second,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Stat row: streak · aura · zone-label (right-aligned) ───────────────────

class _StatRow extends ConsumerWidget {
  final bool collapsed;
  const _StatRow({required this.collapsed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final s = SyntraSurface.of(context);
    final stats = ref.watch(overviewStatsProvider).valueOrNull;
    final weekStreak = stats?['weekStreak'] ?? 0;
    final pendingStreak = stats?['pendingWeekStreak'] ?? 0;
    final streak = weekStreak > 0 ? weekStreak : pendingStreak;
    final aura = ref.watch(availableAuraProvider) ?? 0;
    final level = ref.watch(comfortZoneLevelProvider);
    final levelName = level >= 1 && level <= ComfortZoneLogic.maxLevel
        ? ComfortZoneLogic.levelNames[level]
        : '';

    // Animate row in/out via grid-template-rows equivalent: AnimatedSize +
    // opacity so the search field can claim the vertical space.
    return AnimatedSize(
      duration: const Duration(milliseconds: 280),
      curve: const Cubic(.16, 1, .3, 1),
      alignment: Alignment.topCenter,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: collapsed ? 0 : 1,
        child: collapsed
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.only(top: 6),
                child: DefaultTextStyle(
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        size: 16,
                        color: BrandColors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$streak',
                        style: const TextStyle(color: BrandColors.orange),
                      ),
                      const SizedBox(width: 14),
                      Icon(Icons.star_rounded, size: 16, color: cs.primary),
                      const SizedBox(width: 4),
                      Text(
                        '$aura',
                        style: const TextStyle(color: BrandColors.pinkSoft),
                      ),
                      Expanded(
                        child: Text(
                          level > 0 ? '$levelName · L$level' : '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: s.mutedSubtle,
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

// ─── Tab pills: For you · Saved · Flirt · Done ──────────────────────────────

class _TabPills extends ConsumerWidget {
  const _TabPills();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = S.of(context);
    final current = ref.watch(challengeHomeTabProvider);
    final all = ref.watch(filteredChallengesProvider).valueOrNull ?? const [];
    final completedIds =
        ref.watch(completedChallengeIdsProvider).valueOrNull ?? const {};
    final bookmarks = ref.watch(bookmarkedChallengeIdsProvider);

    final counts = <ChallengeHomeTab, int>{
      ChallengeHomeTab.foryou: all.length,
      ChallengeHomeTab.saved: all.where((c) => bookmarks.contains(c.id)).length,
      ChallengeHomeTab.flirt: all.where((c) => c.flirt).length,
      ChallengeHomeTab.done: all
          .where((c) => completedIds.contains(c.id))
          .length,
    };

    final entries = <(ChallengeHomeTab, String)>[
      (ChallengeHomeTab.foryou, l.tabForYou),
      (ChallengeHomeTab.saved, l.tabSaved),
      (ChallengeHomeTab.flirt, l.tabFlirt),
      (ChallengeHomeTab.done, l.tabDone),
    ];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        // Header already has 20 px horizontal padding via the outer Padding.
        padding: EdgeInsets.zero,
        // Don't hard-clip: the active chip's soft glow extends past the
        // 36 px row and would otherwise be sliced into a rectangle.
        clipBehavior: Clip.none,
        physics: const BouncingScrollPhysics(),
        itemCount: entries.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (tab, label) = entries[i];
          return SyntraChip(
            active: current == tab,
            onTap: () {
              HapticFeedback.selectionClick();
              ref.read(challengeHomeTabProvider.notifier).state = tab;
            },
            label: label,
            count: counts[tab],
          );
        },
      ),
    );
  }
}

// ─── Surprise me FAB ─────────────────────────────────────────────────────────

class _SurpriseMeFab extends StatelessWidget {
  final VoidCallback onTap;
  const _SurpriseMeFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        customBorder: const CircleBorder(),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: cs.primary,
            shape: BoxShape.circle,
            // No ring border — the pink glow alone separates the disc from
            // the list/nav. A scaffold-colored ring reads as a dark band
            // because the FAB floats over surface tiers, not the raw
            // scaffold colour.
          ),
          child: const Icon(
            Icons.casino_rounded,
            size: 26,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
