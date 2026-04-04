# Syntra — Development Roadmap

Generated: 2026-04-03 · Last updated: 2026-04-04 (Phase 3 complete)
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
 └─ [PR] refactor/notification-cleanup              ← merge EIGHTH (independent)
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
| 1.7 | Split large screen files into `widgets/` subdirectories | — | **TODO** (deferred; Phase 2 tests written against monolithic files) |

### CZL Expansion

| # | Task | Branch | Status |
|---|---|---|---|
| CZL | `hints: List<String>` replaces pipe-delimited string | `refactor/challenge-model` | **Done** |
| CZL | `maxLevel` 5→10, new level names 6–10 | `refactor/czl-expand` | **Done** |
| CZL | Assign levels 6–10 to actual challenges in `challenges.json` | — | **TODO** (all 127 challenges currently assigned levels 1–5 only) |
| CZL | Add challenges for levels 6–10 to the catalog | — | **TODO** (content work) |

---

## Phase 2 — Testability

| # | Task | Status |
|---|---|---|
| 2.1 | `SharedPreferences` Riverpod provider for injection | **Done** (1.6) |
| 2.2 | Widget tests for `ChallengeCard`, `ChallengeDoneScreen`, `ActiveChallengeScreen` | **Done** (`test/widget/`, branch `test/widget-tests`) |

---

## Phase 3 — Core Loop Depth ✓

| # | Task | Status |
|---|---|---|
| 3.1 | Challenge reflection history (mood trend chart per challenge in logbook) | **Done** (`_MoodChart` in detail sheet, `moodHistoryProvider`) |
| 3.2 | Personal best streak tracking (`all_time_max_streak` in SharedPrefs) | **Done** (`personalBestStreakProvider`, Best Streak card in stats grid) |
| 3.3 | Repeat challenge suggestion after abort | **Done** ("Try Again" button → `pushReplacement` fresh `ActiveChallengeScreen`) |
| 3.4 | Context-aware environment filter (session chip, not persisted) | **Skipped** — all 127 challenges have `environment: "all"`, filter would be useless |

## Phase 0 — Pre-Release Bug Fixes (blocker)

These must ship before any public release. They are data-integrity issues that
will cause crashes or silent corruption for users upgrading from an earlier build.

---

### 0.1 Fix logbook DB migration — `feeling` / `perception` columns

