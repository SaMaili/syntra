# Syntra UI Style Guide

This document defines the visual language, interaction patterns, and psychological design principles behind Syntra. Every screen, widget, and animation should reinforce the same goal: **make facing social discomfort feel like a game the user wants to keep playing.**

---

## 1. Psychological Framework

### 1.1 Core Loop: Challenge > Reward > Reflect > Return

Syntra's UX is built around a habit loop borrowed from game design:

1. **Trigger** — Daily notifications with warm, varied copy ("Your next win is waiting") pull the user back. Three configurable time slots ensure the app meets them where they are.
2. **Action** — A short, time-boxed challenge with a live countdown. The timer creates urgency without anxiety because it counts *down to success*, not failure.
3. **Variable Reward** — XP, coach messages, social proof ("~2,400 people did this one"), and a rotating quote card. Variability keeps dopamine flowing.
4. **Investment** — The post-challenge survey (feeling + perception + notes) makes the user reflect, deepening commitment. The logbook and heatmap give them something to lose if they stop.

### 1.2 No Punishment, Ever

Failure is reframed, never penalized:

- XP is never subtracted. Aborted challenges earn `+0 XP` with the label "you showed up."
- Copy on failure is normalizing: *"That one was hard. Showing up and trying is the whole game."*
- Haptics never fire on failure — vibration is reserved exclusively for positive events.
- The logbook records `status: 'tried'`, not `status: 'failed'`.

This asymmetry is deliberate. Punishing failure creates avoidance. Rewarding *any* attempt creates approach behavior, which is exactly what a social confidence app needs.

### 1.3 Streaks & Milestones

Streaks are the backbone of retention:

- A fire badge appears in the daily mission header once the streak is >= 1.
- Milestone celebrations (3, 7, 14, 30, 60, 100 days) trigger a full-screen dialog with haptic feedback (`VibrationService.milestone()`).
- Streak data is shown in the statistics heatmap — the user can *see* consistency forming.

### 1.4 Comfort Zone Leveling

A 3-tier progression system (levels 1-3) unlocks harder challenges as the user proves readiness. Each level-up triggers a celebration dialog. This gives the app an RPG-like progression arc beyond daily XP.

### 1.5 Clean Consistency = Trust

Every pixel of visual inconsistency — a misaligned margin, a rogue color, a janky transition — erodes the user's unconscious trust. Syntra must feel *solid*. The rules below exist to make the app feel like a single, intentional surface.

---

## 2. Color System

### 2.1 Material 3 Seed Color

All colors derive from a single seed:

```dart
static const Color seedColor = Color(0xFF5C2CAF); // Grape purple
```

Flutter's Material 3 engine generates the full tonal palette (light and dark) from this seed. **Never define colors manually** — use `Theme.of(context).colorScheme`.

### 2.2 ColorScheme Token Usage

| Token | When to use |
|---|---|
| `cs.primary` | Primary actions, active states, progress bars, completion indicators, chart "success" bars |
| `cs.onPrimary` | Text/icons on `cs.primary` backgrounds |
| `cs.primaryContainer` | Elevated surfaces for hero content (XP chip, level badge, growth story card) |
| `cs.onPrimaryContainer` | Text/icons on `primaryContainer` |
| `cs.secondary` | Supporting accents (mindset tips icon, secondary actions) |
| `cs.secondaryContainer` | Secondary elevated surfaces (quote card, aborted-state button bg) |
| `cs.tertiary` | Accent for data emphasis (streak badge, "tried" chart bars, notification slot 1) |
| `cs.tertiaryContainer` | Milestone celebration icon backgrounds |
| `cs.error` | Destructive actions (delete button bg), bold-tier challenge indicator |
| `cs.onError` | Text/icons on `cs.error` backgrounds |
| `cs.surface` | Default scaffold/card background |
| `cs.surfaceContainerHighest` | Recessed/disabled surfaces (abort-state icon bg, hint containers, inactive progress track) |
| `cs.onSurface` | Primary body text |
| `cs.onSurfaceVariant` | Secondary/muted text, subtitles, timestamps |
| `cs.outline` | Borders, meta chip text, divider-weight elements |
| `cs.outlineVariant` | Unselected/inactive icon tint (e.g., unselected smiley) |

