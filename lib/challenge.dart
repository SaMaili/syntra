// Challenge type string constants — match the JSON catalog values.
abstract class ChallengeType {
  static const String solo = 'solo';
  static const String group = 'group';
  static const String coop = 'coop';
  static const String dare = 'dare';
}

// Challenge environment string constants — match the JSON catalog values.
abstract class ChallengeEnvironment {
  static const String all = 'all';
  static const String street = 'street';
  static const String transit = 'transit';
  static const String cafe = 'cafe';
  static const String event = 'event';
}

class Challenge {
  final String id;
  final String title;
  final String description;
  /// Suggested phrases the user can say. Shown in the hint dialog.
  final List<String> hints;
  final int level; // 1–N explicit difficulty level from the catalog
  final int xp;
  final int time; // seconds
  final String type; // see ChallengeType
  final bool flirt;
  final String environment; // see ChallengeEnvironment

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    this.hints = const [],
    this.level = 1,
    required this.xp,
    this.type = 'solo',
    this.flirt = false,
    this.environment = 'all',
    this.time = 60,
  });
}
