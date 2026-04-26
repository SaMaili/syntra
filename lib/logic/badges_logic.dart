import 'package:flutter/material.dart';

import 'comfort_zone_logic.dart';

/// A single achievement badge definition.
class AppBadge {
  final String id;

  /// Icon shown in the badge tile.
  final IconData icon;

  /// Accent color used for the badge background.
  final Color color;

  /// Returns true when the badge has been earned given the current stats.
  final bool Function(Map<String, int> stats, int bestStreak) _condition;

  const AppBadge({
    required this.id,
    required this.icon,
    required this.color,
    required bool Function(Map<String, int> stats, int bestStreak) condition,
  }) : _condition = condition;

  bool isEarned(Map<String, int> stats, int bestStreak) =>
      _condition(stats, bestStreak);
}

/// Defines all badges and evaluates which ones the user has earned.
class BadgesLogic {
  BadgesLogic._();

  static List<AppBadge> get all => [
    AppBadge(
      id: 'first_step',
      icon: Icons.rocket_launch_rounded,
      color: Color(0xFF43A047),
      condition: _firstStep,
    ),
    AppBadge(
      id: 'ten_challenges',
      icon: Icons.directions_run_rounded,
      color: Color(0xFF1E88E5),
      condition: _tenChallenges,
    ),
    AppBadge(
      id: 'fifty_challenges',
      icon: Icons.emoji_events_rounded,
      color: Color(0xFFFF8F00),
      condition: _fiftyChallenges,
    ),
    AppBadge(
      id: 'three_week_streak',
      icon: Icons.local_fire_department_rounded,
      color: Color(0xFFE65100),
      condition: _threeWeekStreak,
    ),
    AppBadge(
      id: 'seven_week_streak',
      icon: Icons.whatshot_rounded,
      color: Color(0xFFC62828),
      condition: _sevenWeekStreak,
    ),
    AppBadge(
      id: 'century_aura',
      icon: Icons.bolt_rounded,
      color: Color(0xFF5E35B1),
      condition: _centuryXp,
    ),
    AppBadge(
      id: 'five_hundred_aura',
      icon: Icons.military_tech_rounded,
      color: Color(0xFFAD1457),
      condition: _fiveHundredXp,
    ),
    AppBadge(
      id: 'brave_minutes',
      icon: Icons.timer_rounded,
      color: Color(0xFF00838F),
      condition: _braveMinutes,
    ),
    // One badge per comfort-zone level reached (levels 2–10).
    for (int lvl = 2; lvl <= ComfortZoneLogic.maxLevel; lvl++)
      AppBadge(
        id: 'level_$lvl',
        icon: ComfortZoneLogic.levelIcons[lvl],
        color: ComfortZoneLogic.levelGradientColors[lvl].$1,
        condition: (stats, _) => (stats['czlLevel'] ?? 1) >= lvl,
      ),
  ];

  /// Returns the subset of badges the user has earned.
  static Set<String> computeEarned(
      Map<String, int> stats, int bestStreak) {
    return {
      for (final b in all)
        if (b.isEarned(stats, bestStreak)) b.id,
    };
  }

  // ─── Conditions ──────────────────────────────────────────────────────────────

  static bool _firstStep(Map<String, int> s, int _) =>
      (s['completedAllTime'] ?? 0) >= 1;

  static bool _tenChallenges(Map<String, int> s, int _) =>
      (s['completedAllTime'] ?? 0) >= 10;

  static bool _fiftyChallenges(Map<String, int> s, int _) =>
      (s['completedAllTime'] ?? 0) >= 50;

  static bool _threeWeekStreak(Map<String, int> s, int best) =>
      best >= 3;

  static bool _sevenWeekStreak(Map<String, int> s, int best) =>
      best >= 7;

  static bool _centuryXp(Map<String, int> s, int _) =>
      (s['totalAura'] ?? 0) >= 100;

  static bool _fiveHundredXp(Map<String, int> s, int _) =>
      (s['totalAura'] ?? 0) >= 500;

  static bool _braveMinutes(Map<String, int> s, int _) =>
      (s['minutesBrave'] ?? 0) >= 60;
}
