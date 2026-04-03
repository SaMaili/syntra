import 'package:shared_preferences/shared_preferences.dart';

import '../challenge.dart';

/// Five-level comfort zone progression system.
///
/// Levels progress from micro-interactions (1) to high-stakes challenges (5).
/// Each level unlocks after [completionsToUnlock] successful completions
/// at the current level. Levels are stored as integers 1–[maxLevel].
///
/// Challenge difficulty levels are assigned explicitly in the catalog JSON
/// (the `level` field), not computed at runtime.
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
  Future<int> getCompletionsAtLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_keyCompletions$level') ?? 0;
  }

  /// Records a successful completion and checks if the user should level up.
  /// Returns the new level if a level-up occurred, null otherwise.
  Future<int?> recordSuccessAndCheckLevelUp(
      int currentLevel, Challenge completed) async {
    if (currentLevel >= maxLevel) return null;

    // Only count challenges at the current level or above.
    if (completed.level < currentLevel) return null;

    final prefs = await SharedPreferences.getInstance();
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
