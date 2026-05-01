import 'package:shared_preferences/shared_preferences.dart';

import '../data/logbook_repository.dart';
import '../data/settings_repository.dart';
import '../logic/badges_logic.dart';
import '../logic/weekly_streak_logic.dart';

/// Populates the app with realistic fake data for App Store screenshot sessions.
///
/// Streak layout (oldest → newest):
///   Week -7: ≥300 aura  →  Week -6: streak freeze (no entries)  →
///   Weeks -5…-1: ≥300 aura each  →  Week 0 (current): <300 aura
///
/// Displayed as a grey "pending" streak of 7.
///
/// Call via the hidden 5-tap trigger in the About page, then restart the app.
Future<void> seedFakeData() async {
  await LogbookRepository.instance.clearAllEntries();

  final today = DateTime.now();
  final base = DateTime(today.year, today.month, today.day);

  // (challengeId, aura, durationSeconds)
  const challenges = [
    ('1', 50, 300),     // index 0 – lvl1, low aura (used for current week)
    ('6', 100, 600),    // index 1 – lvl2
    ('8', 90, 480),     // index 2 – lvl3
    ('11', 110, 600),   // index 3 – lvl3
    ('4', 120, 720),    // index 4 – lvl3
    ('2', 100, 600),    // index 5 – lvl3
    ('55', 100, 600),   // index 6 – lvl2
  ];

  // Entries: (daysAgo, challengeIndex, feeling 0–4, perception 0–4, preAnxiety 1–5, notes?)
  //
  // Each active week has a deliberately different entry count so the weekly
  // aura chart shows visible variety:
  //   W-7 ≈  400  W-6 [freeze]  W-5 ≈  610  W-4 ≈  710
  //   W-3 ≈  950  W-2 ≈ 1050   W-1 ≈  790   W-0 ≈  250 (current, under threshold)
  const entries = [
    // ── Current week (days 0–3) — 250 aura, under threshold ────────────────
    (0, 0, 3, 3, 2, null),
    (1, 0, 2, 2, 3, 'Kleine Schritte diese Woche.'),
    (1, 0, 3, 3, 2, null),
    (2, 0, 2, 3, 3, null),
    (3, 0, 3, 2, 2, null),
    // ── Week -1 — 8 entries ≈ 790 aura ──────────────────────────────────────
    (4, 4, 3, 3, 3, null),
    (5, 0, 3, 2, 4, 'Hat Überwindung gekostet.'),
    (6, 1, 4, 4, 2, null),
    (7, 3, 4, 3, 1, 'Richtig stolz auf mich!'),
    (7, 6, 3, 3, 2, null),
    (8, 5, 4, 4, 2, 'Sehr schön.'),
    (9, 1, 3, 3, 3, null),
    (10, 3, 4, 3, 2, null),
    // ── Week -2 — 10 entries ≈ 1050 aura ────────────────────────────────────
    (11, 1, 2, 3, 4, null),
    (12, 4, 4, 3, 2, 'Weggegangen, Challenge gewählt.'),
    (12, 3, 3, 3, 2, null),
    (13, 5, 3, 4, 3, null),
    (13, 6, 4, 4, 1, 'Perfekt.'),
    (14, 2, 3, 3, 3, null),
    (15, 1, 3, 2, 5, 'Extrem nervös, aber gemacht.'),
    (15, 3, 3, 3, 3, null),
    (16, 4, 4, 4, 2, 'Beste Woche!'),
    (17, 1, 3, 3, 2, null),
    // ── Week -3 — 9 entries ≈ 950 aura ──────────────────────────────────────
    (18, 3, 3, 3, 2, null),
    (19, 1, 4, 3, 2, 'Einfach super!'),
    (20, 4, 3, 4, 3, null),
    (20, 6, 3, 3, 2, null),
    (21, 5, 4, 4, 1, 'Hat Spaß gemacht.'),
    (22, 2, 3, 3, 3, null),
    (23, 3, 4, 3, 2, null),
    (24, 1, 2, 2, 4, 'Musste mich wirklich überwinden.'),
    (24, 4, 3, 3, 2, null),
    // ── Week -4 — 7 entries ≈ 710 aura ──────────────────────────────────────
    (25, 1, 4, 4, 2, null),
    (26, 2, 3, 3, 2, null),
    (27, 3, 3, 3, 3, 'Gut gelaufen.'),
    (28, 4, 3, 4, 2, 'Challenge war für mich neu.'),
    (29, 5, 4, 4, 2, null),
    (30, 1, 3, 3, 3, null),
    (31, 2, 4, 3, 2, 'Kleine Schritte zählen.'),
    // ── Week -5 — 6 entries ≈ 610 aura ──────────────────────────────────────
    (32, 1, 3, 3, 3, null),
    (33, 2, 3, 3, 3, null),
    (34, 3, 4, 3, 2, null),
    (35, 1, 3, 2, 3, 'Regelmäßig bleiben lohnt sich.'),
    (37, 2, 4, 4, 1, null),
    (38, 4, 3, 3, 2, 'Tolles Gefühl danach.'),
    // ── Week -6: no entries — streak freeze covers this gap ─────────────────
    // ── Week -7 — 5 entries ≈ 400 aura ──────────────────────────────────────
    (46, 1, 3, 3, 3, null),
    (48, 0, 2, 2, 4, 'Erster Versuch.'),
    (50, 0, 2, 2, 3, null),
    (51, 2, 3, 3, 3, null),
    (52, 3, 2, 2, 5, 'Der Anfang war schwer — jetzt läuft es.'),
  ];

  for (final e in entries) {
    final (daysAgo, cIdx, feeling, perception, pre, notes) = e;
    final (id, aura, dur) = challenges[cIdx % challenges.length];
    final ts = base.subtract(Duration(days: daysAgo));
    final timestamp = DateTime(ts.year, ts.month, ts.day, 9 + (cIdx % 8), 0);
    await LogbookRepository.instance.addEntry(
      challengeId: id,
      status: 'success',
      aura: aura,
      timestamp: timestamp,
      feeling: feeling,
      perception: perception,
      durationSeconds: dur,
      preAnxiety: pre,
      notes: notes,
    );
  }

  // ── SharedPreferences ──────────────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();

  // CZL level 5 with partial progress toward level 6.
  await prefs.setInt('comfort_zone_level', 5);
  await prefs.setInt('czl_completions_5', 3);

  // Best weekly streak: 7 (5 active + freeze + 1 before freeze).
  await prefs.setInt('best_weekly_streak', 7);

  // Freeze week -6 so the streak logic counts it as active.
  final currentWeekMonday = WeeklyStreakLogic.startOfIsoWeek(today);
  final freezeMonday = DateTime(
    currentWeekMonday.year,
    currentWeekMonday.month,
    currentWeekMonday.day - 6 * 7,
  );
  final frozenWeekKey = WeeklyStreakLogic.isoYearWeek(freezeMonday);
  await prefs.setString('shop_frozen_weeks', frozenWeekKey);

  // Suppress the weekly goal celebration pop-up for the current week.
  final currentWeekKey = WeeklyStreakLogic.isoYearWeek(today);
  await prefs.setString('last_goal_week', currentWeekKey);

  // Mark all badges as seen so no celebration sheet blocks screenshots.
  final allIds = BadgesLogic.all.map((b) => b.id).toList();
  await SettingsRepository.instance.saveSeenBadges(allIds.toSet());
  await SettingsRepository.instance.appendUnlockedBadges(allIds);
}
