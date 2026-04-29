import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../generated/l10n.dart';
import '../providers/scroll_providers.dart';
import '../providers/statistics_providers.dart';
import '../theme/app_spacing.dart';
import '../widgets/syntra_blur_app_bar.dart';
import '../widgets/syntra_button.dart';
import 'logbook_page.dart';
import 'settings_screen.dart' show ComfortZoneLevelCard;
import 'statistics/activity_calendar.dart' show WeeklyAuraChart;
import 'statistics/average_mood_card.dart';
import 'statistics/badges_section.dart';
import 'statistics/overall_prediction_card.dart';
import 'statistics/overview_grid.dart';
import 'statistics/weekly_charts.dart';

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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: SyntraBlurAppBar(title: Text(S.of(context).profileTitle)),
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
            const ComfortZoneLevelCard(),
            const SizedBox(height: AppSpacing.md),
            const StatsOverviewGrid(),
            const SizedBox(height: AppSpacing.md),
            SyntraButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LogbookPage()),
              ),
              icon: Icons.history,
              label: Text(S.of(context).challengeLogbook),
            ),
            const SizedBox(height: AppSpacing.md),
            const BadgesSection(),
            const SizedBox(height: AppSpacing.md),
            const WeeklyAuraChart(),
            const SizedBox(height: AppSpacing.md),
            const WeeklyXpChart(),
            const SizedBox(height: AppSpacing.md),
            const OverallPredictionCard(),
            const SizedBox(height: AppSpacing.md),
            const AverageMoodCard(),
          ],
        ),
      ),
    );
  }
}
