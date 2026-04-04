import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/logbook_repository.dart';
import '../data/settings_repository.dart';
import 'settings_providers.dart' show comfortZoneLevelProvider;

/// Invalidate this to force all statistics providers to reload.
final statisticsRefreshProvider = StateProvider<int>((ref) => 0);

/// Controls which bottom-nav tab is active. Write to navigate programmatically.
final homeTabIndexProvider = StateProvider<int>((ref) => 0);

final overviewStatsProvider = FutureProvider<Map<String, int>>((ref) {
  ref.watch(statisticsRefreshProvider);
  return LogbookRepository.instance.overviewStats();
});

final weeklyXpProvider = FutureProvider<List<int>>((ref) {
  ref.watch(statisticsRefreshProvider);
  return LogbookRepository.instance.weeklyXp();
});

final weeklyCountsProvider =
    FutureProvider<List<List<int>>>((ref) {
  ref.watch(statisticsRefreshProvider);
  return LogbookRepository.instance.weeklyChallengeCounts();
});

final activityHeatmapProvider =
    FutureProvider<Map<String, int>>((ref) {
  ref.watch(statisticsRefreshProvider);
  return LogbookRepository.instance.activityHeatmap();
});

final completedChallengeIdsProvider = FutureProvider<Set<String>>((ref) {
  ref.watch(statisticsRefreshProvider);
  return LogbookRepository.instance.completedChallengeIds();
});

final weeklyProgressProvider = FutureProvider<int>((ref) {
  ref.watch(statisticsRefreshProvider);
  return LogbookRepository.instance.challengesCompletedThisWeek();
});

/// Mutable weekly goal (3 / 5 / 7). Loaded once from SharedPrefs.
final weeklyGoalProvider = StateNotifierProvider<_WeeklyGoalNotifier, int>(
  (_) => _WeeklyGoalNotifier(),
);

class _WeeklyGoalNotifier extends StateNotifier<int> {
  _WeeklyGoalNotifier() : super(5) {
    SettingsRepository.instance.loadWeeklyGoal().then((v) => state = v);
  }

  Future<void> setGoal(int goal) async {
    await SettingsRepository.instance.saveWeeklyGoal(goal);
    state = goal;
  }
}
final personalBestStreakProvider = FutureProvider<int>((ref) {
  ref.watch(statisticsRefreshProvider);
  return SettingsRepository.instance.loadAllTimeMaxStreak();
});

final moodHistoryProvider =
    FutureProvider.family<List<int>, String>((ref, challengeId) {
  ref.watch(statisticsRefreshProvider);
  return LogbookRepository.instance.moodHistoryForChallenge(challengeId);
});

/// Completions toward the next CZL level-up. Reacts to both challenge
/// completions (statisticsRefreshProvider) and level changes.
/// SharedPreferences reads are synchronous, so this is a plain Provider.
final czlCompletionsProvider = Provider<int>((ref) {
  ref.watch(statisticsRefreshProvider);
  ref.watch(comfortZoneLevelProvider);
  return ref.read(comfortZoneLevelProvider.notifier).getCompletionsAtCurrentLevel();
});

/// Convenience helper to bump the refresh counter from anywhere.
void refreshStatistics(WidgetRef ref) {
  ref.read(statisticsRefreshProvider.notifier).state++;
}