### 2.3 Semantic Colors (Exceptions)

Some colors carry universal meaning and must *not* be theme-derived:

**Feeling scale** (5-point smiley rating):
```
Colors.red → Colors.orange → Colors.amber → Colors.lightGreen → Colors.green
```
This red-to-green gradient is a universally understood sentiment spectrum. Theming it purple would destroy legibility.

**XP indicators** in logbook detail:
```
positive XP → Colors.green
zero XP     → Colors.amber
negative XP → Colors.red
```

These semantic colors appear only in data visualization contexts (survey smileys, logbook entries, detail cards). They are never used for structural UI like buttons, cards, or backgrounds.

### 2.4 Rules

- **Never use `Colors.xxx` for structural UI.** No `Colors.white`, `Colors.grey`, `Colors.black`. Use `cs.surface`, `cs.outline`, `cs.onSurface`.
- **Never use `.withOpacity()`.** Use `.withValues(alpha: 0.XX)` (the non-deprecated API).
- **Never check `isDark` to pick colors.** The ColorScheme already adapts. If you find yourself writing `isDark ? colorA : colorB`, you are working around the theme instead of with it.
- **No gradients on screen backgrounds.** Syntra screens use flat `Scaffold` backgrounds. The only exception is `MindsetScreen`, which uses a subtle `primaryContainer → secondaryContainer` gradient because it is static motivational content, not an interactive workflow.

---

## 3. Typography

### 3.1 TextTheme Tokens

All text uses `Theme.of(context).textTheme`:

| Token | Typical usage |
|---|---|
| `tt.headlineSmall` | Screen/section headlines ("Congratulations", stat values) |
| `tt.titleLarge` | XP display in result screens |
| `tt.titleMedium` | Card section headers, survey question labels |
| `tt.titleSmall` | Compact card headers (growth story) |
| `tt.bodyLarge` | Primary content text, coach messages, encouragement copy |
| `tt.bodyMedium` | Description text, narrative story sentences, tip items |
| `tt.bodySmall` | Timestamps, social proof line, chart explanations |
| `tt.labelMedium` | Streak badge text, meta info |
| `tt.labelSmall` | Progress labels, chart axis labels, meta chips |

### 3.2 Rules

- **Never use raw `TextStyle(fontSize: XX)`.** Always start from a textTheme token and `.copyWith()` overrides.
- **`fontWeight: FontWeight.bold`** for headlines and values. **`FontWeight.w600`** for section headers and buttons. **`FontWeight.w500`** for emphasized body text.
- Color overrides on text always use ColorScheme tokens (`cs.onPrimaryContainer`, `cs.onSurfaceVariant`, etc.), never hardcoded values.

---

## 4. Spacing & Layout

### 4.1 The 8-Point Grid

All spacing uses `AppSpacing` constants:

```dart
xs  =  4    // Tight gaps (between icon and label, vertical padding in chips)
sm  =  8    // Small gaps (between related elements, list separator height)
md  = 16    // Standard padding (card padding, horizontal page margin)
lg  = 24    // Section spacing (between card groups, dialog padding)
xl  = 32    // Major section breaks (top/bottom page padding, between content zones)
xxl = 48    // Hero spacing (rarely used, reserved for splash/empty states)
```

### 4.2 Border Radii

```dart
cardRadius   = 20   // Cards, dialogs, containers
buttonRadius = 16   // FilledButton, OutlinedButton, TextButton
chipRadius   = 24   // Chips, badges, pill-shaped indicators
```

### 4.3 Rules

- **Never use magic numbers for spacing.** No `SizedBox(height: 10)` or `EdgeInsets.all(18)`. Round to the nearest AppSpacing value.
- Page-level horizontal padding is always `AppSpacing.md` (16).
- Card internal padding is `AppSpacing.md` (16) for standard cards, `AppSpacing.lg` (24) for hero/celebration cards.
- Dialog padding is `AppSpacing.xl` (32).

