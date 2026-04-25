import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../generated/l10n.dart';
import '../logic/daily_missions_logic.dart';
import '../providers/scroll_providers.dart';
import '../providers/settings_providers.dart';
import '../providers/shared_preferences_provider.dart';
import '../providers/statistics_providers.dart';
import '../router.dart';
import '../theme/app_spacing.dart';
import '../widgets/syntra_blur_app_bar.dart';
import '../widgets/syntra_button.dart';
import '../widgets/syntra_progress_bar.dart';
import 'challenge_detail_screen.dart';
import 'challenges/challenge_list_item.dart' show MetaChip;

// ─── Provider ─────────────────────────────────────────────────────────────────

final dailyMissionsProvider =
    AsyncNotifierProvider<DailyMissionsNotifier, List<DailyMission>>(
        DailyMissionsNotifier.new);

class DailyMissionsNotifier extends AsyncNotifier<List<DailyMission>> {
  @override
  Future<List<DailyMission>> build() async {
    final lang = ref.watch(activeLocaleProvider);
    final prefs = ref.read(sharedPreferencesProvider);
    return DailyMissionsLogic().getTodayMissions(lang, prefs);
  }

  Future<void> markCompleted(MissionTier tier) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await DailyMissionsLogic().markCompleted(tier, prefs);
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current
          .map((m) => m.tier == tier ? m.copyWith(completed: true) : m)
          .toList(),
    );
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class DailyChallengeScreen extends ConsumerStatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  ConsumerState<DailyChallengeScreen> createState() =>
      _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends ConsumerState<DailyChallengeScreen>
    with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _startMission(DailyMission mission) async {
    final rewardFactor = await context.pushPriming(
      mission.challenge,
      isDailyMission: true,
    );
    if (rewardFactor != null && rewardFactor > 0 && mounted) {
      ref.read(dailyMissionsProvider.notifier).markCompleted(mission.tier);
      refreshStatistics(ref);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    ref.listen(dailyScrollToTopProvider, (prev, next) {
      if (next > 0 && _scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });

    final async = ref.watch(dailyMissionsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: SyntraBlurAppBar(
        title: Text(S.of(context).dailyChallenge),
        actions: const [_StreakBadge()],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (missions) => ListView(
          controller: _scrollController,
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            SyntraBlurAppBar.topPadding(context) + AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.bottomNavBarHeight(context) + AppSpacing.md,
          ),
          children: [
            _ProgressCard(missions: missions),
            const SizedBox(height: AppSpacing.md),
            for (final m in missions) ...[
              _MissionCard(mission: m, onStart: () => _startMission(m)),
              const SizedBox(height: AppSpacing.sm),
            ],
            const SizedBox(height: AppSpacing.sm),
            const _ExploreAllButton(),
          ],
        ),
      ),
    );
  }
}

// ─── Streak badge (app-bar action) ────────────────────────────────────────────

class _StreakBadge extends ConsumerWidget {
  const _StreakBadge();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(overviewStatsProvider);
    final streak = stats.whenOrNull(data: (s) => s['streak']) ?? 0;
    if (streak <= 0) return const SizedBox.shrink();

