import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../generated/l10n.dart';
import '../providers/statistics_providers.dart';
import '../theme/app_spacing.dart';
import '../widgets/syntra_button.dart';
import 'logbook_page.dart';
import 'statistics/activity_calendar.dart';
import 'statistics/average_mood_card.dart';
import 'statistics/badges_section.dart';
import 'statistics/overview_grid.dart';
import 'statistics/weekly_charts.dart';
import 'statistics/weekly_goal_card.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).yourStatistics)),
      body: RefreshIndicator(
        onRefresh: () async => refreshStatistics(ref),
        child: ListView(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          children: [
            const WeeklyGoalCard(),
            const SizedBox(height: AppSpacing.md),
            const StatsOverviewGrid(),
            const SizedBox(height: AppSpacing.md),
            const BadgesSection(),
            const SizedBox(height: AppSpacing.md),
            const ActivityCalendar(),
            const SizedBox(height: AppSpacing.md),
            SyntraButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LogbookPage()),
              ),
              icon: Icons.history,
              label: Text(S.of(context).challengeLogbook),
            ),
            const SizedBox(height: AppSpacing.md),
            const WeeklyCountChart(),
            const SizedBox(height: AppSpacing.md),
            const WeeklyXpChart(),
            const SizedBox(height: AppSpacing.md),
            const AverageMoodCard(),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
