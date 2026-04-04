# Syntra — Development Roadmap

Generated: 2026-04-03 · Last updated: 2026-04-04 (Phase 5 complete)
Based on: CODEBASE_ANALYSIS.txt (2026-04-03)

---

## Branch Status & Merge Order

Branches must be merged in the order shown. Indentation = dependency.

```
main
 │
 ├─ [PR] fix/db-migration-feeling-perception        ← merge FIRST
 │        └─ [PR] fix/challenge-id-type             ← merge SECOND (depends on above)
 │
 ├─ [PR] refactor/challenge-model                   ← merge THIRD
 │        └─ [PR] refactor/czl-expand               ← merge FOURTH (depends on above)
 │
 ├─ [PR] refactor/navigate-gorouter                 ← merge FIFTH (independent)
 │        └─ [PR] refactor/priming-gorouter         ← merge SIXTH (depends on above)
 │
 ├─ [PR] refactor/shared-prefs-provider             ← merge SEVENTH (independent)
 │
 ├─ [PR] refactor/notification-cleanup              ← merge EIGHTH (independent)
 │
 ├─ [PR] refactor/split-screens                     ← Phase 1.7 (independent)
 │
 ├─ [PR] test/widget-tests                          ← Phase 2.2 (after split-screens)
 │
 ├─ [PR] feat/phase-3-core-loop                     ← Phase 3 (independent)
 │
 ├─ [PR] feat/phase-4-progression                   ← Phase 4 (independent)
 │
 └─ [PR] feat/phase-5-ux-polish                     ← Phase 5 (in progress)
```

### Branch summaries

| Branch | What it does | Status |
|---|---|---|
| `fix/db-migration-feeling-perception` | DB v2→v3: adds `feeling` / `perception` columns. Prevents crash on upgrade. | Ready |
| `fix/challenge-id-type` | DB v3→v4: rebuilds `logbook` table with `challenge_id TEXT` instead of INTEGER. Removes `.toString()` workaround. | Ready |
| `refactor/challenge-model` | `notSureWhatToSay: String` → `hints: List<String>` (JSON arrays). New `level: int` field on `Challenge` (explicit, from JSON). All fields `final`. `toMap`/`fromMap` removed. `assignLevel` simplified. 127 challenges updated. All rendering sites updated. | Ready |
| `refactor/czl-expand` | `maxLevel` 5→10. Level names + descriptions for levels 6–10 (Stepping Up → Untouchable). Settings chip row and level-up dialog scale automatically. | Ready |
| `refactor/navigate-gorouter` | `ActiveChallengeScreen→ChallengeDoneScreen` and both `StreakCelebration` push sites migrated from `Navigator.push` to GoRouter. Also fixes pre-existing bug: `isDailyMission` flag (and daily XP bonus) now correctly flows through `PrimingScreen→ActiveChallengeScreen→ChallengeDoneArgs`. | Ready |
| `refactor/priming-gorouter` | Add `/priming` GoRoute. Remove `onDone` callback from `PrimingScreen` and `ActiveChallengeScreen`. Result bubbles back via `Future<double?>` pop chain. `ChallengesScreen` and `DailyChallengeScreen` use `context.pushPriming(...)`. | Ready |
| `refactor/shared-prefs-provider` | `sharedPreferencesProvider` initialized once in `main()` and injected via `ProviderScope`. `SettingsRepository` takes `SharedPreferences` in constructor. All `StateNotifier`s receive `SettingsRepository` via constructor from `ref`. `ChallengeFiltersNotifier`, `ComfortZoneLogic`, `DailyMissionsLogic` use injected prefs. Tests can override with a fake. | Ready |
| `refactor/notification-cleanup` | Remove duplicate `FlutterLocalNotificationsPlugin` instance from `NotificationManager`. Collapse triple-cancel into single `SyntraNotificationService.cancelAllNotifications()` call. `initialize()` delegates entirely to the service. | Ready |
| `refactor/split-screens` | Split `challenges_screen.dart` (965→205 lines) and `onboarding_screen.dart` (864→193 lines) into `challenges/` and `onboarding/` subdirectory widgets. | Ready |
| `test/widget-tests` | Widget tests for `ChallengeCard` (9 tests), `ChallengeDoneScreen` (7 tests), `ActiveChallengeScreen` (3 tests). Shared `test/helpers/test_helpers.dart` with channel mocks and fake challenge factory. | Ready |
| `feat/phase-3-core-loop` | Personal best streak (3.2), mood trend chart in detail sheet (3.1), retry-after-abort "Try Again" button (3.3). | Ready |
| `feat/phase-4-progression` | Badges system (4.1), CZL gradient/icon identity (4.2), weekly goal progress card (4.3), weekly recap notification (4.4). | Ready |

---

## Phase 0 — Bug Fixes (pre-release blockers)

| # | Task | Branch | Status |
|---|---|---|---|
| 0.1 | Fix logbook DB migration — `feeling`/`perception` columns | `fix/db-migration-feeling-perception` | **Done** |
| 0.2 | Fix `challenge_id` type — INTEGER → TEXT in SQLite | `fix/challenge-id-type` | **Done** |

---

## Phase 1 — Code Quality & Architecture

