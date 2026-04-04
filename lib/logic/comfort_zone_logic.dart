import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../challenge.dart';

/// Ten-level comfort zone progression system.
///
/// Levels progress from micro-interactions (1) to elite social mastery (10).
/// Each level unlocks after [completionsToUnlock] successful completions
/// at the current level. Levels are stored as integers 1–[maxLevel].
///
/// Challenge difficulty levels are assigned explicitly in the catalog JSON
/// (the `level` field), not computed at runtime.
class ComfortZoneLogic {
  static const completionsToUnlock = 3;
  static const maxLevel = 10;

  static const levelNames = [
    '',                       // index 0 unused
    'Warming Up',             // 1
    'Breaking the Ice',       // 2
    'Holding the Floor',      // 3
    'Taking Risks',           // 4
    'The Bold Zone',          // 5
    'Stepping Up',            // 6
    'Owning the Room',        // 7
    'Social Athlete',         // 8
    'Fearless',               // 9
    'Untouchable',            // 10
  ];

  static const levelDescriptions = [
    '',
    'Micro-interactions — low stakes, high growth',      // 1
    'Brief exchanges with real humans',                  // 2
    'Sustained conversations and presence',              // 3
    'Vulnerability, compliments, assertiveness',         // 4
    'High-stakes social challenges',                     // 5
    'Leading interactions with confidence',              // 6
    'Commanding attention in any setting',               // 7
    'Pushing social limits with ease',                   // 8
    'Embracing full exposure without hesitation',        // 9
    'Elite social mastery — nothing holds you back',     // 10
  ];

  static const levelIcons = <IconData>[
    Icons.spa_rounded,          // 0 unused
    Icons.spa_rounded,          // 1 Warming Up
    Icons.ac_unit_rounded,      // 2 Breaking the Ice
    Icons.mic_rounded,          // 3 Holding the Floor
    Icons.flash_on_rounded,     // 4 Taking Risks
    Icons.star_rounded,         // 5 The Bold Zone
  ];

  /// Two-stop gradient per level (begin → end).
  static const levelGradientColors = <(Color, Color)>[
    (Color(0xFF43A047), Color(0xFF66BB6A)), // 0 unused
    (Color(0xFF43A047), Color(0xFF66BB6A)), // 1 green
    (Color(0xFF0288D1), Color(0xFF29B6F6)), // 2 blue
    (Color(0xFFE65100), Color(0xFFFF7043)), // 3 orange
    (Color(0xFFC62828), Color(0xFFEF5350)), // 4 red
    (Color(0xFFFF8F00), Color(0xFFFFCA28)), // 5 gold
  ];

  /// Returns the [LinearGradient] for [level] (clamped to valid range).
  static LinearGradient levelGradient(int level) {
    final idx = level.clamp(1, maxLevel);
    final (begin, end) = levelGradientColors[idx];
    return LinearGradient(
      colors: [begin, end],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static const _keyCompletions = 'czl_completions_'; // + level number

  /// Returns how many successful completions count toward the next level unlock.
  /// Only completions of challenges *at* or *above* the current CZL count.
  Future<int> getCompletionsAtLevel(int level, SharedPreferences prefs) async =>
      prefs.getInt('$_keyCompletions$level') ?? 0;

  /// Records a successful completion and checks if the user should level up.
  /// Returns the new level if a level-up occurred, null otherwise.
  Future<int?> recordSuccessAndCheckLevelUp(
    int currentLevel,
    Challenge completed,
    List<Challenge> catalog,
    SharedPreferences prefs,
  ) async {
    if (currentLevel >= maxLevel) return null;

    // Only count challenges at the current level or above.
    if (completed.level < currentLevel) return null;

    final key = '$_keyCompletions$currentLevel';
    final newCount = (prefs.getInt(key) ?? 0) + 1;
    await prefs.setInt(key, newCount);

    if (newCount >= completionsToUnlock) {
      return currentLevel + 1;
    }
    return null;
  }

  /// Returns the difficulty level for a challenge — reads directly from the
  /// catalog JSON field. Kept as a static method for call-site compatibility.
  static int assignLevel(Challenge challenge) => challenge.level;

  /// Returns all challenges visible for the given [currentLevel].
  static List<Challenge> filterByCzl(
      List<Challenge> catalog, int currentLevel) {
    return catalog.where((c) => c.level <= currentLevel).toList();
  }
}
