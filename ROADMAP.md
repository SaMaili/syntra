# Syntra — Development Roadmap

Generated: 2026-04-03 · Last updated: 2026-04-04 (Phase 4 complete)
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
 └─ [PR] feat/phase-5-ux-polish                     ← Phase 5 (independent, in progress)
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
| `feat/phase-3-core-loop` | Personal best streak (3.2), mood trend chart (3.1), retry-after-abort button (3.3). | Ready |
| `feat/phase-4-progression` | Badges system (4.1), CZL gradients/icons (4.2), weekly goal card (4.3), weekly recap notification (4.4). | Ready |

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
| 1.7 | Split large screen files into `widgets/` subdirectories | `refactor/split-screens` | **Done** (`challenges/` + `onboarding/` subdirs) |

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
| 2.1 | `SharedPreferences` Riverpod provider for injection | **Done** (1.6 / `refactor/shared-prefs-provider`) |
| 2.2 | Widget tests for `ChallengeCard`, `ChallengeDoneScreen`, `ActiveChallengeScreen` | **Done** (`test/widget-tests` — 19 tests total) |

---

## Phase 3 — Core Loop Depth ✓

| # | Task | Status |
|---|---|---|
| 3.1 | Challenge reflection history (mood trend chart per challenge in logbook) | **Done** (`_MoodChart` in detail sheet, `moodHistoryProvider`, `feat/phase-3-core-loop`) |
| 3.2 | Personal best streak tracking (`all_time_max_streak` in SharedPrefs) | **Done** (`personalBestStreakProvider`, Best Streak + Done Today cards in stats grid, `feat/phase-3-core-loop`) |
| 3.3 | Repeat challenge suggestion after abort | **Done** ("Try Again" button → `pushReplacement` to fresh `ActiveChallengeScreen`, `feat/phase-3-core-loop`) |
| 3.4 | Context-aware environment filter (session chip, not persisted) | **Skipped** — all 127 challenges have `environment: "all"` |

---

## Phase 4 — Progression & Motivation ✓

| # | Task | Status |
|---|---|---|
| 4.1 | Badges / achievements system | TODO |
| 4.2 | CZL visual identity — level icon + gradient per level | TODO |
| 4.3 | Weekly goal setting (3/5/7 challenges, progress ring) | TODO |
| 4.4 | Weekly recap notification (Sunday evening summary) | TODO |
---

### 4.1 Badges / achievements system

**Files:** `lib/data/settings_repository.dart`,
`lib/routes/statistics_screen.dart` (new `widgets/badges_grid.dart`)  
**Source:** Section 10.2

**Badge definitions (initial set):**

| ID | Name | Trigger |
|---|---|---|
| `first_blood` | First Blood | First successful logbook entry |
| `streak_3` | Streak Starter | 3-day streak |
| `streak_7` | Week Warrior | 7-day streak |
| `consistent` | Consistent | 7/7 days in a calendar week |
| `comfort_breaker` | Comfort Breaker | First challenge at CZL 3+ |
| `bold_move` | Bold Move | First Bold-tier daily mission completed |
| `night_owl` | Night Owl | Challenge completed after 21:00 |

**Changes:**
- Store earned badges as a `Set<String>` in SharedPreferences
  (`earned_badges` key, serialized as JSON array)
- Add `BadgeService.checkAndAward(ref, logbookEntry)` called from
  `ChallengeDoneScreen._onBackToHome` after logging
- Show unlocked badges in a grid on the stats screen
- On unlock: scale-in animation + `SoundService.playSuccess()` +
  `VibrationService.milestone()`

---

### 4.2 CZL visual identity (level badge)

**Files:** `lib/routes/challenges_screen.dart` → `widgets/czl_progress_card.dart`  
**Source:** Section 10.2

Each level gets a distinct icon and color accent. Currently the level name is
plain text.

**Level identity map:**

| Level | Name | Icon | Accent |
|---|---|---|---|
| 1 | Warming Up | `local_fire_department` (small) | Teal |
| 2 | Breaking the Ice | `ac_unit` | Cyan |
| 3 | Holding the Floor | `record_voice_over` | Amber |
| 4 | Taking Risks | `bolt` | Orange |
| 5 | The Bold Zone | `whatshot` (full) | Neon pink (seed) |

**Changes:**
- Replace the text-only CZL header card with a styled card that has the icon,
  gradient background, level name, and completion progress bar
