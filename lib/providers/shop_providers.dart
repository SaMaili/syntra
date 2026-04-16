import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/logbook_repository.dart';
import '../data/settings_repository.dart';
import '../logic/weekly_streak_logic.dart';
import '../providers/statistics_providers.dart';

const int kStreakFreezePrice = 500;
const int kMaxStreakFreezes = 2;

// ─── Spent Aura ───────────────────────────────────────────────────────────────

final spentAuraProvider =
    StateNotifierProvider<_SpentAuraNotifier, int>((_) => _SpentAuraNotifier());

class _SpentAuraNotifier extends StateNotifier<int> {
  _SpentAuraNotifier() : super(0) {
    SettingsRepository.instance.loadSpentAura().then((v) => state = v);
  }

  Future<void> spend(int amount) async {
    final next = state + amount;
    await SettingsRepository.instance.saveSpentAura(next);
    state = next;
  }
}

// ─── Streak Freezes inventory ─────────────────────────────────────────────────

final streakFreezesProvider =
    StateNotifierProvider<_StreakFreezesNotifier, int>(
        (_) => _StreakFreezesNotifier());

class _StreakFreezesNotifier extends StateNotifier<int> {
  _StreakFreezesNotifier() : super(0) {
    SettingsRepository.instance.loadStreakFreezes().then((v) => state = v);
  }

  Future<void> add() async {
    final next = (state + 1).clamp(0, kMaxStreakFreezes);
    await SettingsRepository.instance.saveStreakFreezes(next);
    state = next;
  }

  Future<void> use() async {
    if (state <= 0) return;
    final next = state - 1;
    await SettingsRepository.instance.saveStreakFreezes(next);
    state = next;
  }
}

// ─── Available Aura (totalXp − spent) ────────────────────────────────────────

/// The Aura the user can still spend. Derived from total earned minus shop
/// purchases. Returns null while the overview stats are still loading.
final availableAuraProvider = Provider<int?>((ref) {
  final statsAsync = ref.watch(overviewStatsProvider);
  final spentAura = ref.watch(spentAuraProvider);
  return statsAsync.whenOrNull(data: (s) => (s['totalXp'] ?? 0) - spentAura);
});

// ─── Auto-apply streak freezes ────────────────────────────────────────────────

/// Call this after every successful challenge completion.
///
/// Reads the current XP-by-week map, checks for consecutive missed past weeks
/// adjacent to the active streak, and automatically consumes available freeze
/// charges to protect them — identical to Duolingo's streak-freeze mechanic.
/// Updates both [streakFreezesProvider] and the persisted frozen-weeks list so
/// that [overviewStats] immediately reflects the corrected streak.
Future<void> applyStreakFreezesIfNeeded(WidgetRef ref) async {
  final freezeCount = await SettingsRepository.instance.loadStreakFreezes();
  if (freezeCount == 0) return;

  final frozenWeeks = await SettingsRepository.instance.loadFrozenWeeks();
  final xpByWeek =
      await LogbookRepository.instance.weeklyXpByWeek(weeks: 52);

  final result = WeeklyStreakLogic.countStreakAutoFreeze(
    xpByWeek,
    DateTime.now(),
    alreadyFrozenWeeks: frozenWeeks,
    availableFreezes: freezeCount,
  );

  if (result.newlyFrozenWeeks.isEmpty) return;

  final usedCount = result.newlyFrozenWeeks.length;
  final newFreezeCount =
      (freezeCount - usedCount).clamp(0, kMaxStreakFreezes);
  final newFrozenWeeks = {...frozenWeeks, ...result.newlyFrozenWeeks};

  await SettingsRepository.instance.saveStreakFreezes(newFreezeCount);
  await SettingsRepository.instance.saveFrozenWeeks(newFrozenWeeks);

  // Sync the in-memory Riverpod state so the UI updates immediately.
  ref.read(streakFreezesProvider.notifier).state = newFreezeCount;
}
