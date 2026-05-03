# Syntra

> Build real social confidence through deliberate real-world challenges.

Syntra is an offline-first Flutter app that helps you step outside your comfort zone — one social challenge at a time. Accept a challenge, run a countdown timer, go do it in the real world, then log how it went. Earn Aura Points, build weekly streaks, and progress through ten levels of social mastery.

---

## Features

- **Comfort Zone Level (CZL)** — 10-level progression system from *Warming Up* (micro-interactions) to *Untouchable* (high-stakes social exposure). Challenges are gated by level; completion thresholds grow with each level so early progress feels fast and later mastery requires real commitment.
- **Prediction-Reality Gap** — rate your pre-challenge anxiety before starting; after completing, the app tracks the gap between what you feared and what you felt. Repeated exposure to this data is the core mechanism for reducing social anxiety.
- **Mission Board** — three daily challenges (Comfort / Growth / Bold tier) with a 10% Aura bonus for completing them.
- **Aura Points** — awarded per challenge based on difficulty and timer efficiency.
- **Weekly streak** — earn ≥300 Aura in a Mon–Sun week to keep your streak alive. Streak freezes protect missed weeks. Celebrated with animated milestone screens.
- **Badges** — 17 badges: 8 achievement badges (completions, Aura, streak milestones, brave minutes) plus one badge per CZL level reached.
- **Weekly goal** — set a challenge target (3 / 5 / 7 per week) and track progress.
- **Logbook** — every attempt stored locally with mood rating, perception rating, notes, duration, and pre-challenge anxiety score.
- **Mood tracking** — per-challenge mood history chart and rolling mood line chart.
- **Priming screen** — contextual framing shown before each challenge, including a 1–5 anxiety rating that feeds the prediction-gap system.
- **Local notifications** — up to 3 configurable daily reminders (morning / afternoon / evening). Exact-alarm scheduling on Android via AlarmManager; rescheduled automatically on boot, update, and timezone change.
- **Sound effects & haptics** — audio and vibration feedback at key moments including a 10-second timer warning.
- **Dark / light / system theme** — Material 3 with a neon pink seed color.
- **Two languages** — English and German, switchable at runtime.
- **Onboarding** — 7-page flow covering how it works, CZL starting level selection, and notification setup.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart 3.8+) |
| State management | Riverpod 2.x |
| Navigation | go_router |
| Local database | SQLite via sqflite |
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
├── main.dart                    Boot: init SharedPrefs, migrate settings, init router
├── challenge.dart               Immutable Challenge model + type/environment constants
├── challenge_ui.dart            UI extension: typeIcon, typeLabel, environmentLabel
├── home_bar.dart                Bottom-nav shell (4 tabs, PageView)
├── router.dart                  GoRouter config + AppNavigation extension helpers
│
├── theme/
│   ├── app_theme.dart           Material 3 light/dark themes (seed: #FF10F0)
│   └── app_spacing.dart         8-point grid constants
│
├── data/
│   ├── challenge_repository.dart    JSON catalog loader with per-language cache
│   ├── logbook_repository.dart      SQLite CRUD + stat queries
│   └── settings_repository.dart    SharedPreferences wrapper (single source of truth)
│
├── providers/
│   ├── challenge_providers.dart     Catalog, CZL filter, challenge filters, sort
│   ├── daily_providers.dart         DailyMissionsNotifier
│   ├── settings_providers.dart      Theme, locale, notifications, CZL, sound
│   ├── statistics_providers.dart    Stats/charts FutureProviders + refresh signal
│   ├── badges_providers.dart        Unlock-order tracking for badges
│   ├── prediction_gap_providers.dart  Per-challenge and overall gap insights
│   ├── note_providers.dart          Last note per challenge
│   └── shop_providers.dart          Aura economy + streak freeze inventory
│
├── logic/
│   ├── comfort_zone_logic.dart      10-level CZL progression
│   ├── daily_missions_logic.dart    Three-tier daily mission selection
│   ├── badges_logic.dart            17 badge definitions + sortByDisplay
│   ├── weekly_streak_logic.dart     ISO-week streak algorithm (pure, DST-safe)
│   ├── prediction_gap_logic.dart    Pre/post anxiety gap computation
│   └── notification_manager.dart   Scheduling logic (next occurrences, batch)
│
├── routes/
│   ├── onboarding_screen.dart
│   ├── challenges_screen.dart       + challenges/ subdirectory
│   ├── challenge_detail_screen.dart
│   ├── active_challenge_screen.dart
│   ├── challenge_done_screen.dart   + challenge_done/ subdirectory
│   ├── daily_challenge_screen.dart
│   ├── profile_screen.dart          + statistics/ subdirectory
│   ├── all_badges_page.dart
│   ├── logbook_page.dart
│   ├── logbook_detail_page.dart     + logbook/ subdirectory
│   ├── settings_screen.dart
│   ├── streak_celebration_screen.dart
│   ├── level_up_screen.dart
│   ├── badge_unlocked_screen.dart
│   ├── priming_screen.dart
│   └── about_page.dart
│
├── services/
│   ├── syntra_notification_service.dart
│   ├── sound_service.dart
│   └── vibration_service.dart
│
└── widgets/
    ├── badge_widgets.dart         BadgeTile, showBadgeInfoSheet
    ├── detail_card.dart           Reusable icon+title card
    ├── prediction_gap_card.dart   Gap insight display
    ├── challenge_card.dart
    ├── syntra_button.dart
    ├── syntra_progress_bar.dart
    └── ...

assets/
└── data/
    ├── challenges.json            Challenge catalog (112 challenges, IDs 0–111)
    └── translations/
        ├── en.json                Localized title/description/hints per challenge
        └── de.json
```

---

## Architecture Notes

**Offline-first, no account required.**
All data lives on the device. SQLite stores the logbook; SharedPreferences stores all settings. No cloud sync, no login.

**Challenge catalog is JSON, not SQL.**
The catalog is read-only at runtime. Storing it in JSON assets with a separate translation file per language makes it trivial to edit and version-control without touching the database. Difficulty levels are hand-curated explicit integers in the JSON — not computed at runtime.

**Riverpod for all state.**
Every piece of mutable state is a Riverpod provider. `statisticsRefreshProvider` acts as a manual invalidation signal — bumping it after any logbook write forces all stat providers to reload.

**Weekly streak, not daily.**
Requires ≥300 Aura in a Mon–Sun ISO week. Streak freezes (purchasable with Aura) protect up to 2 missed past weeks retroactively. This design handles travel, illness, and busy weeks without punishing the user for missing a single day.

**Prediction-reality gap is the core differentiator.**
Users rate anxiety before a challenge (1–5); the app computes the gap between predicted and actual feeling across all attempts. This is the mechanism most supported by clinical evidence for reducing social anxiety. The data pipeline is complete; the system surfaces insights per-challenge and in aggregate.

**Android notifications use AlarmManager, not just the Flutter plugin.**
`flutter_local_notifications` alone cannot guarantee exact timing in Doze mode. The native Kotlin layer uses `setExactAndAllowWhileIdle()` and a `BroadcastReceiver` that reschedules on boot, app update, and timezone changes.

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

- Prediction gap on the done screen — show the per-session comparison immediately after completing a challenge
- Weekly goal completion animation
- Shop UI — buy streak freezes with Aura (mechanics already implemented)
- Coach messages segmented by challenge type
- App theme unlocks (cosmetic seed-color themes purchasable with Aura)
- Backend + leaderboard (Firebase sync, social ranking — v2)