- The gradient uses the level accent color fading into the surface color

---

### 4.3 Weekly goal setting

**Files:** `lib/routes/statistics_screen.dart`,
`lib/data/settings_repository.dart`  
**Source:** Section 10.2

**Changes:**
- Add `weekly_challenge_goal` (int, default 5) to `SettingsRepository`
- Add a goal selector in Settings (3 / 5 / 7 challenges — `SegmentedButton`)
- On the stats screen, replace the raw "Challenges today" counter with a
  progress ring showing `completedThisWeek / weeklyGoal`
- At 100%: ring turns primary color + brief success animation

---

### 4.4 Weekly recap notification

**Files:** `lib/logic/notification_manager.dart`  
**Source:** Section 10.2

**Changes:**
- Add `scheduleWeeklyRecap()` to `NotificationManager`
- Scheduled for Sunday 19:00 using the same `zonedSchedule` path
- Body is built from `LogbookRepository.weeklyChallengeCounts()`:
  "You completed X challenges this week and earned Y Aura Points."
- Called alongside `scheduleDailyReminders()` in settings save + onboarding

---

## Phase 5 — UX Polish

| # | Task | Status |
|---|---|---|
| 5.1 | Logbook search and filter | TODO |
| 5.2 | Challenge detail screen (replaces bottom sheet) | TODO |
| 5.3 | Timer customization before starting | TODO |
| 5.4 | Distinct haptic vocabulary per event | TODO |

---

## Phase 6 — Custom Challenges

Full user-created challenge flow (`user_challenges` SQLite table, DB v5). Requires Phase 1 complete.

---

## Phase 7 — Social Features (future, requires backend)

Real social proof, friend streaks, community feed.
---

### 5.1 Logbook search and filter

**Files:** `lib/routes/logbook_page.dart`,
`lib/data/logbook_repository.dart`  
**Source:** Section 10.5

**Changes:**
- Add `LogbookRepository.searchEntries(query, status, dateFrom, dateTo)`
- Add a search bar + filter icon to `LogbookPage` AppBar
- Filter sheet: status toggle (all / success / tried), date range picker
- Search hits notes text via `LIKE '%query%'` in SQLite

---

### 5.2 Challenge detail screen

**Files:** new `lib/routes/challenge_detail_screen.dart`  
**Source:** Section 10.5

**Changes:**
- New `GoRouter` route `/challenge_detail` receiving a `Challenge` as `extra`
- Shows: full description, `notSureWhatToSay` hint, social proof count, XP +
  timer, past attempts (from §3.1 query)
- "Start Challenge" button navigates to `/active_challenge`
- Replace the current bottom sheet on `ChallengesScreen` with
  `context.push('/challenge_detail', extra: challenge)`

---

### 5.3 Timer customization (pre-challenge)

**Files:** `lib/routes/active_challenge_screen.dart` or new pre-challenge sheet  
**Source:** Section 10.5

**Changes:**
- Before starting the timer, show a bottom sheet with the challenge title +
  `+30s` / `-30s` buttons clamped to `[challenge.time / 2, challenge.time * 2]`
- Store overrides in SharedPreferences: `timer_override_<challengeId>` (int)
- `ActiveChallengeScreen` reads the override on init if present

---

### 5.4 Distinct haptic vocabulary

**File:** `lib/services/vibration_service.dart`  
**Source:** Section 10.5

**Changes:**
- `timerWarning()`: two short pulses (50ms on, 50ms off, 50ms on)
- `timerEnd()`: one 200ms pulse
- `success()`: rising pattern (50ms, 50ms, 150ms)
- `milestone()`: 500ms at max intensity
- Gate all patterns behind a capability check
  (`Vibration.hasCustomVibrationsSupport()`)

---

## Phase 6 — Custom Challenges (larger scope)

**Source:** Section 10.3

A dedicated `user_challenges` SQLite table for user-created challenges.

**Schema:**
```sql
CREATE TABLE user_challenges (
  id        INTEGER PRIMARY KEY AUTOINCREMENT,
  title     TEXT NOT NULL,
  description TEXT,
  hint      TEXT,
  xp        INTEGER NOT NULL,
  duration  INTEGER NOT NULL,
  created_at DATETIME
);
```

**Constraints:**
- Custom challenges do **not** count toward CZL unlock progression
- Custom challenges appear in the challenge list with a `custom` badge
- No level assignment (shown at all CZL levels)