---

## 5. Components

### 5.1 Buttons

| Widget | When to use | Style |
|---|---|---|
| `FilledButton` | Primary action (Start challenge, Back to home, Save, Keep it up) | Theme default. No custom `backgroundColor` unless semantic (e.g., `cs.error` for delete). |
| `FilledButton.icon` | Primary action with leading icon (Back to home, Open logbook) | Same as above. |
| `FilledButton.tonalIcon` | Secondary emphasized action | Uses `secondaryContainer` tones automatically. |
| `OutlinedButton` | Secondary action (Cancel, Skip) | Theme default. |
| `TextButton` | Tertiary/low-emphasis action (Explore all challenges, toggle details) | Theme default. |
| `TextButton.icon` | Tertiary with icon | Same as above. |

**Never** build buttons from `Container` + `InkWell` + manual styling. The theme already defines padding (`horizontal: 24, vertical: 16`), border radius (16), and text style (`fontSize: 16, fontWeight: w600`).

For destructive actions:
```dart
FilledButton(
  style: FilledButton.styleFrom(
    backgroundColor: cs.error,
    foregroundColor: cs.onError,
  ),
  // ...
)
```

### 5.2 Cards

Use the `Card` widget. The theme sets `elevation: 0`, `borderRadius: 20`, and appropriate surface colors for light/dark mode. Never override these unless you have a specific reason.

For colored cards (e.g., the growth story card):
```dart
Card(
  color: cs.primaryContainer,
  child: // ...
)
```

### 5.3 Dialogs

Celebration/milestone dialogs use:
```dart
Dialog(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppSpacing.cardRadius * 2), // 40
  ),
  // ...
)
```

The extra radius makes celebrations feel special compared to standard cards (radius 20).

### 5.4 Chips & Badges

Tier badges, level indicators, and meta chips use `AppSpacing.chipRadius` (24) for the pill shape. Background colors use low-alpha theme tokens:

```dart
Container(
  decoration: BoxDecoration(
    color: cs.tertiary.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
    border: Border.all(color: cs.tertiary.withValues(alpha: 0.3)),
  ),
)
```

### 5.5 Progress Indicators

```dart
LinearProgressIndicator(
  value: progress,
  minHeight: 6,
  backgroundColor: cs.surfaceContainerHighest,
  valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
)
```

Always wrap in `ClipRRect` with `borderRadius: 4` for rounded ends.

### 5.6 Input Fields

The theme provides `InputDecorationTheme` with `borderRadius: 12` and `filled: true`. Use `TextField` with only semantic overrides (hintText, maxLines). Never style inputs manually.

---

## 6. Animations & Transitions

### 6.1 Principles

Animations serve three purposes in Syntra:

1. **Continuity** — Transitions between states should feel connected, not jumped. The user's eye should be able to follow content.
2. **Reward** — Celebrations (milestone dialogs, XP reveal, quote rotation) use animation to amplify the dopamine hit.
3. **Perceived speed** — Fade-ins and slide-ins make loading states feel intentional rather than broken.

### 6.2 Standard Durations

| Duration | Use |
|---|---|
| 200ms | Micro-interactions (chip selection, card scale) |
| 300ms | Standard transitions (opacity changes, content swap, filter animation) |
| 400ms | Page transitions (tab fly-over, screen push) |
| 500-600ms | Entrance animations (fade-in on screen load, pulse setup) |

### 6.3 Curves

| Curve | Use |
|---|---|
| `Curves.easeInOutCubicEmphasized` | Tab navigation fly-over (the signature Syntra page transition) |
| `Curves.easeInOutCubic` | Content transitions (challenge list filter, expand/collapse) |
| `Curves.easeIn` | Fade-in on screen entrance (active challenge, logbook detail) |
| `Curves.easeInOut` | General-purpose (card scale, notification permission widget) |

### 6.4 Key Animations

