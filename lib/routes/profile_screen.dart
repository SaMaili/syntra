import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../generated/l10n.dart';
import '../logic/badges_logic.dart';
import '../providers/badges_providers.dart' show unlockedBadgesOrderProvider;
import '../providers/scroll_providers.dart';
import '../providers/settings_providers.dart';
import '../providers/statistics_providers.dart';
import '../router.dart';
import '../theme/app_spacing.dart';
import '../theme/brand_colors.dart';
import '../widgets/syntra_blur_app_bar.dart';
import 'logbook_page.dart';
import 'statistics/activity_calendar.dart' show WeeklyAuraChart;
import 'statistics/average_mood_card.dart';
import 'statistics/nav_row_card.dart';
import 'statistics/overall_prediction_card.dart';
import 'statistics/overview_grid.dart';
import 'statistics/weekly_aura_daily_card.dart';
import 'statistics/zone_hero_card.dart';

/// Profile redesign — zone hero on top, dense stats strip, Logbook/Badges
/// nav rows, then the three differentiated charts in importance order
/// (Prediction → Mood → Aura week → Activity).
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    ref.listen(profileScrollToTopProvider, (prev, next) {
      if (next > 0 && _scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });

    final l = S.of(context);
    final statsAsync = ref.watch(overviewStatsProvider);
    final currentLevel = ref.watch(comfortZoneLevelProvider);
    final orderAsync = ref.watch(unlockedBadgesOrderProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: SyntraBlurAppBar(title: Text(l.profileTitle)),
      body: RefreshIndicator(
        onRefresh: () async => refreshStatistics(ref),
        child: ListView(
          controller: _scrollController,
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            SyntraBlurAppBar.topPadding(context) + AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.bottomNavBarHeight(context) + AppSpacing.md,
          ),
          children: [
            // ── Hero zone card ─────────────────────────────────────────────
            const ZoneHeroCard(),
            const SizedBox(height: AppSpacing.sm),
            const ZoneLadder(),
            const SizedBox(height: AppSpacing.lg),

            // ── Dense 3×2 stats strip ──────────────────────────────────────
            const StatsOverviewGrid(),
            const SizedBox(height: AppSpacing.md),

            // ── Logbook + Badges nav rows ──────────────────────────────────
            statsAsync.when(
              loading: () => const _NavRowsSkeleton(),
              error: (_, __) => const _NavRowsSkeleton(),
              data: (stats) {
                final completed = stats['completedAllTime'] ?? 0;
                final enriched = {...stats, 'czlLevel': currentLevel};
                final earned = BadgesLogic.computeEarned(
                    enriched, enriched['weekStreak'] ?? 0);
                return Row(
                  children: [
                    Expanded(
                      child: NavRowCard(
                        icon: Icons.history_rounded,
                        label: l.profileLogbookLabel,
                        subtitle: l.profileLogbookEntries(completed),
                        tint: Theme.of(context).colorScheme.primary,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const LogbookPage()),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: NavRowCard(
                        icon: Icons.military_tech_rounded,
                        label: l.profileBadgesLabel,
                        subtitle: l.profileBadgesCount(
                            earned.length, BadgesLogic.all.length),
                        tint: BrandColors.amber,
                        onTap: () => context.goAllBadges(),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Prediction vs Reality (most important — placed first) ─────
            const OverallPredictionCard(),
            const SizedBox(height: AppSpacing.md),

            // ── Mood trend ────────────────────────────────────────────────
            const AverageMoodCard(),
            const SizedBox(height: AppSpacing.md),

            // ── Aura this week (daily bars + dashed goal line) ───────────
            const WeeklyAuraDailyCard(),
            const SizedBox(height: AppSpacing.md),

            // ── Activity (months × weeks, orange/blue/grey) ──────────────
            const WeeklyAuraChart(),

            // Unused order-hint to keep the unlockedBadgesOrderProvider warm
            // (it's used by the BadgesSection that we no longer render here
            // but want to keep up-to-date for the all-badges page).
            if (orderAsync.hasValue) const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

class _NavRowsSkeleton extends StatelessWidget {
  const _NavRowsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }
}
