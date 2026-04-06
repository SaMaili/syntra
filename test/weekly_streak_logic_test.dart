import 'package:flutter_test/flutter_test.dart';
import 'package:syntra/logic/weekly_streak_logic.dart';

void main() {
  // Reference Monday 2026-04-06 (week 15)
  final monday = DateTime(2026, 4, 6);
  // Wednesday mid-week
  final wednesday = DateTime(2026, 4, 8);
  // Sunday end-of-week
  final sunday = DateTime(2026, 4, 5); // week 14

  // ── isoYearWeek ────────────────────────────────────────────────────────────

  group('WeeklyStreakLogic.isoYearWeek', () {
    test('Monday 2026-04-06 is 2026-W15', () {
      expect(WeeklyStreakLogic.isoYearWeek(DateTime(2026, 4, 6)), '2026-W15');
    });

    test('Sunday 2026-04-05 is 2026-W14', () {
      expect(WeeklyStreakLogic.isoYearWeek(DateTime(2026, 4, 5)), '2026-W14');
    });

    test('Wednesday 2026-04-08 is same week as its Monday', () {
      expect(WeeklyStreakLogic.isoYearWeek(DateTime(2026, 4, 8)),
          WeeklyStreakLogic.isoYearWeek(DateTime(2026, 4, 6)));
    });

    test('first day of year 2026-01-01 (Thursday) is 2026-W01', () {
      expect(WeeklyStreakLogic.isoYearWeek(DateTime(2026, 1, 1)), '2026-W01');
    });

    test('2025-12-29 (Monday) belongs to 2026-W01', () {
      expect(WeeklyStreakLogic.isoYearWeek(DateTime(2025, 12, 29)), '2026-W01');
    });

    test('2025-12-28 (Sunday) belongs to 2025-W52', () {
      expect(WeeklyStreakLogic.isoYearWeek(DateTime(2025, 12, 28)), '2025-W52');
    });
  });

  // ── startOfIsoWeek ─────────────────────────────────────────────────────────

  group('WeeklyStreakLogic.startOfIsoWeek', () {
    test('Monday returns itself', () {
      expect(WeeklyStreakLogic.startOfIsoWeek(monday), monday);
    });

    test('Wednesday returns previous Monday', () {
      expect(WeeklyStreakLogic.startOfIsoWeek(wednesday), monday);
    });

    test('Sunday 2026-04-05 returns Monday 2026-03-30', () {
      expect(WeeklyStreakLogic.startOfIsoWeek(sunday), DateTime(2026, 3, 30));
    });
  });

  // ── countStreak ────────────────────────────────────────────────────────────

  group('WeeklyStreakLogic.countStreak', () {
    // today = Monday 2026-04-06 (W15). Last completed week = W14.

    test('returns 0 for empty xpByWeek', () {
      expect(WeeklyStreakLogic.countStreak({}, monday), 0);
    });

    test('returns 0 when current week has 0 XP (new week, not yet farmed)', () {
      // Current week W15 has 0 XP → streak is 0 even if previous weeks qualified
      expect(WeeklyStreakLogic.countStreak({'2026-W14': 400}, monday), 0);
    });

    test('returns 0 when current week XP is below threshold', () {
      expect(WeeklyStreakLogic.countStreak({'2026-W15': 299}, monday), 0);
    });

    test('returns 1 when current week just hit threshold', () {
      expect(WeeklyStreakLogic.countStreak({'2026-W15': 300}, monday), 1);
    });

    test('returns 1 when current week hit threshold but previous week did not', () {
      final xp = {'2026-W15': 400, '2026-W14': 100};
      expect(WeeklyStreakLogic.countStreak(xp, monday), 1);
    });

    test('returns 2 when current and previous week both qualify', () {
      final xp = {'2026-W15': 400, '2026-W14': 350};
      expect(WeeklyStreakLogic.countStreak(xp, monday), 2);
    });

    test('returns 3 for three consecutive qualifying weeks including current', () {
      final xp = {
        '2026-W15': 500,
        '2026-W14': 300,
        '2026-W13': 400,
      };
      expect(WeeklyStreakLogic.countStreak(xp, monday), 3);
    });

    test('stops at first gap — past qualifying week does not help', () {
      final xp = {
        '2026-W15': 500,
        '2026-W14': 0,   // gap
        '2026-W13': 400,
      };
      expect(WeeklyStreakLogic.countStreak(xp, monday), 1);
    });

    test('current week XP counts immediately once threshold is reached', () {
      final xp = {
        '2026-W15': 999, // current week — must count
        '2026-W14': 300,
      };
      expect(WeeklyStreakLogic.countStreak(xp, monday), 2);
    });

    test('mid-week: current week counts if threshold already reached', () {
      // today = Wednesday W15
      final xp = {
        '2026-W15': 400,
        '2026-W14': 300,
        '2026-W13': 300,
      };
      expect(WeeklyStreakLogic.countStreak(xp, wednesday), 3);
    });

    test('mid-week: streak is 0 if current week not yet qualified', () {
      // today = Wednesday W15, current week has only 100 XP
      final xp = {
        '2026-W15': 100,
        '2026-W14': 300,
      };
      expect(WeeklyStreakLogic.countStreak(xp, wednesday), 0);
    });

    test('missing previous weeks treated as 0 XP (breaks streak)', () {
      // Only current week present → streak is 1
      final xp = {'2026-W15': 400};
      expect(WeeklyStreakLogic.countStreak(xp, monday), 1);
    });

    test('respects custom threshold', () {
      final xp = {'2026-W15': 150};
      expect(WeeklyStreakLogic.countStreak(xp, monday, threshold: 100), 1);
      expect(WeeklyStreakLogic.countStreak(xp, monday, threshold: 200), 0);
    });

    test('handles streak from Sunday mid-week (W14)', () {
      // today = Sunday 2026-04-05 (W14). Current week W14 qualifies.
      final xp = {'2026-W14': 350, '2026-W13': 300};
      expect(WeeklyStreakLogic.countStreak(xp, sunday), 2);
    });

    test('on Monday of new week with 0 XP, previous streak is not shown', () {
      // today = Monday W15, hasn't farmed yet → streak = 0
      final xp = {
        '2026-W15': 0,
        '2026-W14': 400,
        '2026-W13': 400,
      };
      expect(WeeklyStreakLogic.countStreak(xp, monday), 0);
    });

    test('large streak counts correctly including current week', () {
      // W15 (current) down to W06 = 10 consecutive qualifying weeks
      final xp = {
        for (int w = 0; w <= 9; w++) '2026-W${(15 - w).toString().padLeft(2, '0')}': 400,
      };
      expect(WeeklyStreakLogic.countStreak(xp, monday), 10);
    });
  });

  // ── countPendingStreak ────────────────────────────────────────────────────

  group('WeeklyStreakLogic.countPendingStreak', () {
    test('returns 0 when last week had 0 XP (streak truly broken)', () {
      expect(WeeklyStreakLogic.countPendingStreak({}, monday), 0);
    });

    test('returns 0 when last week was below threshold', () {
      expect(
        WeeklyStreakLogic.countPendingStreak({'2026-W14': 299}, monday),
        0,
      );
    });

    test('returns 1 when only last week qualified', () {
      expect(
        WeeklyStreakLogic.countPendingStreak({'2026-W14': 300}, monday),
        1,
      );
    });

    test('returns 3 when last three weeks qualified', () {
      final xp = {
        '2026-W14': 400,
        '2026-W13': 350,
        '2026-W12': 300,
      };
      expect(WeeklyStreakLogic.countPendingStreak(xp, monday), 3);
    });

    test('ignores current week entirely', () {
      // Current week W15 has lots of XP but should not be counted
      final xp = {'2026-W15': 999, '2026-W14': 400};
      expect(WeeklyStreakLogic.countPendingStreak(xp, monday), 1);
    });

    test('returns 0 when last week missed even if week before qualified', () {
      final xp = {'2026-W14': 0, '2026-W13': 500};
      expect(WeeklyStreakLogic.countPendingStreak(xp, monday), 0);
    });

    test('grace period: one missed week shows previous streak, two resets to 0', () {
      final xp = {'2026-W14': 400, '2026-W13': 350, '2026-W12': 300};
      // Current week (W15) not yet active → pending = 3
      expect(WeeklyStreakLogic.countPendingStreak(xp, monday), 3);

      // Simulate next Monday (W16): last week W15 had 0 XP → pending = 0
      final nextMonday = DateTime(2026, 4, 13);
      expect(WeeklyStreakLogic.countPendingStreak(xp, nextMonday), 0);
    });
  });

  // ── isCurrentWeekComplete ──────────────────────────────────────────────────

  group('WeeklyStreakLogic.isCurrentWeekComplete', () {
    test('returns true when XP equals threshold', () {
      expect(WeeklyStreakLogic.isCurrentWeekComplete(300), isTrue);
    });

    test('returns true when XP exceeds threshold', () {
      expect(WeeklyStreakLogic.isCurrentWeekComplete(450), isTrue);
    });

    test('returns false when XP is below threshold', () {
      expect(WeeklyStreakLogic.isCurrentWeekComplete(299), isFalse);
    });

    test('returns false for zero XP', () {
      expect(WeeklyStreakLogic.isCurrentWeekComplete(0), isFalse);
    });

    test('respects custom threshold', () {
      expect(
          WeeklyStreakLogic.isCurrentWeekComplete(150, threshold: 100), isTrue);
      expect(
          WeeklyStreakLogic.isCurrentWeekComplete(50, threshold: 100), isFalse);
    });
  });
}