**Files to create/modify:**
- `lib/data/user_challenge_repository.dart` (new)
- `lib/routes/create_challenge_screen.dart` (new — wires up `priming_screen.dart`
  concept)
- `lib/providers/challenge_providers.dart` — merge custom challenges into
  `filteredChallengesProvider`
- DB version bump to 4

---

## Phase 7 — Social Features (requires backend, future)

These are directional only. They cannot be implemented in the current
offline-first architecture.

- **Real social proof** — anonymous challenge completion counts via a minimal
  REST API (replace the deterministic hash)
- **Accountability partner** — share a "streak code" with a friend; their
  streak is visible alongside yours
- **Community feed** — anonymously posted challenge completions in your region

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

- `PrimingScreen` is now fully on GoRouter (Phase 1.5 — branch `refactor/priming-gorouter`).
- All 127 challenges are assigned levels 1–5 only. Levels 6–10 exist in the system
  but no challenge content covers them yet.
- `NotificationManager` and `SyntraNotificationService` overlap cleaned up (Phase 1.4 — branch `refactor/notification-cleanup`).
- `SharedPreferences.getInstance()` injection done (Phase 1.6 — branch `refactor/shared-prefs-provider`).
- Screen files are still monolithic (Phase 1.7):
  `challenges_screen.dart` 965 lines, `onboarding_screen.dart` 864 lines, etc.
Phase 0 (bugs)       ← must ship first, blocks release
  └─ Phase 1.1       (Challenge immutability)
  └─ Phase 1.2       (level field) ← blocks 4.2
Phase 1.3            (GoRouter) ← independent
Phase 1.4            (notification merge) ← independent
Phase 1.5            (dead code) ← independent
Phase 1.6            (SharedPrefs inject) ← blocks Phase 2.1
Phase 1.7            (file split) ← blocks Phase 2.1
Phase 2.1            (widget tests) ← should follow 1.6 + 1.7
Phase 3.1            (reflection history) ← blocks 5.2 (detail screen)
Phase 3.2            (personal best) ← independent
Phase 3.3            (repeat suggestion) ← independent
Phase 3.4            (env filter) ← independent
Phase 4.1            (badges) ← requires Phase 1.6
Phase 4.2            (CZL visual) ← requires Phase 1.2
Phase 4.3            (weekly goal) ← independent
Phase 4.4            (weekly recap) ← requires Phase 1.4
Phase 5.1            (logbook search) ← independent
Phase 5.2            (challenge detail) ← requires Phase 3.1
Phase 5.3            (timer custom) ← independent
Phase 5.4            (haptics) ← independent
Phase 6              (custom challenges) ← requires Phase 1.7, Phase 1.6
Phase 7              (social) ← requires backend (out of scope)
```

---

## Summary Table

| Phase | Item | Type | Effort |
|---|---|---|---|
| 0.1 | DB migration feeling/perception | Bug fix | XS |
| 0.2 | challenge_id type contract | Bug fix | S |
| 1.1 | Challenge fields final | Refactor | XS |
| 1.2 | Explicit level in JSON | Refactor | S |
| 1.3 | Navigator → GoRouter | Refactor | S |
| 1.4 | Merge notification classes | Refactor | M |
| 1.5 | Wire or delete dead screens | Cleanup | XS |
| 1.6 | SharedPrefs provider injection | Refactor | S |
| 1.7 | Split large screen files | Refactor | M |
| 2.1 | Widget tests | Testing | M |
| 3.1 | Reflection history | Feature | M |
| 3.2 | Personal best streak | Feature | S |
| 3.3 | Repeat suggestion | Feature | S |
| 3.4 | Environment filter | Feature | S |
| 4.1 | Badges system | Feature | M |
| 4.2 | CZL visual identity | Feature | S |
| 4.3 | Weekly goal setting | Feature | S |
| 4.4 | Weekly recap notification | Feature | S |
| 5.1 | Logbook search | Feature | M |
| 5.2 | Challenge detail screen | Feature | M |
| 5.3 | Timer customization | Feature | S |
| 5.4 | Haptic vocabulary | Polish | XS |
| 6 | Custom challenges | Feature | L |
| 7 | Social features | Future | XL |

Effort scale: XS < 1h · S = 1–3h · M = 3–8h · L = 1–3d · XL = requires backend
