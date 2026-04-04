import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../challenge.dart';

/// Five-level comfort zone progression system.
///
/// Levels progress from micro-interactions (1) to high-stakes challenges (5).
/// Each level unlocks after [completionsToUnlock] successful completions
/// at the current level. Levels are stored as integers 1–5.
class ComfortZoneLogic {
  static const completionsToUnlock = 3;
  static const maxLevel = 5;

  static const levelNames = [
    '',                    // index 0 unused
    'Warming Up',          // 1
    'Breaking the Ice',    // 2
    'Holding the Floor',   // 3
    'Taking Risks',        // 4
    'The Bold Zone',       // 5
  ];

  static const levelDescriptions = [
    '',
    'Micro-interactions — low stakes, high growth',
    'Brief exchanges with real humans',
    'Sustained conversations and presence',
    'Vulnerability, compliments, assertiveness',
    'High-stakes social challenges',
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
  Future<int> getCompletionsAtLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_keyCompletions$level') ?? 0;
  }

  /// Records a successful completion and checks if the user should level up.
  /// Returns the new level if a level-up occurred, null otherwise.
  Future<int?> recordSuccessAndCheckLevelUp(
      int currentLevel, Challenge completed, List<Challenge> catalog) async {
    if (currentLevel >= maxLevel) return null;

    // Only count challenges that belong to the current level or above.
    final challengeLevel = assignLevel(completed, catalog);
    if (challengeLevel < currentLevel) return null;

    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyCompletions$currentLevel';
    final newCount = (prefs.getInt(key) ?? 0) + 1;
    await prefs.setInt(key, newCount);

    if (newCount >= completionsToUnlock) {
      return currentLevel + 1;
    }
    return null;
  }

  /// Assigns a difficulty level (1–5) to a challenge based on XP percentile
  /// within the provided catalog. Computed deterministically for any catalog.
  static int assignLevel(Challenge challenge, List<Challenge> catalog) {
    if (catalog.isEmpty) return 1;
    final sorted = [...catalog]..sort((a, b) => a.xp.compareTo(b.xp));
    // Find the position of this challenge's XP in the sorted list.
    // Use the first occurrence to handle ties consistently.
    final idx = sorted.indexWhere((c) => c.xp >= challenge.xp);
    final pct = idx < 0 ? 1.0 : idx / sorted.length;
    if (pct < 0.20) return 1;
    if (pct < 0.40) return 2;
    if (pct < 0.60) return 3;
    if (pct < 0.80) return 4;
    return 5;
  }

  /// Returns all challenges visible for the given [currentLevel].
  /// Users see challenges from level 1 up to their current level.
  static List<Challenge> filterByCzl(
      List<Challenge> catalog, int currentLevel) {
    return catalog
        .where((c) => assignLevel(c, catalog) <= currentLevel)
        .toList();
  }
}
