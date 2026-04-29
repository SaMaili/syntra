import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_providers.dart';
import 'statistics_providers.dart';

/// Ordered list of unlocked badge IDs (oldest first, most recent last).
/// Refreshes whenever statistics refresh, so newly celebrated badges show
/// up immediately on the badge list.
final unlockedBadgesOrderProvider = FutureProvider<List<String>>((ref) async {
  ref.watch(statisticsRefreshProvider);
  final repo = ref.watch(settingsRepositoryProvider);
  return repo.loadUnlockedBadgesOrder();
});
