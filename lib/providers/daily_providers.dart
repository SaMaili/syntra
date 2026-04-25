import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logic/daily_missions_logic.dart';
import 'settings_providers.dart' show activeLocaleProvider;
import 'shared_preferences_provider.dart';

final dailyMissionsProvider =
    AsyncNotifierProvider<DailyMissionsNotifier, List<DailyMission>>(
        DailyMissionsNotifier.new);

class DailyMissionsNotifier extends AsyncNotifier<List<DailyMission>> {
  @override
  Future<List<DailyMission>> build() async {
    final lang = ref.watch(activeLocaleProvider);
    final prefs = ref.read(sharedPreferencesProvider);
    return DailyMissionsLogic().getTodayMissions(lang, prefs);
  }

  Future<void> markCompleted(MissionTier tier) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await DailyMissionsLogic().markCompleted(tier, prefs);
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current
          .map((m) => m.tier == tier ? m.copyWith(completed: true) : m)
          .toList(),
    );
  }
}
