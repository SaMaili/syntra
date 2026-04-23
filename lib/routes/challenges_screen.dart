import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:syntra/data/settings_repository.dart';
import 'package:syntra/challenge.dart';
import 'package:syntra/generated/l10n.dart';
import 'package:syntra/logic/weekly_streak_logic.dart';
import 'package:syntra/providers/challenge_providers.dart';
import 'package:syntra/providers/scroll_providers.dart';
import 'package:syntra/providers/settings_providers.dart';
import 'package:syntra/providers/shop_providers.dart';
import 'package:syntra/providers/statistics_providers.dart';
import 'package:syntra/router.dart';
import 'package:syntra/services/sound_service.dart';

import '../theme/app_spacing.dart';
import 'challenges/challenge_list.dart';
import 'challenges/challenges_header.dart';
import 'challenges/filter_bar.dart';

class ChallengesScreen extends ConsumerStatefulWidget {
  const ChallengesScreen({super.key});

  @override
  ConsumerState<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends ConsumerState<ChallengesScreen>
    with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();
  int _displayWeeklyXp = 0;
  int _displayAura = 0;
  bool _initialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onChallengeFinished() async {
    refreshStatistics(ref);
    final allowed =
        await SettingsRepository.instance.checkAndMarkReviewRequest();
    if (!allowed) return;
    final review = InAppReview.instance;
    if (await review.isAvailable()) review.requestReview();
  }

  Future<void> _startChallenge(BuildContext context, Challenge challenge) async {
    SoundService.playDing(enabled: ref.read(soundEffectsEnabledProvider));
    final result = await context.pushPriming(challenge);
    if (result != null) {
      _onChallengeFinished();
      // Force a rebuild on return. The ref.listener fired while we were
      // covered by the pushed route (isVisible=false → skipped), and when the
      // provider value doesn't change again no rebuild triggers the build()
      // fallback — without this setState, _displayAura stays at the
      // pre-challenge value and the counter never animates.
      if (mounted) setState(() {});
    }
  }

  void _onGiveMeOne(BuildContext context) {
    final allAsync = ref.read(filteredChallengesProvider);
    final list = allAsync.value;
    if (list == null || list.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).noChallengesFound),
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
          content: Text(S.of(context).noChallengesFound),
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

    ref.listen(challengesScrollToTopProvider, (prev, next) {
      if (next > 0 && _scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });

    final topPad = MediaQuery.paddingOf(context).top;
    
    // Watch all stats directly in the screen so the Sliver definitively rebuilds
    final statsAsync = ref.watch(overviewStatsProvider);
    final s = statsAsync.valueOrNull;
    final weekStreak = s?['weekStreak'] ?? 0;
    final pendingWeekStreak = s?['pendingWeekStreak'] ?? 0;
    final displayStreak = weekStreak > 0 ? weekStreak : pendingWeekStreak;
    final availableXp = ref.watch(availableAuraProvider) ?? 0;
    final freezes = ref.watch(streakFreezesProvider);
    final currentWeekXp = ref.watch(currentWeekXpProvider).valueOrNull ?? 0;

    if (!_initialized) {
      _displayWeeklyXp = currentWeekXp;
      _displayAura = availableXp;
      _initialized = true;
    }

    ref.listen(currentWeekXpProvider, (prev, next) {
      final nextVal = next.valueOrNull ?? 0;

      if (nextVal > _displayWeeklyXp) {
        final isVisible = ModalRoute.of(context)?.isCurrent ?? false;
        if (isVisible) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) setState(() => _displayWeeklyXp = nextVal);
          });
        }
        // If in background, leave _displayWeeklyXp unchanged;
        // the postFrameCallback below will catch it on next visibility.
      } else if (nextVal < _displayWeeklyXp) {
        setState(() => _displayWeeklyXp = nextVal);
      }
    });

    ref.listen<int?>(availableAuraProvider, (prev, next) {
      final nextVal = next ?? 0;
      if (nextVal > _displayAura) {
        final isVisible = ModalRoute.of(context)?.isCurrent ?? false;
        if (isVisible) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && _displayAura < nextVal) {
              setState(() => _displayAura = nextVal);
            }
          });
        }
        // If in background, leave _displayAura unchanged;
        // the postFrameCallback below will catch it on next visibility.
      } else if (nextVal < _displayAura) {
        setState(() => _displayAura = nextVal);
      }
    });

    // If we return from background and there's a pending increase, start it.
    final isCurrent = ModalRoute.of(context)?.isCurrent ?? false;
    if (isCurrent && _displayAura < availableXp) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _displayAura < availableXp) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && _displayAura < availableXp) {
              setState(() => _displayAura = availableXp);
            }
          });
        }
      });
    }

    if (isCurrent && _displayWeeklyXp < currentWeekXp) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // We check the condition again inside the callback to be safe.
        if (mounted && _displayWeeklyXp < currentWeekXp) {
          // User requested: "wait 2 seconds then rise"
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && _displayWeeklyXp < currentWeekXp) {
              setState(() => _displayWeeklyXp = currentWeekXp);
            }
          });
        }
      });
    }

    final progress = (_displayWeeklyXp / kWeeklyXpThreshold).clamp(0.0, 1.0);
    final isWeekComplete = progress >= 1.0;
    
    final filters = ref.watch(challengeFiltersProvider);
    final filterCount = filters.activeFilterCount;

    final double headerCollapseRange = isWeekComplete ? 56.0 : 84.0;
    final physics = _HeaderSnapPhysics(
      snapRange: headerCollapseRange,
      parent: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
    );

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        physics: physics,
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _ChallengesHeaderDelegate(
              topPad: topPad,
              isWeekComplete: isWeekComplete,
              displayStreak: displayStreak,
              availableXp: _displayAura,
              freezes: freezes,
              currentWeekXp: _displayWeeklyXp,
              progress: progress,
              filterCount: filterCount,
              onGiveMeOne: () => _onGiveMeOne(context),
              onFilterTap: () => ChallengesFilterBar.openSheet(context),
            ),
          ),
          ChallengeListSliver(onStart: _startChallenge),
          // Guarantees maxScrollExtent >= snapRange so the header can fully dock.
          const SliverFillRemaining(
            hasScrollBody: false,
            child: SizedBox.shrink(),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: headerCollapseRange),
          ),
        ],
      ),
    );
  }
}

