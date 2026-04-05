class Challenge {
  final String id;
  final String title;
  final String description;
  /// Suggested phrases the user can say. Shown in the hint dialog.
  final List<String> hints;
  final int level; // 1–N explicit difficulty level from the catalog
  final int xp;
  final int time; // seconds
  final String type; // 'solo' | 'group' | 'coop' | 'dare'
  final bool flirt;
  final String environment; // 'all' | 'street' | 'transit' | 'cafe' | 'event'

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
