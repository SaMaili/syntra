import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syntra/challenge.dart';

import '../../generated/l10n.dart';
import '../../providers/challenge_providers.dart';
import '../../providers/statistics_providers.dart';
import '../../theme/app_spacing.dart';
import 'challenge_list_item.dart';

class ChallengeListSliver extends ConsumerStatefulWidget {
  final void Function(BuildContext, Challenge) onStart;

  const ChallengeListSliver({required this.onStart, super.key});

  @override
  ConsumerState<ChallengeListSliver> createState() => _ChallengeListSliverState();
}

class _ChallengeListSliverState extends ConsumerState<ChallengeListSliver> {
  static const _pageSize = 20;
  int _visibleCount = _pageSize;

  @override
  Widget build(BuildContext context) {
    // Reset paging and re-enable stagger whenever filters change.
    ref.listen(challengeFiltersProvider, (prev, next) {
      if (mounted) setState(() => _visibleCount = _pageSize);
    });

    final displayedAsync = ref.watch(displayedChallengesProvider);
    final completedIds = ref.watch(completedChallengeIdsProvider).valueOrNull ?? {};

    return displayedAsync.when(
      loading: () => const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => SliverFillRemaining(
        child: Center(child: Text('Error: $e')),
      ),
      data: (filtered) {
        if (filtered.isEmpty) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: ChallengesEmptyState()),
          );
        }

        final showing = filtered.length.clamp(0, _visibleCount);
        final hasMore = showing < filtered.length;

        return SliverMainAxisGroup(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                0,
              ),
              sliver: SliverList.separated(
                itemCount: showing,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, i) => _FadeInItem(
                  key: ValueKey(filtered[i].id),
                  child: ChallengeListItem(
                    challenge: filtered[i],
                    isDone: completedIds.contains(filtered[i].id),
                    onStart: () => widget.onStart(context, filtered[i]),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: hasMore
                  ? _LoadMoreSentinel(
                      onVisible: () =>
                          setState(() => _visibleCount += _pageSize),
                    )
                  : SizedBox(
                      height: AppSpacing.bottomNavBarHeight(context) +
                          AppSpacing.md,
                    ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Sentinel ─────────────────────────────────────────────────────────────────

class _LoadMoreSentinel extends StatefulWidget {
  final VoidCallback onVisible;
  const _LoadMoreSentinel({required this.onVisible});

  @override
  State<_LoadMoreSentinel> createState() => _LoadMoreSentinelState();
}

class _LoadMoreSentinelState extends State<_LoadMoreSentinel> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) { if (mounted) widget.onVisible(); });
  }

  @override
  Widget build(BuildContext context) => const SizedBox(height: 1);
}

// ─── Fade-in wrapper ──────────────────────────────────────────────────────────

class _FadeInItem extends StatefulWidget {
  final Widget child;
  const _FadeInItem({required this.child, super.key});

  @override
  State<_FadeInItem> createState() => _FadeInItemState();
}

class _FadeInItemState extends State<_FadeInItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..forward();
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _opacity,
        child: SlideTransition(position: _slide, child: widget.child),
      );
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class ChallengesEmptyState extends StatelessWidget {
  const ChallengesEmptyState({super.key});

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
