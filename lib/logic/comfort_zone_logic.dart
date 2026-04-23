import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../challenge.dart';

/// Ten-level comfort zone progression system.
///
/// Levels progress from micro-interactions (1) to elite social mastery (10).
/// Each level unlocks after [completionsNeeded] successful completions.
/// The threshold grows with each level so early progress feels fast and
/// later mastery requires real commitment.
/// Levels are stored as integers 1–[maxLevel].
///
/// Challenge difficulty levels are assigned explicitly in the catalog JSON
/// (the `level` field), not computed at runtime.
class ComfortZoneLogic {
  static const maxLevel = 10;

  /// Completions required to advance from [level] to [level + 1].
  /// Index matches the current level (index 0 unused).
  static const List<int> _completionsPerLevel = [
    0,   // index 0: unused
    3,   // level 1 → 2
    5,   // level 2 → 3
    8,   // level 3 → 4
    12,  // level 4 → 5
    16,  // level 5 → 6
    20,  // level 6 → 7
    25,  // level 7 → 8
    30,  // level 8 → 9
    35,  // level 9 → 10
  ];

  /// Returns the number of successful completions needed to advance from
  /// [level] to the next level. Clamped to valid range.
  static int completionsNeeded(int level) {
    final idx = level.clamp(1, _completionsPerLevel.length - 1);
    return _completionsPerLevel[idx];
  }

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
    'The discomfort is purely internal: ego, self-consciousness, the fear of being seen. No words required. Small on the outside, real on the inside.', // 1
    'One sentence, one stranger: someone who\'s already there and somewhat expects interaction (cashier, barista, receptionist). You initiate but the social script is familiar. The discomfort is in speaking first.', // 2
    'You approach someone who has no particular reason to expect you. Brief but real: 2 to 3 exchanges. You start it and hold it for at least one follow-up. The discomfort is in staying present once the opener lands.', // 3
    'You put something of yourself into the interaction: a genuine compliment, a personal opinion, a small act of assertiveness. The discomfort is in saying something that reveals what you notice or think.', // 4
    'You approach someone with no social cover: no reason, no service context. Rejection is possible and visible. A sustained interaction or a bold opener that requires real confidence to deliver.', // 5
    'More eyes, higher stakes. You approach a group or lead the interaction: asking multiple people, making a request that\'s slightly unusual. The discomfort is in being the one who started something visible.', // 6
    'You declare something about yourself or your interest in another person: directly, clearly, without softening it. Or you do something that draws the attention of multiple people at once. Vulnerable and public.', // 7
    'You do something that takes real nerve to follow through on. Physical boldness, deliberate awkwardness owned completely, or deeply personal disclosure to a stranger. A controlled, confident push into discomfort.', // 8
    'You become the spectacle. You do something that draws a sustained audience or requires speaking loudly, performing, or behaving in a way that makes strangers turn around. The whole point is the exposure: being looked at and owning every second of it.', // 9
    'For things that sit just outside what feels acceptable. Not dangerous, not harmful, not illegal — but the kind of thing that makes a bystander stop and look twice. You feel the weight of it. You go anyway.', // 10
  ];

  static const levelIcons = <IconData>[
    Icons.spa_rounded,               // 0 unused
    Icons.spa_rounded,               // 1 Warming Up
    Icons.ac_unit_rounded,           // 2 Breaking the Ice
    Icons.mic_rounded,               // 3 Holding the Floor
    Icons.flash_on_rounded,          // 4 Taking Risks
    Icons.star_rounded,              // 5 The Bold Zone
    Icons.trending_up_rounded,       // 6 Stepping Up
    Icons.emoji_events_rounded,      // 7 Owning the Room
    Icons.fitness_center_rounded,    // 8 Social Athlete
    Icons.whatshot_rounded,          // 9 Fearless
    Icons.workspace_premium_rounded, // 10 Untouchable
  ];

  /// Two-stop gradient per level (begin → end).
  static const levelGradientColors = <(Color, Color)>[
    (Color(0xFF43A047), Color(0xFF66BB6A)), // 0 unused
    (Color(0xFF43A047), Color(0xFF66BB6A)), // 1 green
    (Color(0xFF0288D1), Color(0xFF29B6F6)), // 2 blue
    (Color(0xFFE65100), Color(0xFFFF7043)), // 3 orange
    (Color(0xFFC62828), Color(0xFFEF5350)), // 4 red
    (Color(0xFFFF8F00), Color(0xFFFFCA28)), // 5 gold
    (Color(0xFF6A1B9A), Color(0xFFAB47BC)), // 6 purple
    (Color(0xFF00695C), Color(0xFF26A69A)), // 7 teal
    (Color(0xFF1565C0), Color(0xFF42A5F5)), // 8 deep blue
    (Color(0xFF880E4F), Color(0xFFEC407A)), // 9 pink
    (Color(0xFF212121), Color(0xFF757575)), // 10 obsidian
  ];

  /// Returns the [LinearGradient] for [level] (clamped to valid range).
  static LinearGradient levelGradient(int level) {
    final idx = level.clamp(1, levelGradientColors.length - 1);
    final (begin, end) = levelGradientColors[idx];
    return LinearGradient(
      colors: [begin, end],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static const _keyCompletions = 'czl_completions_'; // + level number

  /// Returns how many successful completions count toward the next level unlock.
  int getCompletionsAtLevel(int level, SharedPreferences prefs) =>
      prefs.getInt('$_keyCompletions$level') ?? 0;

  /// Resets the completion counter for [level] to zero.
  Future<void> resetCompletionsAtLevel(int level, SharedPreferences prefs) =>
      prefs.setInt('$_keyCompletions$level', 0);

  /// Records a successful completion and checks if the user should level up.
  /// Returns the new level if a level-up occurred, null otherwise.
  Future<int?> recordSuccessAndCheckLevelUp(
    int currentLevel,
    Challenge completed,
    List<Challenge> catalog,
    SharedPreferences prefs,
  ) async {
    if (currentLevel >= maxLevel) return null;
    if (completed.level != currentLevel) return null;

    final key = '$_keyCompletions$currentLevel';
    final newCount = (prefs.getInt(key) ?? 0) + 1;
    await prefs.setInt(key, newCount);

    if (newCount >= completionsNeeded(currentLevel)) {
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