// Docks the header to expanded or collapsed on release; fast flings pass through.
class _HeaderSnapPhysics extends ScrollPhysics {
  final double snapRange;

  const _HeaderSnapPhysics({required this.snapRange, super.parent});

  @override
  _HeaderSnapPhysics applyTo(ScrollPhysics? ancestor) {
    return _HeaderSnapPhysics(snapRange: snapRange, parent: buildParent(ancestor));
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    final current = position.pixels;

    // Not enough content to fully collapse → don't interfere.
    if (position.maxScrollExtent < snapRange) {
      return super.createBallisticSimulation(position, velocity);
    }

    // Outside the header's collapse band → normal list scrolling.
    if (current <= 0 || current >= snapRange) {
      return super.createBallisticSimulation(position, velocity);
    }

    // Rough kinematic projection of where natural physics would land.
    final projected = current + velocity * 0.15;

    // Fling that would exit the band anyway → let it through.
    if (projected <= 0 || projected >= snapRange) {
      return super.createBallisticSimulation(position, velocity);
    }

    // Pick nearest dock point, biased by projected landing.
    final target = projected < snapRange / 2 ? 0.0 : snapRange;

    if ((target - current).abs() < 0.5) return null;

    return ScrollSpringSimulation(
      spring,
      current,
      target,
      velocity,
      tolerance: toleranceFor(position),
    );
  }
}

// ─── Collapsible header delegate ─────────────────────────────────────────────