| # | Task | Branch | Status |
|---|---|---|---|
| 1.1 | Make `Challenge` fields `final`, remove `toMap`/`fromMap` | `refactor/challenge-model` | **Done** |
| 1.2 | Explicit `level` field in `challenges.json` (replaces percentile logic) | `refactor/challenge-model` | **Done** |
| 1.3 | Migrate `Navigator.push` calls to GoRouter | `refactor/navigate-gorouter` | **Done** (partial — PrimingScreen entry points remain) |
| 1.4 | Merge / clean up notification manager classes | `refactor/notification-cleanup` | **Done** |
| 1.5 | Wire `PrimingScreen` into GoRouter | `refactor/priming-gorouter` | **Done** |
| 1.6 | Inject `SharedPreferences` via Riverpod provider | `refactor/shared-prefs-provider` | **Done** |
| 1.7 | Split large screen files into `widgets/` subdirectories | `refactor/split-screens` | **Done** |

### CZL Expansion

| # | Task | Branch | Status |
|---|---|---|---|
| CZL | `hints: List<String>` replaces pipe-delimited string | `refactor/challenge-model` | **Done** |
| CZL | `maxLevel` 5→10, new level names 6–10 | `refactor/czl-expand` | **Done** |
| CZL | Assign levels 6–10 to actual challenges in `challenges.json` | — | **TODO** (all 127 challenges currently assigned levels 1–5 only) |
| CZL | Add challenges for levels 6–10 to the catalog | — | **TODO** (content work) |

---

## Phase 2 — Testability ✓

| # | Task | Status |
|---|---|---|
| 2.1 | `SharedPreferences` Riverpod provider for injection | **Done** (`refactor/shared-prefs-provider`) |
| 2.2 | Widget tests for `ChallengeCard`, `ChallengeDoneScreen`, `ActiveChallengeScreen` | **Done** (`test/widget-tests` — 19 tests) |

---

## Phase 3 — Core Loop Depth ✓

| # | Task | Status |
|---|---|---|
| 3.1 | Challenge reflection history (mood trend chart per challenge in logbook) | **Done** (`_MoodChart` widget, `moodHistoryProvider`, `feat/phase-3-core-loop`) |
| 3.2 | Personal best streak tracking (`all_time_max_streak` in SharedPrefs) | **Done** (`personalBestStreakProvider`, Best Streak + Done Today stat cards, `feat/phase-3-core-loop`) |
| 3.3 | Repeat challenge suggestion after abort | **Done** ("Try Again" → `pushReplacement` fresh `ActiveChallengeScreen`, `feat/phase-3-core-loop`) |
| 3.4 | Context-aware environment filter (session chip, not persisted) | **Skipped** — all 127 challenges use `environment: "all"` |

---

## Phase 4 — Progression & Motivation ✓

| # | Task | Status |
|---|---|---|
| 4.1 | Badges / achievements system | **Done** (8 badges, `BadgesLogic`, `_BadgesSection` in stats, `feat/phase-4-progression`) |
| 4.2 | CZL visual identity — level icon + gradient per level | **Done** (gradient header band + level icons in card and level-up dialog, `feat/phase-4-progression`) |
| 4.3 | Weekly goal setting (3/5/7 challenges, progress ring) | **Done** (`weeklyGoalProvider`, linear progress bar, ChoiceChips, `feat/phase-4-progression`) |
| 4.4 | Weekly recap notification (Sunday evening summary) | **Done** (`scheduleWeeklyRecap` called from `main()`, `feat/phase-4-progression`) |

---

## Phase 5 — UX Polish ✓

| # | Task | Status |
|---|---|---|
| 5.1 | Logbook search and filter | **Done** (`filteredEntries()` + search bar + status chips in `LogbookPage`) |
| 5.2 | Challenge detail screen (replaces bottom sheet) | **Done** (`ChallengeDetailScreen` as `MaterialPageRoute`, old sheet removed) |
| 5.3 | Timer customization before starting | **Done** (`_DurationPicker` in `PrimingScreen`, `overrideTime` in `ActiveChallengeScreen`) |
| 5.4 | Distinct haptic vocabulary per event | **Done** (`VibrationService.abort()` added and wired; full vocabulary: accept/start/timerWarning/timerEnd/success/milestone/xpTick/abort) |

---

## Phase 6 — Custom Challenges

Full user-created challenge flow (`user_challenges` SQLite table, DB v5). Requires Phase 1 complete.

---

## Phase 7 — Social Features (future, requires backend)

Real social proof, friend streaks, community feed.

---

## Dependency Graph

```
fix/db-migration  →  fix/challenge-id-type
refactor/challenge-model  →  refactor/czl-expand
refactor/navigate-gorouter  (independent)

Phase 1.6 (SharedPrefs inject)  →  Phase 2 (widget tests)
Phase 3.1 (reflection history)  →  Phase 5.2 (challenge detail screen)
Phase 1.2 (explicit level)  →  Phase 4.2 (CZL visual identity)
Phase 1.4 (notification merge)  →  Phase 4.4 (weekly recap notification)
Phase 1.7 (split screens)  →  Phase 2 (widget tests)
Phase 1  →  Phase 6 (custom challenges)
```

---

## Known Remaining Issues

- All 127 challenges are assigned levels 1–5 only. Levels 6–10 exist in the system but no challenge content covers them (CZL TODO).
- Phase 3.4 (environment filter) skipped — all challenges use `environment: "all"`.
- Phases 1–4 complete on feature branches; none merged to `main` yet.
- Phase 5 complete on `feat/phase-5-ux-polish`.
- All feature branches (Phases 1–5) ready to merge; none merged to `main` yet.
