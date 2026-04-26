import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../generated/l10n.dart';
import '../../logic/weekly_streak_logic.dart';
import '../../providers/shop_providers.dart';
import '../../providers/statistics_providers.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/syntra_progress_bar.dart';
import 'filter_bar.dart';

/// Hero header shown at the top of the challenges screen.
class ChallengesHeroHeader extends ConsumerWidget {
  const ChallengesHeroHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(overviewStatsProvider);
    final availableAura = ref.watch(availableAuraProvider) ?? 0;
    final weekStreak = stats.whenOrNull(data: (s) => s['weekStreak']) ?? 0;
    final pendingWeekStreak =
        stats.whenOrNull(data: (s) => s['pendingWeekStreak']) ?? 0;
    final currentWeekAura = ref.watch(currentWeekAuraProvider).valueOrNull ?? 0;
    final freezes = ref.watch(streakFreezesProvider);

    final isStreakActive = weekStreak > 0;
    final displayStreak = weekStreak > 0 ? weekStreak : pendingWeekStreak;
    final progress = (currentWeekAura / kWeeklyAuraThreshold).clamp(0.0, 1.0);

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        MediaQuery.paddingOf(context).top + AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title + inline stat counts ──────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                l.navChallenge,
                style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Icon(Icons.emoji_events_rounded, size: 16, color: cs.primary),
              const SizedBox(width: 3),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                        parent: animation, curve: Curves.easeOut)),
                    child: child,
                  ),
                ),
                child: Text(
                  '$availableAura',
                  key: ValueKey(availableAura),
                  style: tt.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold, color: cs.primary),
                ),
              ),
              if (freezes > 0) ...[
                const SizedBox(width: AppSpacing.md),
                Icon(Icons.ac_unit_rounded, size: 14, color: cs.tertiary),
                const SizedBox(width: 2),
                Text(
                  '×$freezes',
                  style: tt.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold, color: cs.tertiary),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Full-width streak bar ───────────────────────────────────────────
          StreakBar(
            isActive: isStreakActive,
            progress: progress,
            currentWeekAura: currentWeekAura,
            streakLabel: '$displayStreak ${l.weeksShort}',
          ),
        ],
      ),
    );
  }
}

// ─── Streak bar ───────────────────────────────────────────────────────────────

class StreakBar extends StatefulWidget {
  final bool isActive;
  final double progress;
  final int currentWeekAura;
  final String streakLabel;
  final double labelOpacity;

  const StreakBar({
    super.key,
    required this.isActive,
    required this.progress,
    required this.currentWeekAura,
    required this.streakLabel,
    this.labelOpacity = 1.0,
  });

  @override
  State<StreakBar> createState() => _StreakBarState();
}

class _StreakBarState extends State<StreakBar> {
  int _prevAura = 0;

