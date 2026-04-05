# Syntra

> Build real social confidence through deliberate real-world challenges.

Syntra is an offline-first Flutter app that helps you step outside your comfort zone — one social challenge at a time. Accept challenges, run a countdown timer, go do it in the real world, then log how it went. Earn Aura Points, build streaks, and unlock harder challenges as you grow.

---

## Features

- **Comfort Zone Level (CZL)** — 5-level progression system. Challenges are gated by level; complete 3 at your current level to unlock the next tier.
- **Mission Board** — three daily challenges (Comfort / Growth / Bold) with a 10% Aura bonus for completing them.
- **Aura Points** — XP awarded per challenge based on difficulty and how long you lasted. Tracked all-time, shown in charts.
- **Streak system** — consecutive days of completing challenges. Celebrated with an animated screen at milestones (3, 7, 14, 30, 60, 100 days).
- **Badges** — 8 achievement badges earned by hitting XP, streak, and completion milestones.
- **Weekly goal** — set a challenge target (3 / 5 / 7 per week) and track progress.
- **Logbook** — every attempt stored locally with your mood rating, perception rating, and optional notes.
- **Activity heatmap** — GitHub-style 12-week calendar showing daily activity intensity.
- **Mood tracking** — per-challenge mood history chart and 14-day average mood line chart.
- **Priming screen** — motivational framing shown before each challenge starts.
- **Local notifications** — up to 3 configurable daily reminders (morning / afternoon / evening). Exact-alarm scheduling on Android via AlarmManager; rescheduled automatically on boot, update, and timezone change.
- **Sound effects** — optional audio feedback for challenge start, success, and failure.
- **Haptic feedback** — vibration at timer start, 10-second warning, timer end, success, and streak milestones.
- **Dark / light / system theme** — Material 3 design with a neon pink seed color.
- **Two languages** — English and German, switchable at runtime.
- **Onboarding** — 7-page flow covering how it works, CZL starting level selection, and notification setup.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State management | Riverpod 2.x |
| Navigation | go_router |
| Local database | SQLite via sqflite (schema v4) |
| Settings | SharedPreferences |
| Charts | fl_chart |
| Notifications | flutter_local_notifications + native AlarmManager (Android) |
| Audio | audioplayers |
| Haptics | vibration |
| Localization | flutter_intl (ARB files) |

---

## Project Structure

```
lib/
├── main.dart                  Boot: copy DB, migrate settings, init router
├── challenge.dart             Immutable Challenge data model
├── home_bar.dart              Bottom-nav shell (4 tabs, PageView)
├── router.dart                GoRouter config + AppNavigation helpers
├── static.dart                Notification message pools + streak milestones
│
├── theme/
│   ├── app_theme.dart         Material 3 light/dark themes (seed: #FF10F0)
│   └── app_spacing.dart       8-point grid constants
│
├── data/
│   ├── challenge_repository.dart   JSON catalog loader with per-language cache
│   ├── logbook_repository.dart     SQLite CRUD + stat queries (schema v4)
│   └── settings_repository.dart   SharedPreferences wrapper (single source of truth)
│
├── providers/
│   ├── challenge_providers.dart    Catalog, CZL filter, challenge filters
│   ├── settings_providers.dart     Theme, locale, notifications, CZL, sound
│   ├── statistics_providers.dart   Stats/charts FutureProviders + refresh signal
│   └── router_notifier.dart        Onboarding guard for GoRouter
│
├── logic/
│   ├── comfort_zone_logic.dart     CZL level assignment + unlock progression
│   ├── daily_missions_logic.dart   Three-tier daily mission selection
│   ├── badges_logic.dart           Badge definitions + earned-set computation
│   └── notification_manager.dart   Scheduling logic (next occurrences, batch)
│
├── routes/
│   ├── onboarding_screen.dart
│   ├── challenges_screen.dart
│   ├── challenge_detail_screen.dart
│   ├── active_challenge_screen.dart
│   ├── challenge_done_screen.dart
│   ├── daily_challenge_screen.dart
│   ├── statistics_screen.dart
│   ├── logbook_page.dart
│   ├── logbook_detail_page.dart
│   ├── settings_screen.dart
│   ├── streak_celebration_screen.dart
│   ├── priming_screen.dart
│   └── about_page.dart
│
├── services/
│   ├── syntra_notification_service.dart
│   ├── sound_service.dart
│   └── vibration_service.dart
│
└── widgets/
    ├── challenge_card.dart
    ├── syntra_button.dart
    ├── syntra_progress_bar.dart
    └── ...

assets/
├── challenge_database.db          Logbook SQLite DB (copied to device on first run)
└── data/
    ├── challenges.json            Challenge catalog (XP, timer, type, level, environment)
    └── translations/
        ├── en.json
        └── de.json
```

---

## Architecture Decisions

**Offline-first, no account required.**
All data lives on the device. SQLite stores the logbook; SharedPreferences stores settings. No cloud sync, no login.

**Challenge catalog is JSON, not SQL.**
The catalog is read-only at runtime. Storing it in JSON assets (with a separate translation file per language) makes it trivial to edit, version-control, and swap without touching the database.

**Riverpod for all state.**
Every piece of mutable state is a Riverpod provider. `statisticsRefreshProvider` acts as a manual invalidation signal — bumping it forces all stat providers to reload after a logbook write.

**Comfort Zone Level is percentile-based (for now).**
CZL levels are assigned by sorting all challenges by XP and bucketing by percentile. This is simple but catalog-sensitive — a planned improvement is to add an explicit `level` field to `challenges.json`.

**Android notifications use AlarmManager, not just the Flutter plugin.**
`flutter_local_notifications` alone cannot guarantee exact timing when the device is in Doze mode. The native Kotlin layer uses `setExactAndAllowWhileIdle()` and a `BroadcastReceiver` that reschedules on boot, app update, and timezone changes.

---

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run on connected device or emulator
flutter run

# Run tests
flutter test
```

Requires Flutter 3.x and Dart SDK ^3.8.1.

---

## Roadmap

- Weekly streak system (replace daily streak — more forgiving, rewards consistent use)
- New challenge content (6 per category, explicit difficulty levels, updated tags)
- Streak Shield + app themes (spend Aura Points, merged into Profile/Stats tab)
- Weekly goal completion animation
- Backend + leaderboard (Firebase sync, social ranking — planned after v1 is stable)
