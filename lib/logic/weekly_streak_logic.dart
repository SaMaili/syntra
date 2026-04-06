/// Pure, side-effect-free logic for the weekly streak system.
///
/// A week is "active" when the user earned ≥ [kWeeklyXpThreshold] Aura Points
/// in that Mon–Sun period. The streak counts consecutive *completed* weeks
/// (the current in-progress week never counts toward the streak yet).
library;

/// Minimum XP to earn in a Mon–Sun week for it to count as an active week.
const int kWeeklyXpThreshold = 300;

class WeeklyStreakLogic {
  WeeklyStreakLogic._();

  /// Returns an ISO year-week string for [date], e.g. `"2026-W14"`.
  ///
  /// Uses ISO 8601 week numbering: weeks start on Monday, week 01 is the week
  /// containing the first Thursday of the year.
  static String isoYearWeek(DateTime date) {
    // Shift to Thursday of the same ISO week to get the correct ISO year.
    final thursday = date.add(Duration(days: 4 - date.weekday));
    final jan4 = DateTime(thursday.year, 1, 4);
    final startOfWeek1 =
        jan4.subtract(Duration(days: jan4.weekday - 1));
    final weekNumber =
        ((thursday.difference(startOfWeek1).inDays) ~/ 7) + 1;
    return '${thursday.year}-W${weekNumber.toString().padLeft(2, '0')}';
  }

  /// Returns the ISO year-week of the Monday that starts the week containing [date].
  static DateTime startOfIsoWeek(DateTime date) {
    return DateTime(date.year, date.month, date.day - (date.weekday - 1));
  }

  /// Counts consecutive weeks (including the current in-progress week) where
  /// XP ≥ [threshold], going backwards from today's week.
  ///
  /// The current week counts as soon as its XP reaches the threshold — the
  /// streak increments immediately, not at the next week boundary.
  /// On Monday of a new week, if the user has not yet reached the threshold,
  /// the current week has 0 qualifying XP and the streak shows 0 (grey).
  ///
  /// [xpByWeek] maps ISO year-week strings (e.g. `"2026-W14"`) to total XP
  /// earned that week. Missing weeks are treated as 0 XP.
  static int countStreak(
    Map<String, int> xpByWeek,
    DateTime today, {
    int threshold = kWeeklyXpThreshold,
  }) {
    final currentWeekMonday = startOfIsoWeek(today);
    int streak = 0;

    for (int weeksBack = 0; weeksBack <= 200; weeksBack++) {
      // Use explicit date arithmetic (year/month/day) to avoid DST-shift bugs
      // that occur when subtracting Duration across a DST boundary.
      final weekStart = DateTime(
        currentWeekMonday.year,
        currentWeekMonday.month,
        currentWeekMonday.day - weeksBack * 7,
      );
      final weekKey = isoYearWeek(weekStart);
      final xp = xpByWeek[weekKey] ?? 0;
      if (xp >= threshold) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Counts consecutive qualifying weeks starting from *last* week (not the
  /// current in-progress week). Used to compute the "pending" streak shown
  /// in grey when the user hasn't yet activated the current week.
  ///
  /// Returns 0 if last week did not qualify (streak truly broken after 2+
  /// missed weeks).
  static int countPendingStreak(
    Map<String, int> xpByWeek,
    DateTime today, {
    int threshold = kWeeklyXpThreshold,
  }) {
    final currentWeekMonday = startOfIsoWeek(today);
    int streak = 0;

    for (int weeksBack = 1; weeksBack <= 200; weeksBack++) {
      final weekStart = DateTime(
        currentWeekMonday.year,
        currentWeekMonday.month,
        currentWeekMonday.day - weeksBack * 7,
      );
      final weekKey = isoYearWeek(weekStart);
      final xp = xpByWeek[weekKey] ?? 0;
      if (xp >= threshold) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Returns whether the current week is on track (XP ≥ threshold already
  /// earned this week).
  static bool isCurrentWeekComplete(
    int currentWeekXp, {
    int threshold = kWeeklyXpThreshold,
  }) =>
      currentWeekXp >= threshold;
}