class _ChallengesHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double topPad;
  final bool isWeekComplete;
  final int displayStreak;
  final int availableXp;
  final int freezes;
  final int currentWeekXp;
  final double progress;
  final int filterCount;
  final VoidCallback onGiveMeOne;
  final VoidCallback onFilterTap;

  _ChallengesHeaderDelegate({
    required this.topPad,
    required this.isWeekComplete,
    required this.displayStreak,
    required this.availableXp,
    required this.freezes,
    required this.currentWeekXp,
    required this.progress,
    required this.filterCount,
    required this.onGiveMeOne,
    required this.onFilterTap,
  });

  static const _headerContent = 76.0;
  static const _filterBarHeight = 56.0;
  static const _compactBarHeight = 48.0;

  @override
  double get maxExtent => topPad + (isWeekComplete ? 48.0 : _headerContent) + _filterBarHeight;

  @override
  double get minExtent => topPad + _compactBarHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final t = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    
    // Bottom bar label fades out first (t=0.0 to 0.3)
    final double labelOpacity = (1.0 - t * 3.33).clamp(0.0, 1.0);

    // Items that slide away when scrolling up (Challenge title, freezes)
    final double slideOutT = (t * 2.0).clamp(0.0, 1.0);

    // Buttons fly in (t=0.5 to 1.0)
    final double buttonsT = ((t - 0.5) * 2).clamp(0.0, 1.0);
    final double filterBarOpacity = (1.0 - buttonsT).clamp(0.0, 1.0);

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);
    final streakColor = isWeekComplete ? const Color(0xFFFF6D00) : cs.onSurfaceVariant;

    return SizedBox(
      height: maxExtent,
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ClipRect(
          child: Stack(
            children: [
              // 1. Streak Bar (sits below Top Row)
              Positioned(
                top: topPad + 48,
                left: 0,
                right: 0,
                child: Offstage(
                  offstage: isWeekComplete,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: StreakBar(
                      key: const ValueKey('streak_bar'),
                      isActive: isWeekComplete,
                      progress: progress,
                      currentWeekXp: currentWeekXp,
                      streakLabel: '$displayStreak ${l.weeksShort}',
                      labelOpacity: labelOpacity,
                    ),
                  ),
                ),
              ),

              // 2. Filter Bar (sits at bottom, moves up over streak bar, fades out in second half)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: filterBarOpacity,
                  child: IgnorePointer(
                    ignoring: filterBarOpacity < 0.5,
                    child: ChallengesFilterBar(onGiveMeOne: onGiveMeOne),
                  ),
                ),
              ),

              // 3. Top Row (Always at top, items inside transition smoothly)
              Positioned(
                top: topPad,
                left: 0,
                right: 0,
                height: _compactBarHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Row(
                    children: [
                      // Left side: Title -> Flame transition
                      Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: 1.0 - slideOutT,
                        child: Transform.translate(
                          offset: Offset(-slideOutT * 40, 0),
                          child: Opacity(
                            opacity: 1.0 - slideOutT,
                            child: Text(
                              l.navChallenge,
                              style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              softWrap: false,
                            ),
                          ),
                        ),
                      ),
                      if (!isWeekComplete)
                        Align(
                          alignment: Alignment.centerLeft,
                          widthFactor: slideOutT,
                          child: Transform.translate(
                            offset: Offset((1.0 - slideOutT) * 40, 0),
                            child: Opacity(
                              opacity: slideOutT,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.local_fire_department_rounded,
                                    size: 16,
                                    color: streakColor,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '$displayStreak ${l.weeksShort}',
                                    style: tt.labelLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: streakColor,
                                    ),
                                    softWrap: false,
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                ],
                              ),
                            ),
                          ),
                        ),

                      // Space that shrinks as we scroll up
                      Expanded(
                        flex: ((1.0 - t) * 1000).clamp(1, 1000).toInt(),
                        child: const SizedBox(),
                      ),

                      // Right side: Streak (if active), Aura, Freezes
                      if (isWeekComplete) ...[
                        Icon(Icons.local_fire_department_rounded, size: 16, color: streakColor),
                        const SizedBox(width: 3),
                        Text(
                          '$displayStreak ${l.weeksShort}',
                          style: tt.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: streakColor),
                        ),
                        const SizedBox(width: AppSpacing.md),
                      ],

                      // Aura
                      Icon(Icons.emoji_events_rounded, size: 16, color: cs.primary),
                      const SizedBox(width: 3),
                      _AnimatedAuraCounter(value: availableXp),
                      
                      // Freezes (fades out and shrinks when scrolling)
                      if (freezes > 0)
                        Align(
                          alignment: Alignment.centerLeft,
                          widthFactor: 1.0 - slideOutT,
                          child: Opacity(
                            opacity: 1.0 - slideOutT,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(width: AppSpacing.md),
                                Icon(Icons.ac_unit_rounded, size: 14, color: cs.tertiary),
                                const SizedBox(width: 2),
                                Text(
                                  '×$freezes',
                                  style: tt.labelMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: cs.tertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Space that grows as we scroll up
                      Expanded(
                        flex: (t * 1000).clamp(1, 1000).toInt(),
                        child: const SizedBox(),
                      ),

                      // Right side: Filter button flies in
                      Align(
                        alignment: Alignment.centerRight,
                        widthFactor: buttonsT,
                        child: Transform.translate(
                          offset: Offset((1.0 - buttonsT) * 40, 0),
                          child: Opacity(
                            opacity: buttonsT,
                            child: Badge(
                              isLabelVisible: filterCount > 0,
                              label: Text('$filterCount'),
                              child: IconButton(
                                icon: const Icon(Icons.tune_rounded),
                                onPressed: onFilterTap,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_ChallengesHeaderDelegate old) =>
      old.topPad != topPad ||
      old.isWeekComplete != isWeekComplete ||
      old.displayStreak != displayStreak ||
      old.availableXp != availableXp ||
      old.freezes != freezes ||
      old.currentWeekXp != currentWeekXp ||
      old.progress != progress ||
      old.filterCount != filterCount ||
      old.onGiveMeOne != onGiveMeOne ||
      old.onFilterTap != onFilterTap;
}

// ─── Animated aura counter ────────────────────────────────────────────────────

class _AnimatedAuraCounter extends StatefulWidget {
  final int value;
  const _AnimatedAuraCounter({required this.value});

  @override
  State<_AnimatedAuraCounter> createState() => _AnimatedAuraCounterState();
}

class _AnimatedAuraCounterState extends State<_AnimatedAuraCounter> {
  late int _prevValue;

  @override
  void initState() {
    super.initState();
    _prevValue = widget.value;
  }

  @override
  void didUpdateWidget(_AnimatedAuraCounter old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      setState(() => _prevValue = old.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<int>(
      key: ValueKey('$_prevValue→${widget.value}'),
      tween: IntTween(begin: _prevValue, end: widget.value),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => Text(
        '$value',
        style: tt.labelLarge
            ?.copyWith(fontWeight: FontWeight.bold, color: cs.primary),
      ),
    );
  }
}