**File:** `lib/data/logbook_repository.dart`  
**Problem (Problem #1):** The `logbook` table schema at version 2 includes
`feeling INTEGER` and `perception INTEGER` in the `CREATE TABLE` statement, but
the `onUpgrade` handler only adds `duration_seconds` (v1 → v2). Any user who
had the DB at version 1 will get `"table logbook has no column named feeling"`
on the first `addEntry()` call.

**Fix:**
- Bump DB version to `3`
- Add a new `if (oldVersion < 3)` branch in `onUpgrade` that runs:
  ```sql
  ALTER TABLE logbook ADD COLUMN feeling INTEGER;
  ALTER TABLE logbook ADD COLUMN perception INTEGER;
  ```

---

### 0.2 Fix `challenge_id` type mismatch — DB vs Dart

**Files:** `lib/data/logbook_repository.dart`, `lib/challenge.dart`  
**Problem (Problem #2):** `Challenge.id` is a `String` in Dart; the SQLite
column is `INTEGER`. The coercion works while IDs stay numeric, but
`completedChallengeIds()` already works around it with `.toString()`. A
non-numeric ID would corrupt the logbook silently.

**Fix (pick one, document the contract):**
- Option A (minimal): Change the DB column to `TEXT` via a migration, update
  all query bindings to pass the string as-is.
- Option B (type-safe): Change `Challenge.id` to `int` throughout Dart and use
  `.toString()` only at display boundaries.

---

## Phase 1 — Code Quality & Architecture (before adding features)

Completing this phase makes every future feature faster and safer to build.
Items are ordered from highest to lowest leverage.

---

### 1.1 Make `Challenge` fields `final`

**File:** `lib/challenge.dart`  
**Problem (Problem #9):** All fields use `var`, making instances mutable after
construction. Nothing in the codebase mutates a `Challenge` after loading.

**Changes:**
- Replace all `var` with `final`
- Remove `toMap()` (challenges are never written back to DB)
- Keep or clean up `fromMap()` to match current JSON field names (it is vestigial)

---

### 1.2 Add a `level` field to `challenges.json`

**Files:** `assets/data/challenges.json`, `lib/logic/comfort_zone_logic.dart`,
`lib/challenge.dart`  
**Problem (Problem #6):** Level assignment is computed at runtime by percentile
across the whole catalog. Adding or removing any challenge shifts every
challenge's level, potentially invalidating stored `czl_completions_N` counts.

**Changes:**
- Add `"level": 1–5` to each entry in `challenges.json` (curate manually)
- Add `final int level` field to `Challenge`
- Replace `ComfortZoneLogic.assignLevel()` with a direct read of `challenge.level`
- Delete the percentile-sorting logic

---

### 1.3 Migrate `Navigator.push` calls to GoRouter

**Files:** `lib/routes/active_challenge_screen.dart`,
`lib/routes/challenge_done_screen.dart`, `lib/home_bar.dart`  
**Problem (Problem #4):** Three screens use the old `Navigator.of(context).push`
API, bypassing GoRouter. This breaks deep links and makes back-stack behaviour
unpredictable.

**Changes:**
- `ActiveChallengeScreen` → replace `Navigator.push<double>(MaterialPageRoute →
  ChallengeDoneScreen)` with `context.push('/challenge_done', extra: ...)`,
  use the returned `Future<double?>` for the reward factor
- `ChallengeDoneScreen` → replace `Navigator.push → StreakCelebrationScreen`
  with `context.goStreakCelebration(streak, isMilestone)`
- `HomeBar._showStreakCelebration` → same `context.goStreakCelebration(…)` call

---

### 1.4 Merge the two notification classes

**Files:** `lib/services/syntra_notification_service.dart` (~850 lines),
`lib/logic/notification_manager.dart` (~640 lines)  
**Problem (Problem #7):** The two classes overlap heavily. `cancelAllNotifications`
currently triple-cancels via three separate code paths in the same call.

**Target ownership split:**
- `SyntraNotificationService`: plugin init, permission, schedule/cancel (low-level)
- `NotificationManager`: next-occurrence calculation, batch build, uses
  `SyntraNotificationService` as its only backend — no direct plugin calls

**Changes:**
- Remove all direct `_notificationsPlugin` calls from `NotificationManager`
- Remove the duplicated `MethodChannel` call in `NotificationManager.cancelAllNotifications`
- Ensure `cancelAllNotifications` calls `SyntraNotificationService.cancelAllNotifications`
  exactly once

---

### 1.5 Wire or delete `priming_screen.dart` and `mindset_screen.dart`

**Files:** `lib/routes/priming_screen.dart` (243 lines),
`lib/routes/mindset_screen.dart` (287 lines)  
**Problem (Problem #8):** Both files are fully implemented but have no route
registration and no navigation entry point — unreachable dead code.

**Decision required:**
- If these screens are roadmapped (see §3.3 Custom Challenges, §3.4 CZL visual
  identity): add routes in `router.dart` + navigation entry points now
- If uncertain: **delete both files** until they are actually needed

---

### 1.6 Inject `SharedPreferences` via a Riverpod provider

**Files:** `lib/providers/challenge_providers.dart`,
`lib/providers/settings_providers.dart`, all `Notifier` subclasses  
**Problem (Problem #10):** Every `StateNotifier` calls
`SharedPreferences.getInstance()` directly. This is non-injectable and
untestable.

**Changes:**
- Add `sharedPreferencesProvider` as a `Provider<SharedPreferences>` that
  throws `UnimplementedError` (must be overridden in tests)
- Override it with the real instance in `main.dart` before `runApp`
- Refactor all `Notifier` constructors to `ref.read(sharedPreferencesProvider)`
  instead of calling `getInstance()` directly

---

### 1.7 Split large screen files into widget subdirectories

**Problem (Problem #3):** Five screens are 500–965 lines each, making code
navigation and testing difficult.

**Target structure:**

```
lib/routes/
  challenges/
    challenges_screen.dart          (orchestrator, <150 lines)
    widgets/
      challenge_list_item.dart
      challenge_filter_bar.dart
      challenge_filter_sheet.dart
      czl_progress_card.dart

  statistics/
    statistics_screen.dart
    widgets/
      stat_overview_card.dart
      weekly_xp_chart.dart
      weekly_counts_chart.dart
      activity_heatmap_grid.dart

  settings/
    settings_screen.dart
    widgets/
      notification_slot_tile.dart

  onboarding/
    onboarding_screen.dart
    widgets/
      onboarding_page_*.dart        (one per page)

  challenge_done/
    challenge_done_screen.dart
    widgets/
      survey_widget.dart
      xp_reward_card.dart
      level_up_dialog.dart
```

---

## Phase 2 — Testability

---

### 2.1 Add widget tests

**File:** `test/widget/` (new directory)  
**Problem (Suggestion #9):** Widget test coverage is currently zero. The five
unit tests cover only logic.

**Minimum test additions:**
- `challenge_card_test.dart` — title, XP badge, type badge render
- `challenge_done_screen_test.dart` — survey state transitions, XP count-up
  animation, bonus badge visibility
- `active_challenge_test.dart` — timer display, abort-lock countdown, abort
  button appears at t=0

Use `ProviderScope` overrides (from §1.6) to inject mock data without SQLite.

---

## Phase 3 — Core Loop Depth (high-impact features)

These use data the app already collects. No new infrastructure needed.

---

### 3.1 Challenge reflection history in logbook

**Files:** `lib/routes/logbook_detail_page.dart`,
`lib/data/logbook_repository.dart`  
**Source:** Section 10.1

The survey data (`feeling`, `perception`, `notes`) is stored but never shown
back to the user.

**Changes:**
- Add `LogbookRepository.attemptsForChallenge(challengeId)` → `List<Map>`
  (all entries for this challenge, ordered by date)
- In `LogbookDetailPage`, add a "Your history with this challenge" section:
  - Mini chart (feeling over time, dots connected by line) using `fl_chart`
  - List of past attempts with date + feeling emoji + notes preview
- If only one attempt exists, show an encouraging "First attempt!" message

---

### 3.2 Personal best streak tracking

**Files:** `lib/data/logbook_repository.dart`,
`lib/data/settings_repository.dart`,
`lib/routes/statistics_screen.dart`  
**Source:** Section 10.1

**Changes:**
- Add `all_time_max_streak` key to `SettingsRepository`
- In `comfortZoneLevelProvider.notifier.recordSuccessAndCheckLevelUp` (or
  wherever streak is computed after a success), compare current streak to stored
  max and update if higher
- Display "Personal best: X days" alongside current streak on the stats screen

---

### 3.3 Repeat challenge suggestion after failure/low mood

**Files:** `lib/routes/challenge_done_screen.dart`,
`lib/data/logbook_repository.dart`  
**Source:** Section 10.1

After abort or a feeling rating ≤ 1, show a card: "Want to try something
a bit easier?" with one lower-XP challenge of the same type.

**Changes:**
- Add `LogbookRepository.suggestEasierChallenge(type, maxXp, excludeIds)`
  query
- In `ChallengeDoneScreen._onBackToHome`, if `_isAborted` or `_feeling <= 1`,
  pass the suggestion as part of the navigation extras to the home screen
- Show a dismissible suggestion card at the top of `ChallengesScreen` if set

---

### 3.4 Context-aware environment filter

**Files:** `lib/routes/challenges_screen.dart`,
`lib/providers/challenge_providers.dart`  
**Source:** Section 10.3

The `environment` field exists on `Challenge` but the filter was removed.

**Changes:**
- Add a horizontal chip row above the challenge list: `Street / Transport /
  Work / Home` — "Where are you right now?"
- This is a *session filter* (not persisted), cleared when the user leaves
  the screen
- Add `environmentFilter` to `ChallengeFilters` but do not persist it to
  SharedPreferences

---

## Phase 4 — Progression & Motivation

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

## Known Remaining Issues (not yet branched)

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
