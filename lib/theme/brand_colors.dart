import 'package:flutter/material.dart';

/// Single source of truth for the Syntra brand palette and gradient tokens.
///
/// Use [BrandColors] for hue accents that do NOT change between light and
/// dark mode (the neon pink primary, the orange tertiary, the success green,
/// the badge/info blues, the celebration yellows).
///
/// Use [SyntraSurface] for the layered grey ramp that DOES flip between
/// light and dark — card backgrounds, borders, dividers, mutes. Resolve via
/// `SyntraSurface.of(context)`.
///
/// Mode-independent grayscale ramps and special backdrops live as named
/// constants on [BrandColors] (e.g. [BrandColors.rootBg] for the level-up /
/// badge-unlock fullscreens).
abstract class BrandColors {
  // ─── Primary — Neon Pink ─────────────────────────────────────────
  /// Brand seed. Used as the Material `primary` in both themes.
  static const Color pink = Color(0xFFFF10F0);

  /// Lighter pink used in confetti palettes and active-challenge accents.
  static const Color pinkBright = Color(0xFFFF6BF6);

  /// Soft pink for dark-mode foregrounds and confetti tail.
  static const Color pinkSoft = Color(0xFFFFB7F5);

  // ─── Orange — Tertiary / Streak / Aura ──────────────────────────
  /// Reddish orange (`tertiary` in both themes). Used for streaks, "harder"
  /// prediction outcomes, and the FAB ring on dark.
  static const Color orange = Color(0xFFFF6D00);

  /// Warm peach for amber chip / coaching badges.
  static const Color orangeWarm = Color(0xFFFFB78A);

  /// Aura-week gradient start (vibrant).
  static const Color orangeHi = Color(0xFFFF7043);

  /// Aura-week gradient end (deep).
  static const Color orangeLo = Color(0xFFE65100);

  // ─── Green — Success / Improvement ──────────────────────────────
  /// Done / success / "easier than expected" outcomes.
  static const Color green = Color(0xFF10B981);

  /// Slightly softer green for delta chips.
  static const Color greenSoft = Color(0xFF34D399);

  /// Pale green tint for backgrounds and ring-fill on the mood ribbon.
  static const Color greenLight = Color(0xFFA7F3D0);

  /// Deep teal-green used by the logbook mood ribbon (dark-mode hero card).
  static const Color greenInk = Color(0xFF1F4F3D);

  /// Even darker green for the mood ribbon gradient tail.
  static const Color greenInkDark = Color(0xFF163828);

  // ─── Blue — Info / Freeze ───────────────────────────────────────
  /// Streak-freeze gradient end (deep blue).
  static const Color blue = Color(0xFF0288D1);

  /// Streak-freeze gradient start (sky).
  static const Color blueLight = Color(0xFF29B6F6);

  // ─── Amber — Highlight / Bookmark ───────────────────────────────
  /// Bookmark indicator / "Saved" tab tint.
  static const Color amber = Color(0xFFFFCA28);

  /// Deeper amber for legends.
  static const Color amberWarm = Color(0xFFFF8F00);

  // ─── Red — Negative delta / Errors ──────────────────────────────
  /// Used as `secondary` in dark theme and the "harder than expected" legend.
  static const Color red = Color(0xFFFF2626);

  /// Softer red for the worst-mood face.
  static const Color redSoft = Color(0xFFEF5350);

  // ─── Cyan — Light-mode secondary ────────────────────────────────
  /// Light-mode `secondary` accent.
  static const Color cyan = Color(0xFF00B8D4);

  // ─── Special backdrops (mode-independent) ───────────────────────
  /// Pure base used by level-up / badge-unlock / streak fullscreens before
  /// the tint lerp is applied.
  static const Color rootBg = Color(0xFF121212);

  /// First-phase backdrop on the streak celebration screen.
  static const Color streakPhase1Bg = Color(0xFF1A1A00);

  /// Light-mode scaffold background defined in [AppTheme.light].
  static const Color lightScaffold = Color(0xFFFBF9F8);

  // ─── Gradients ──────────────────────────────────────────────────
  /// Orange → Pink. Used by the logbook-detail Insight card and the
  /// reflection celebration halo.
  static const List<Color> insightGradient = <Color>[orange, pink];

  /// Vibrant orange → deep orange. Used by the activity calendar's
  /// "completed week" bars.
  static const List<Color> auraWeekGradient = <Color>[orangeHi, orangeLo];

  /// Sky blue → deep blue. Used by streak-freeze bars.
  static const List<Color> streakFreezeGradient = <Color>[blueLight, blue];

  /// Pink confetti palette (reflection halo + level-up celebration).
  static const List<Color> confettiPalette = <Color>[
    pink,
    pinkBright,
    pinkSoft,
    orange,
  ];
}

/// Layered grey ramp that flips between light and dark mode.
///
/// Tier semantics (light → dark gets darker as the tier number rises):
/// - **bg0** — outer scaffold edges (just outside the primary card)
/// - **bg1** — primary surface (cards, sheets, modals)
/// - **bg2** — secondary surface (chip background, inset blocks, group cards)
/// - **bg3** — nested surface / faint border
/// - **bg4** — emphasized border / divider
/// - **bg5** — strong outline (rare; toggle tracks, dashed-line strokes)
///
/// [muted] is the body-of-text grey for de-emphasized labels.
///
/// Resolve once per `build` via `final s = SyntraSurface.of(context);` then
/// reference `s.bg1`, `s.bg4`, etc.
class SyntraSurface {
  /// Outer scaffold edge (just past the primary card).
  final Color bg0;

  /// Primary surface (cards, sheets, modals).
  final Color bg1;

  /// Secondary surface (chip bg, inset block, group card).
  final Color bg2;

  /// Nested surface / faint divider.
  final Color bg3;

  /// Emphasized border / focus stroke.
  final Color bg4;

  /// Strong outline (rare; toggle tracks, dashed lines).
  final Color bg5;

  /// Primary muted text colour for de-emphasized labels.
  /// Dark: high-contrast grey. Light: medium grey.
  final Color muted;

  /// Dimmer secondary text — captions, deeply faded labels.
  final Color mutedSubtle;

  /// Light-mode warm beige used by chip alts and the switch track.
  /// In dark mode this collapses to [bg2] so the field is mode-safe.
  final Color warmTint;

  const SyntraSurface._({
    required this.bg0,
    required this.bg1,
    required this.bg2,
    required this.bg3,
    required this.bg4,
    required this.bg5,
    required this.muted,
    required this.mutedSubtle,
    required this.warmTint,
  });

  static const SyntraSurface dark = SyntraSurface._(
    bg0: Color(0xFF0A0A0A),
    bg1: Color(0xFF0D0D0D),
    bg2: Color(0xFF161616),
    bg3: Color(0xFF1F1F1F),
    bg4: Color(0xFF2A2A2A),
    bg5: Color(0xFF3A3A3A),
    muted: Color(0xFFBFBFBF),
    mutedSubtle: Color(0xFF7A7A7A),
    warmTint: Color(0xFF161616),
  );

  static const SyntraSurface light = SyntraSurface._(
    bg0: Color(0xFFFAFAFA),
    bg1: Color(0xFFFFFFFF),
    bg2: Color(0xFFF5F2F0),
    bg3: Color(0xFFE5E5E5),
    bg4: Color(0xFFD4D4D4),
    bg5: Color(0xFFB0B0B0),
    muted: Color(0xFF5C5C5C),
    mutedSubtle: Color(0xFF5C5C5C),
    warmTint: Color(0xFFEFEAE7),
  );

  static SyntraSurface of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}
