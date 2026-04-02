import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../generated/l10n.dart';
import '../logic/daily_missions_logic.dart';
import '../providers/settings_providers.dart';
import '../providers/statistics_providers.dart';
import '../theme/app_spacing.dart';
import '../widgets/syntra_button.dart';
import '../widgets/syntra_progress_bar.dart';
import 'priming_screen.dart';

// ─── Provider ─────────────────────────────────────────────────────────────────

final dailyMissionsProvider =
    AsyncNotifierProvider<DailyMissionsNotifier, List<DailyMission>>(
        DailyMissionsNotifier.new);

class DailyMissionsNotifier
    extends AsyncNotifier<List<DailyMission>> {
  @override
  Future<List<DailyMission>> build() async {
    final lang = ref.watch(activeLocaleProvider);
    return DailyMissionsLogic().getTodayMissions(lang);
  }

  Future<void> markCompleted(MissionTier tier) async {
    await DailyMissionsLogic().markCompleted(tier);
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

    return Scaffold(
      body: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (missions) => _MissionBoard(
            missions: missions,
            streak: streak,
            completedToday: completedToday,
          ),
        ),
      ),
    );
  }
}

// ─── Mission board layout ─────────────────────────────────────────────────────

class _MissionBoard extends ConsumerWidget {
  final List<DailyMission> missions;
  final int streak;
  final int completedToday;

  const _MissionBoard({
    required this.missions,
    required this.streak,
    required this.completedToday,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      children: [
        // ── Header ──────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).todaysMissions,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      S.of(context).threeChallengesTodo,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              if (streak > 0)
                _StreakBadge(
                  streak: streak,
                  isActiveToday: completedToday > 0,
                ),
            ],
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
    final navigator = Navigator.of(context);

    navigator.push<void>(
      MaterialPageRoute(
        builder: (_) => PrimingScreen(
          challenge: mission.challenge,
          onDone: (rewardFactor) {
            // Called from ActiveChallengeScreen before it pops to root.
            // rewardFactor > 0 means the user completed (not aborted).
            if (rewardFactor > 0) {
              ref
                  .read(dailyMissionsProvider.notifier)
                  .markCompleted(mission.tier);
              refreshStatistics(ref);
            }
          },
        ),
      ),
    );
  }
}

// ─── Streak badge ─────────────────────────────────────────────────────────────

class _StreakBadge extends StatelessWidget {
  final int streak;
  final bool isActiveToday;

  const _StreakBadge({required this.streak, this.isActiveToday = true});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = isActiveToday ? cs.tertiary : cs.outline;
    final bgColor = isActiveToday
        ? cs.tertiary.withValues(alpha: 0.1)
        : cs.surfaceContainerHighest;
    final borderColor = isActiveToday
        ? cs.tertiary.withValues(alpha: 0.3)
        : cs.outlineVariant;

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            '$streak day${streak == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
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

class _MissionCard extends StatefulWidget {
  final DailyMission mission;
  final VoidCallback onStart;

  const _MissionCard({required this.mission, required this.onStart});

  @override
  State<_MissionCard> createState() => _MissionCardState();
}

class _MissionCardState extends State<_MissionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final m = widget.mission;
    final c = m.challenge;
    final tier = m.tier;
    final done = m.completed;

    final tierColor = switch (tier) {
      MissionTier.comfort => cs.primary,
      MissionTier.growth => cs.tertiary,
      MissionTier.bold => cs.error,
    };
    final l = S.of(context);
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

    return AnimatedOpacity(
      opacity: done ? 0.55 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tier badge row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: 3),
                    decoration: BoxDecoration(
                      color: tierColor.withAlpha(30),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.chipRadius),
                      border: Border.all(color: tierColor.withAlpha(100)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(tierIcon, size: 12, color: tierColor),
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
                  const Spacer(),
                  if (done)
                    Icon(Icons.check_circle_rounded,
                        size: 20, color: cs.primary),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // Title + teaser
              Text(
                c.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: done ? TextDecoration.lineThrough : null,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                c.description,
                maxLines: _expanded ? null : 2,
                overflow:
                    _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Meta chips + Start button
              Row(
                children: [
                  _MetaChip(
                    icon: Icons.timer_outlined,
                    label: _fmtTime(c.time),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _MetaChip(
                    icon: Icons.emoji_events_outlined,
                    label: '${c.xp} XP',
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _MetaChip(
                    icon: c.type == 'group'
                        ? Icons.group_outlined
                        : Icons.person_outlined,
                    label: c.type == 'group' ? l.group : l.solo,
                  ),
                  const Spacer(),
                  if (!done)
                  SyntraButton.small(
                    onPressed: widget.onStart,
                    color: tierColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(S.of(context).start),
                    ),
                  ),
                ],
              ),

              // Details toggle
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 16,
                        color: cs.outline,
                      ),
                      Text(
                        _expanded ? l.lessLabel : l.detailsLabel,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: cs.outline),
                      ),
                    ],
                  ),
                ),
              ),

              // Expanded hint
              if (_expanded && c.notSureWhatToSay.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  ),
                  child: Text(
                    '💬 ${c.notSureWhatToSay}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _fmtTime(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return s == 0 ? '${m}m' : '${m}m ${s}s';
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
        Icon(icon, size: 12, color: cs.outline),
        const SizedBox(width: 2),
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