  @override
  void didUpdateWidget(StreakBar old) {
    super.didUpdateWidget(old);
    if (old.currentWeekAura != widget.currentWeekAura) {
      setState(() => _prevAura = old.currentWeekAura);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final labelColor = widget.isActive ? const Color(0xFFFF6D00) : cs.onSurfaceVariant;
    final barColor = cs.primary;

    return Opacity(
      opacity: widget.labelOpacity,
      child: Row(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_fire_department_rounded, size: 15, color: labelColor),
              const SizedBox(width: AppSpacing.xs),
              Text(
                widget.streakLabel,
                style: tt.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: labelColor),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
          ),
          Expanded(
            child: SyntraXpBar(
              value: widget.progress,
              initialValue: (_prevAura / kWeeklyAuraThreshold).clamp(0.0, 1.0),
              minHeight: 5,
              color: barColor,
              backgroundColor: cs.surfaceContainerHighest,
              silent: true,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          TweenAnimationBuilder<int>(
            key: ValueKey('$_prevAura→${widget.currentWeekAura}'),
            tween: IntTween(begin: _prevAura, end: widget.currentWeekAura),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => Text(
              '$value/$kWeeklyAuraThreshold',
              style: tt.labelSmall?.copyWith(color: cs.outline),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header snap physics ──────────────────────────────────────────────────────

// Docks the header to expanded or collapsed on release; fast flings pass through.
class HeaderSnapPhysics extends ScrollPhysics {
  final double snapRange;

  const HeaderSnapPhysics({required this.snapRange, super.parent});

  @override
  HeaderSnapPhysics applyTo(ScrollPhysics? ancestor) {
    return HeaderSnapPhysics(snapRange: snapRange, parent: buildParent(ancestor));
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    final current = position.pixels;

    if (position.maxScrollExtent < snapRange) {
      return super.createBallisticSimulation(position, velocity);
    }

    if (current <= 0 || current >= snapRange) {
      return super.createBallisticSimulation(position, velocity);
    }

    final projected = current + velocity * 0.15;

    if (projected <= 0 || projected >= snapRange) {
      return super.createBallisticSimulation(position, velocity);
    }

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

class ChallengesHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double topPad;
  final bool isWeekComplete;
  final int displayStreak;
  final int availableAura;
  final int freezes;
  final int currentWeekAura;
  final double progress;
  final int filterCount;
  final VoidCallback onGiveMeOne;
  final VoidCallback onFilterTap;

  ChallengesHeaderDelegate({
    required this.topPad,
    required this.isWeekComplete,
    required this.displayStreak,
    required this.availableAura,
    required this.freezes,
    required this.currentWeekAura,
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final t = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    final double labelOpacity = (1.0 - t * 3.33).clamp(0.0, 1.0);
    final double slideOutT = (t * 2.0).clamp(0.0, 1.0);
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
              // 1. Streak Bar
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
                      currentWeekAura: currentWeekAura,
                      streakLabel: '$displayStreak ${l.weeksShort}',
                      labelOpacity: labelOpacity,
                    ),
                  ),
                ),
              ),

              // 2. Filter Bar
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

              // 3. Top Row
              Positioned(
                top: topPad,
                left: 0,
                right: 0,
                height: _compactBarHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Row(
                    children: [
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
                                  Icon(Icons.local_fire_department_rounded, size: 16, color: streakColor),
                                  const SizedBox(width: 3),
                                  Text(
                                    '$displayStreak ${l.weeksShort}',
                                    style: tt.labelLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: streakColor,
                                      fontSize: 15,
                                    ),
                                    softWrap: false,
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                ],
                              ),
                            ),
                          ),
                        ),

                      Expanded(
                        flex: ((1.0 - t) * 1000).clamp(1, 1000).toInt(),
                        child: const SizedBox(),
                      ),

                      if (isWeekComplete) ...[
                        Icon(Icons.local_fire_department_rounded, size: 16, color: streakColor),
                        const SizedBox(width: 3),
                        Text(
                          '$displayStreak ${l.weeksShort}',
                          style: tt.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: streakColor, fontSize: 15),
                        ),
                        const SizedBox(width: AppSpacing.md),
                      ],

                      Icon(Icons.emoji_events_rounded, size: 16, color: cs.primary),
                      const SizedBox(width: 3),
                      _AnimatedAuraCounter(value: availableAura),

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
                                Icon(Icons.ac_unit_rounded, size: 16, color: cs.tertiary),
                                const SizedBox(width: 2),
                                Text(
                                  '×$freezes',
                                  style: tt.labelLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: cs.tertiary,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      Expanded(
                        flex: (t * 1000).clamp(1, 1000).toInt(),
                        child: const SizedBox(),
                      ),

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
  bool shouldRebuild(ChallengesHeaderDelegate old) =>
      old.topPad != topPad ||
      old.isWeekComplete != isWeekComplete ||
      old.displayStreak != displayStreak ||
      old.availableAura != availableAura ||
      old.freezes != freezes ||
      old.currentWeekAura != currentWeekAura ||
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
        style: tt.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: cs.primary, fontSize: 15),
      ),
    );
  }
}
