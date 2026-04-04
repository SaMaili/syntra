class Challenge {
  final String id;
  final String title;
  final String description;
  /// Suggested phrases the user can say. Shown in the hint dialog.
  final List<String> hints;
  final int level; // 1–N explicit difficulty level from the catalog
  final int xp;
  final int time; // seconds
  final String type; // 'solo' | 'group' | 'both'
  final bool flirt;
  final double frequency; // 0.0–1.0
  final String environment; // 'street' | 'public_transport' | 'home' | 'work' | 'all'

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    this.hints = const [],
    this.level = 1,
    required this.xp,
    this.type = 'both',
    this.flirt = false,
    this.frequency = 1.0,
    this.environment = 'all',
    this.time = 60,
  });
}
