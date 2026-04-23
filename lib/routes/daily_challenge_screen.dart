import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../generated/l10n.dart';
import '../logic/daily_missions_logic.dart';
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

class DailyMissionsNotifier
    extends AsyncNotifier<List<DailyMission>> {
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
  ConsumerState<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends ConsumerState<DailyChallengeScreen>
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final async = ref.watch(dailyMissionsProvider);
    final stats = ref.watch(overviewStatsProvider);
    final streak = stats.whenOrNull(data: (s) => s['streak']) ?? 0;
    final completedToday = stats.whenOrNull(data: (s) => s['completedToday']) ?? 0;

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: SyntraBlurAppBar(
        title: Text(l.dailyChallenge),
        actions: streak > 0
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_fire_department_rounded,
                          size: 18,
                          color: completedToday > 0
                              ? cs.tertiary
                              : cs.onSurfaceVariant),
                      const SizedBox(width: 3),
                      Text(
                        '$streak',
                        style: tt.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: completedToday > 0
                              ? cs.tertiary
                              : cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ]
            : null,
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (missions) => _MissionBoard(missions: missions),
      ),
    );
  }
}

// ─── Mission board layout ─────────────────────────────────────────────────────

class _MissionBoard extends ConsumerWidget {
  final List<DailyMission> missions;

  const _MissionBoard({required this.missions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: EdgeInsets.only(
        top: SyntraBlurAppBar.topPadding(context) + AppSpacing.sm,
        bottom: AppSpacing.bottomNavBarHeight(context) + AppSpacing.md,
      ),
      children: [
        // ── Subtitle ─────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
          child: Text(
            S.of(context).threeChallengesTodo,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
          ),
        ),

        // ── Progress indicator ───────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: _DayProgress(missions: missions),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Mission cards ────────────────────────────────────────────────────
        ...missions.map(
          (m) => Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            child: _MissionCard(
              mission: m,
              onStart: () => _onStart(context, ref, m),
            ),
          ),
        ),

        // ── Footer ──────────────────────────────────────────────────────────
        const SizedBox(height: AppSpacing.md),
        Center(
          child: TextButton.icon(
            icon: const Icon(Icons.explore_outlined, size: 18),
            label: Text(
              S.of(context).exploreAllChallenges,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            onPressed: () =>
                ref.read(homeTabIndexProvider.notifier).state = 0,
          ),
        ),
      ],
    );
  }

  Future<void> _onStart(
      BuildContext context, WidgetRef ref, DailyMission mission) async {
    if (!context.mounted) return;
    final rewardFactor = await context.pushPriming(
      mission.challenge,
      isDailyMission: true,
    );
    if (rewardFactor != null && rewardFactor > 0 && context.mounted) {
      ref.read(dailyMissionsProvider.notifier).markCompleted(mission.tier);
      refreshStatistics(ref);
    }
  }
}

// ─── Day progress ─────────────────────────────────────────────────────────────

class _DayProgress extends StatelessWidget {
  final List<DailyMission> missions;
  const _DayProgress({required this.missions});

  @override
  Widget build(BuildContext context) {
    final done = missions.where((m) => m.completed).length;
    final total = missions.length;

    return Row(
      children: [
        Expanded(
          child: SyntraXpBar(
            value: total == 0 ? 0 : done / total,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$done / $total',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
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
    final c = mission.challenge;
    final tier = mission.tier;
    final done = mission.completed;
    final l = S.of(context);

    final tierColor = switch (tier) {
      MissionTier.comfort => cs.primary,
      MissionTier.growth => cs.tertiary,
      MissionTier.bold => cs.error,
    };
    final tierLabel = switch (tier) {
      MissionTier.comfort => l.comfortZone,
      MissionTier.growth => l.growthZone,
      MissionTier.bold => l.boldMove,
    };
    final tierIcon = switch (tier) {
      MissionTier.comfort => Icons.spa_outlined,
      MissionTier.growth => Icons.trending_up_rounded,
      MissionTier.bold => Icons.bolt_rounded,
    };

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
            // ── Tappable title area → opens detail screen ──────────────────
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
                    // Tier badge + done check
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm, vertical: 4),
                          decoration: BoxDecoration(
                            color: tierColor.withAlpha(30),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.chipRadius),
                            border: Border.all(color: tierColor.withAlpha(100)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(tierIcon, size: 14, color: tierColor),
                              const SizedBox(width: 4),
                              Text(
                                tierLabel,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: tierColor,
                                      fontWeight: FontWeight.bold,
                                    ),
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
                        if (c.flirt)
                          Padding(
                            padding: const EdgeInsets.only(left: AppSpacing.xs),
                            child: Icon(Icons.favorite,
                                size: 16, color: cs.secondary),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Title
                    Text(
                      c.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    // Description
                    Text(
                      c.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),

            // ── Chips + button ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        MetaChip(
                          icon: Icons.timer_outlined,
                          label: _fmtCompact(c.time),
                        ),
                        MetaChip(
                          icon: Icons.emoji_events_outlined,
                          label: '${c.xp} ${l.auraPoints}',
                        ),
                        MetaChip(
                          icon: _typeIcon(c.type),
                          label: _typeLabel(context, c.type),
                        ),
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

  String _fmtCompact(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

}