    final completedToday =
        stats.whenOrNull(data: (s) => s['completedToday']) ?? 0;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color = completedToday > 0 ? cs.tertiary : cs.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.md),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department_rounded, size: 18, color: color),
          const SizedBox(width: 3),
          Text(
            '$streak',
            style: tt.labelLarge
                ?.copyWith(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

// ─── Progress card ────────────────────────────────────────────────────────────

class _ProgressCard extends StatelessWidget {
  final List<DailyMission> missions;
  const _ProgressCard({required this.missions});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);
    final done = missions.where((m) => m.completed).length;
    final total = missions.length;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.threeChallengesTodo,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: SyntraXpBar(value: total == 0 ? 0 : done / total),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '$done / $total',
                  style: tt.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Mission card ─────────────────────────────────────────────────────────────

class _MissionCard extends StatelessWidget {
  final DailyMission mission;
  final VoidCallback onStart;

  const _MissionCard({required this.mission, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);
    final c = mission.challenge;
    final done = mission.completed;

    final tierColor = _tierColor(cs, mission.tier);
    final cardColor = done
        ? Color.lerp(
            Theme.of(context).cardTheme.color ?? cs.surfaceContainer,
            const Color(0xFF10B981),
            0.12,
          )
        : null;

    return AnimatedOpacity(
      opacity: done ? 0.55 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Card(
        margin: EdgeInsets.zero,
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
                padding: const EdgeInsets.fromLTRB(AppSpacing.md,
                    AppSpacing.md, AppSpacing.md, AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TierHeader(
                      tier: mission.tier,
                      done: done,
                      flirt: c.flirt,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      c.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      c.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: tt.bodyMedium
                          ?.copyWith(color: cs.onSurfaceVariant),
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
                  Expanded(
                    child: Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        MetaChip(
                            icon: Icons.timer_outlined,
                            label: _fmtDuration(c.time)),
                        MetaChip(
                            icon: Icons.emoji_events_outlined,
                            label: '${c.xp} ${l.auraPoints}'),
                        MetaChip(
                            icon: _typeIcon(c.type),
                            label: _typeLabel(l, c.type)),
                      ],
                    ),
                  ),
                  if (!done) ...[
                    const SizedBox(width: AppSpacing.sm),
                    SyntraButton.small(
                      onPressed: onStart,
                      color: tierColor,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(l.letsGo),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onInfoTap(BuildContext context) async {
    final start = await showChallengeDetailSheet(context, mission.challenge);
    if (start == true) onStart();
  }
}

// ─── Tier header (chip + status icons) ────────────────────────────────────────

class _TierHeader extends StatelessWidget {
  final MissionTier tier;
  final bool done;
  final bool flirt;
  const _TierHeader(
      {required this.tier, required this.done, required this.flirt});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);
    final color = _tierColor(cs, tier);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm, vertical: 4),
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
            border: Border.all(color: color.withAlpha(100)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_tierIcon(tier), size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                _tierLabel(l, tier),
                style: tt.labelSmall?.copyWith(
                    color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        if (done)
          const Padding(
            padding: EdgeInsets.only(left: AppSpacing.xs),
            child: Icon(Icons.check_circle_rounded,
                size: 16, color: Color(0xFF10B981)),
          ),
        if (flirt)
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs),
            child: Icon(Icons.favorite, size: 16, color: cs.secondary),
          ),
      ],
    );
  }
}

// ─── Explore-all footer button ────────────────────────────────────────────────

class _ExploreAllButton extends ConsumerWidget {
  const _ExploreAllButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: TextButton.icon(
        icon: const Icon(Icons.explore_outlined, size: 18),
        label: Text(
          S.of(context).exploreAllChallenges,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        onPressed: () => ref.read(homeTabIndexProvider.notifier).state = 0,
      ),
    );
  }
}

// ─── Tier helpers ─────────────────────────────────────────────────────────────

Color _tierColor(ColorScheme cs, MissionTier tier) => switch (tier) {
      MissionTier.comfort => cs.primary,
      MissionTier.growth => cs.tertiary,
      MissionTier.bold => cs.error,
    };

String _tierLabel(S l, MissionTier tier) => switch (tier) {
      MissionTier.comfort => l.comfortZone,
      MissionTier.growth => l.growthZone,
      MissionTier.bold => l.boldMove,
    };

IconData _tierIcon(MissionTier tier) => switch (tier) {
      MissionTier.comfort => Icons.spa_outlined,
      MissionTier.growth => Icons.trending_up_rounded,
      MissionTier.bold => Icons.bolt_rounded,
    };

IconData _typeIcon(String type) => switch (type) {
      'group' => Icons.group_outlined,
      'coop' => Icons.people_alt_outlined,
      'dare' => Icons.bolt_outlined,
      _ => Icons.person_outlined,
    };

String _typeLabel(S l, String type) => switch (type) {
      'group' => l.group,
      'coop' => l.coop,
      'dare' => l.dare,
      _ => l.solo,
    };

String _fmtDuration(int seconds) {
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}
