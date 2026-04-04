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

    // Only count challenges that belong to the current level or above.
    final challengeLevel = assignLevel(completed, catalog);
    if (challengeLevel < currentLevel) return null;

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