- **Tab navigation**: `PageView` with `Curves.easeInOutCubicEmphasized` (400ms). Tabs retain state via `AutomaticKeepAliveClientMixin`. This fly-over effect is the app's signature navigation feel.
- **Quote rotation**: `AnimatedSwitcher` (300ms) in `MindsetScreen` — content cross-fades on button tap.
- **Challenge card scale**: `AnimatedScale` (200ms) in challenges list — subtle press feedback.
- **Completed mission**: `AnimatedOpacity` to 0.55 (300ms) — done missions visually recede without disappearing.
- **Screen entrance**: `FadeTransition` with `CurvedAnimation(curve: Curves.easeIn)` over 500-600ms on `ActiveChallengeScreen` and `LogbookDetailPage`.
- **Timer pulse**: `AnimationController` with `repeat(reverse: true)` for the "Done" button glow when main time expires.

### 6.5 Rules

- **No animation without purpose.** If an animation doesn't serve continuity, reward, or perceived speed, remove it.
- **No `setState` rebuilds for animation.** Use `AnimatedFoo` implicit animations or explicit `AnimationController` with `AnimatedBuilder`. Never call `setState` in a tight loop.
- **Haptics accompany key moments.** When a celebration dialog appears, `VibrationService.milestone()` fires. When a challenge starts, `VibrationService.start()` fires. Animation and haptics are always paired for reward moments.

---

## 7. Haptic Vocabulary

Syntra uses a semantic haptic system. Call sites reference intent, not raw vibration values:

| Method | Trigger | Pattern |
|---|---|---|
| `accept()` | Challenge accepted, swipe right | Light single tap (40ms) |
| `start()` | Challenge timer begins | Short double pulse |
| `timerWarning()` | 10 seconds remaining | Single long buzz (400ms) |
| `timerEnd()` | Timer hits zero | Three short pulses |
| `success()` | Challenge completed | Strong single vibration (600ms) |
| `milestone()` | Streak milestone or level-up | Complex rising pattern |
| *(nothing)* | Challenge failed/aborted | **No vibration. Never punish with haptics.** |

---

## 8. Notification Copy

Notifications are the app's re-engagement mechanism. The copy must feel like a friend nudging, not an app nagging:

- Varied pool (8 messages per language) so users don't see the same one twice in a row.
- Tone: encouraging, casual, sometimes playful ("You are the sun! But what is the sun if it can't shine?").
- Always actionable ("Do a challenge!", "Try a challenge today!").
- Title uses the app name ("Syntra Motivation" / "Syntra Erinnerung") to build brand familiarity.

---

## 9. Dark Mode

Dark mode is handled entirely by Material 3's `brightness: Brightness.dark` with the same seed color. **No manual dark-mode color definitions.** The only light-mode-specific values are:

- `scaffoldBackgroundColor: Color(0xFFF7F3F2)` — a warm off-white that feels less clinical than pure white.
- `cardTheme.color: Colors.white` — cards pop slightly above the warm scaffold in light mode.

In dark mode, both values are omitted and Flutter's defaults take over.

---

## 10. Checklist for New Screens

Before merging any new screen or widget:

- [ ] All colors from `Theme.of(context).colorScheme` (no `Colors.xxx` for structural UI)
- [ ] All text from `Theme.of(context).textTheme` (no raw `TextStyle(fontSize:)`)
- [ ] All spacing from `AppSpacing` constants (no magic numbers)
- [ ] Buttons use `FilledButton` / `OutlinedButton` / `TextButton` (no custom Container buttons)
- [ ] Cards use `Card` widget with theme defaults
- [ ] Border radii use `AppSpacing.cardRadius` / `buttonRadius` / `chipRadius`
- [ ] Screen has `Scaffold` with flat background (no gradient)
- [ ] Animations use standard durations and curves from section 6
- [ ] Haptic feedback uses `VibrationService` semantic methods
- [ ] No `isDark` conditionals for color picking
- [ ] No `.withOpacity()` — use `.withValues(alpha:)` instead
- [ ] Failure states never punish (no negative XP, no negative haptics, normalizing copy)
