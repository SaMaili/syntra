import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../generated/l10n.dart';
import '../logic/badges_logic.dart';
import '../providers/badges_providers.dart';
import '../providers/settings_providers.dart';
import '../providers/statistics_providers.dart';
import '../theme/app_spacing.dart';
import '../widgets/badge_widgets.dart';
import '../widgets/syntra_blur_app_bar.dart';

class AllBadgesPage extends ConsumerWidget {
  const AllBadgesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = S.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final statsAsync = ref.watch(overviewStatsProvider);
    final currentLevel = ref.watch(comfortZoneLevelProvider);
    final orderAsync = ref.watch(unlockedBadgesOrderProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: SyntraBlurAppBar(title: Text(l.allBadgesTitle)),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const SizedBox.shrink(),
        data: (stats) {
          final enriched = {...stats, 'czlLevel': currentLevel};
          final earned = BadgesLogic.computeEarned(
              enriched, enriched['weekStreak'] ?? 0);
          final order = orderAsync.maybeWhen(
            data: (v) => v,
            orElse: () => const <String>[],
          );
          final sorted = BadgesLogic.sortByDisplay(
            earned: earned,
            unlockedOrder: order,
          );
          final earnedBadges =
              sorted.where((b) => earned.contains(b.id)).toList();
          final lockedBadges =
              sorted.where((b) => !earned.contains(b.id)).toList();

          return ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              SyntraBlurAppBar.topPadding(context) + AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.bottomNavBarHeight(context),
            ),
            children: [
              _BadgeGroupCard(
                title: l.badgesEarnedSection,
                count: '${earnedBadges.length}/${BadgesLogic.all.length}',
                child: earnedBadges.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm),
                        child: Text(
                          l.badgesLocked,
                          style: tt.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      )
                    : _BadgeGrid(badges: earnedBadges, isEarned: true),
              ),
              const SizedBox(height: AppSpacing.md),
              _BadgeGroupCard(
                title: l.badgesLockedSection,
                count: '${lockedBadges.length}',
                child: lockedBadges.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm),
                        child: Text(
                          l.badgesAllUnlocked,
                          style: tt.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      )
                    : _BadgeGrid(badges: lockedBadges, isEarned: false),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BadgeGroupCard extends StatelessWidget {
  final String title;
  final String count;
  final Widget child;

  const _BadgeGroupCard({
    required this.title,
    required this.count,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: tt.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  count,
                  style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

class _BadgeGrid extends StatelessWidget {
  final List<AppBadge> badges;
  final bool isEarned;

  const _BadgeGrid({required this.badges, required this.isEarned});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        for (final b in badges)
          BadgeTile(
            badge: b,
            isEarned: isEarned,
            size: 60,
            onTap: () => showBadgeInfoSheet(context, b, isEarned),
          ),
      ],
    );
  }
}
