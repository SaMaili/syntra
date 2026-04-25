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

final completedChallengeIdsProvider = FutureProvider<Set<String>>((ref) {
  ref.watch(statisticsRefreshProvider);
  return LogbookRepository.instance.completedChallengeIds();
});

final latestCompletionDatesProvider =
    FutureProvider<Map<String, DateTime>>((ref) {
  ref.watch(statisticsRefreshProvider);
  return LogbookRepository.instance.latestCompletionDates();
});

final personalBestStreakProvider = FutureProvider<int>((ref) {
  ref.watch(statisticsRefreshProvider);
  return SettingsRepository.instance.loadBestWeeklyStreak();
});

final currentWeekXpProvider = FutureProvider<int>((ref) {
  ref.watch(statisticsRefreshProvider);
  return LogbookRepository.instance.currentWeekXp();
});

final moodHistoryProvider =
    FutureProvider.family<List<int>, String>((ref, challengeId) {
  ref.watch(statisticsRefreshProvider);
  return LogbookRepository.instance.moodHistoryForChallenge(challengeId);
});

final averageMoodProvider =
    FutureProvider<List<({DateTime date, double avg})>>((ref) {
  ref.watch(statisticsRefreshProvider);
  return LogbookRepository.instance.averageMoodPerDay(days: 14);
});

/// Completions toward the next CZL level-up.
/// SharedPreferences reads are synchronous and already flushed when
/// [comfortZoneLevelProvider] notifies, so no extra refresh dependency needed.
final czlCompletionsProvider = Provider<int>((ref) {
  ref.watch(comfortZoneLevelProvider);
  return ref.read(comfortZoneLevelProvider.notifier).getCompletionsAtCurrentLevel();
});

/// XP per ISO year-week for the last 52 weeks (for the weekly history chart).
final weeklyXpByWeekProvider = FutureProvider<Map<String, int>>((ref) {
  ref.watch(statisticsRefreshProvider);
  return LogbookRepository.instance.weeklyXpByWeek(weeks: 52);
});

/// Set of ISO year-week keys that are protected by a streak freeze.
final frozenWeeksProvider = FutureProvider<Set<String>>((ref) {
  ref.watch(statisticsRefreshProvider);
  return SettingsRepository.instance.loadFrozenWeeks();
});

/// Whether a single challenge has been completed at least once.
/// Uses a family so rebuilds are scoped to one challenge instead of the whole set.
final isChallengeCompletedProvider = Provider.family<bool, String>((ref, id) {
  return ref.watch(completedChallengeIdsProvider).valueOrNull?.contains(id) ?? false;
});

/// Convenience helper to bump the refresh counter from anywhere.
void refreshStatistics(WidgetRef ref) {
  ref.read(statisticsRefreshProvider.notifier).state++;
}
