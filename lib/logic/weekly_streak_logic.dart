/// Pure, side-effect-free logic for the weekly streak system.
///
/// A week is "active" when the user earned ≥ [kWeeklyAuraThreshold] Aura Points
/// in that Mon–Sun period. The streak counts consecutive *completed* weeks
/// (the current in-progress week never counts toward the streak yet).
library;

/// Minimum Aura to earn in a Mon–Sun week for it to count as an active week.
const int kWeeklyAuraThreshold = 300;

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
  /// [xpByWeek] maps ISO year-week strings (e.g. `"2026-W14"`) to total Aura
  /// earned that week. Missing weeks are treated as 0.
  ///
  /// [frozenWeeks] is the set of ISO week keys that have been protected by a
  /// streak freeze — they are treated as having met the threshold.
  static int countStreak(
    Map<String, int> auraByWeek,
    DateTime today, {
    int threshold = kWeeklyAuraThreshold,
    Set<String> frozenWeeks = const {},
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
      final aura = auraByWeek[weekKey] ?? 0;
      if (aura >= threshold || frozenWeeks.contains(weekKey)) {
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
    Map<String, int> auraByWeek,
    DateTime today, {
    int threshold = kWeeklyAuraThreshold,
    Set<String> frozenWeeks = const {},
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
      final aura = auraByWeek[weekKey] ?? 0;
      if (aura >= threshold || frozenWeeks.contains(weekKey)) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Walks the streak backwards from today and automatically applies available
  /// freeze charges to consecutive missed past weeks — exactly like Duolingo's
  /// streak freeze.
  ///
  /// Only past weeks (weeksBack ≥ 1) are eligible for a freeze; the current
  /// in-progress week (weeksBack == 0) must qualify on its own XP.  A freeze
  /// is never applied if the current week hasn't reached the threshold yet,
  /// because the streak counter starts at 0 and never reaches the gap check.
  ///
  /// Returns the resulting streak count **and** the list of newly-frozen week
  /// keys (so the caller can persist them and decrement the freeze inventory).
  /// Already-frozen weeks in [alreadyFrozenWeeks] are counted but not re-added
  /// to the returned list.
  static ({int streak, List<String> newlyFrozenWeeks}) countStreakAutoFreeze(
    Map<String, int> auraByWeek,
    DateTime today, {
    int threshold = kWeeklyAuraThreshold,
    Set<String> alreadyFrozenWeeks = const {},
    int availableFreezes = 0,
  }) {
    final currentWeekMonday = startOfIsoWeek(today);
    int streak = 0;
    int remainingFreezes = availableFreezes;
    final newlyFrozen = <String>[];

    for (int weeksBack = 0; weeksBack <= 200; weeksBack++) {
      final weekStart = DateTime(
        currentWeekMonday.year,
        currentWeekMonday.month,
        currentWeekMonday.day - weeksBack * 7,
      );
      final weekKey = isoYearWeek(weekStart);
      final aura = auraByWeek[weekKey] ?? 0;
      final isFrozen =
          alreadyFrozenWeeks.contains(weekKey) || newlyFrozen.contains(weekKey);

      if (aura >= threshold || isFrozen) {
        streak++;
      } else if (weeksBack > 0 && remainingFreezes > 0) {
        // Auto-apply a freeze to this missed past week.
        remainingFreezes--;
        newlyFrozen.add(weekKey);
        streak++;
      } else {
        break;
      }
    }

    return (streak: streak, newlyFrozenWeeks: newlyFrozen);
  }

  /// Returns whether the current week is on track (XP ≥ threshold already
  /// earned this week).
  static bool isCurrentWeekComplete(
    int currentWeekAura, {
    int threshold = kWeeklyAuraThreshold,
  }) =>
      currentWeekAura >= threshold;
}
