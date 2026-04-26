import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../challenge.dart';
import '../data/challenge_repository.dart';
import '../logic/comfort_zone_logic.dart';
import 'settings_providers.dart';
import 'shared_preferences_provider.dart';
import 'statistics_providers.dart';

// ─── Catalog ──────────────────────────────────────────────────────────────────

/// Loads the full challenge catalog for the currently selected language.
/// Rebuilds automatically when [activeLocaleProvider] changes.
final challengeCatalogProvider =
    FutureProvider<List<Challenge>>((ref) async {
  final lang = ref.watch(activeLocaleProvider);
  return ChallengeRepository.instance.loadChallenges(lang);
});

/// Catalog filtered only by the user's Comfort Zone Level (CZL).
final czlFilteredChallengesProvider =
    Provider<AsyncValue<List<Challenge>>>((ref) {
  final catalogAsync = ref.watch(challengeCatalogProvider);
  final czl = ref.watch(comfortZoneLevelProvider);

  return catalogAsync.whenData((catalog) {
    return ComfortZoneLogic.filterByCzl(catalog, czl);
  });
});

// ─── Filters ──────────────────────────────────────────────────────────────────

/// Indexes must stay stable for SharedPreferences compatibility.
enum ChallengeTypeFilter { solo, group, all, coop, dare }

enum FlirtFilter { all, showOnly, exclude }

enum EnvironmentFilter { all, street, transit, cafe, event }

enum CompletionFilter { all, done, notDone }

enum AuraSortOrder { none, asc, desc }

enum CompletionSortOrder { none, newestFirst, oldestFirst }

/// Persisted filter state for the challenges screen.
final challengeFiltersProvider =
    StateNotifierProvider<ChallengeFiltersNotifier, ChallengeFilters>(
  (ref) => ChallengeFiltersNotifier(ref.watch(sharedPreferencesProvider)),
);

class ChallengeFilters {
  final ChallengeTypeFilter typeFilter;
  final FlirtFilter flirtFilter;
  final EnvironmentFilter environmentFilter;
  final bool showOnlyNotDone;
  final CompletionFilter completionFilter;
  final AuraSortOrder auraSortOrder;
  final CompletionSortOrder completionSortOrder;
  /// Empty set means "all levels".
  final Set<int> levelFilter;

  const ChallengeFilters({
    this.typeFilter = ChallengeTypeFilter.solo,
    this.flirtFilter = FlirtFilter.all,
    this.environmentFilter = EnvironmentFilter.all,
    this.showOnlyNotDone = false,
    this.completionFilter = CompletionFilter.all,
    this.auraSortOrder = AuraSortOrder.none,
    this.completionSortOrder = CompletionSortOrder.none,
    this.levelFilter = const {},
  });

  ChallengeFilters copyWith({
    ChallengeTypeFilter? typeFilter,
    FlirtFilter? flirtFilter,
    EnvironmentFilter? environmentFilter,
    bool? showOnlyNotDone,
    CompletionFilter? completionFilter,
    AuraSortOrder? auraSortOrder,
    CompletionSortOrder? completionSortOrder,
    Set<int>? levelFilter,
  }) =>
      ChallengeFilters(
        typeFilter: typeFilter ?? this.typeFilter,
        flirtFilter: flirtFilter ?? this.flirtFilter,
        environmentFilter: environmentFilter ?? this.environmentFilter,
        showOnlyNotDone: showOnlyNotDone ?? this.showOnlyNotDone,
        completionFilter: completionFilter ?? this.completionFilter,
        auraSortOrder: auraSortOrder ?? this.auraSortOrder,
        completionSortOrder: completionSortOrder ?? this.completionSortOrder,
        levelFilter: levelFilter ?? this.levelFilter,
      );

  /// Number of non-default advanced filters active (shown as badge on tune button).
  /// Solo / Coop / All type are shown in the main bar and don't count as "advanced".
  int get activeFilterCount {
    int n = 0;
    if (typeFilter == ChallengeTypeFilter.group ||
        typeFilter == ChallengeTypeFilter.dare) { n++; }
    if (environmentFilter != EnvironmentFilter.all) n++;
    if (completionFilter != CompletionFilter.all) n++;
    if (auraSortOrder != AuraSortOrder.none) n++;
    if (completionSortOrder != CompletionSortOrder.none) n++;
    if (levelFilter.isNotEmpty) n++;
    return n;
  }
}

class ChallengeFiltersNotifier extends StateNotifier<ChallengeFilters> {
  final SharedPreferences _prefs;

  ChallengeFiltersNotifier(this._prefs) : super(const ChallengeFilters()) {
    _load();
  }

  static const _keyType = 'filter_type';
  static const _keyFlirtV2 = 'filter_flirt_v2';
  static const _keyNotDone = 'filter_not_done';
  static const _keyEnv = 'filter_env';
  static const _keyCompletion = 'filter_completion';
  static const _keyAuraSort = 'filter_aura_sort';
  static const _keyCompletionSort = 'filter_completion_sort';
  static const _keyLevelFilter = 'filter_levels';

  void _load() {
    final typeIdx = _prefs.getInt(_keyType) ?? 0;
    final flirtIdx = _prefs.getInt(_keyFlirtV2) ?? 0;
    final notDone = _prefs.getBool(_keyNotDone) ?? false;
    final envIdx = _prefs.getInt(_keyEnv) ?? 0;
    final completionIdx = _prefs.getInt(_keyCompletion) ??
        (notDone ? CompletionFilter.notDone.index : 0);
    final auraSortIdx = _prefs.getInt(_keyAuraSort) ?? 0;
    final completionSortIdx = _prefs.getInt(_keyCompletionSort) ?? 0;
    final levelStr = _prefs.getString(_keyLevelFilter) ?? '';
    final levelFilter = levelStr.isEmpty
        ? <int>{}
        : levelStr
            .split(',')
            .map(int.tryParse)
            .whereType<int>()
            .toSet();
    state = ChallengeFilters(
      typeFilter: ChallengeTypeFilter.values[
          typeIdx.clamp(0, ChallengeTypeFilter.values.length - 1)],
      flirtFilter:
          FlirtFilter.values[flirtIdx.clamp(0, FlirtFilter.values.length - 1)],
      environmentFilter: EnvironmentFilter.values[
          envIdx.clamp(0, EnvironmentFilter.values.length - 1)],
      completionFilter: CompletionFilter.values[
          completionIdx.clamp(0, CompletionFilter.values.length - 1)],
      auraSortOrder: AuraSortOrder.values[
          auraSortIdx.clamp(0, AuraSortOrder.values.length - 1)],
      completionSortOrder: CompletionSortOrder.values[
          completionSortIdx.clamp(0, CompletionSortOrder.values.length - 1)],
      levelFilter: levelFilter,
    );
  }

  Future<void> setTypeFilter(ChallengeTypeFilter filter) async {
    state = state.copyWith(typeFilter: filter);
    await _prefs.setInt(_keyType, filter.index);
  }

  Future<void> setFlirtFilter(FlirtFilter filter) async {
    state = state.copyWith(flirtFilter: filter);
    await _prefs.setInt(_keyFlirtV2, filter.index);
  }

  Future<void> setEnvironmentFilter(EnvironmentFilter filter) async {
    state = state.copyWith(environmentFilter: filter);
    await _prefs.setInt(_keyEnv, filter.index);
  }

  Future<void> setShowOnlyNotDone(bool value) async {
    state = state.copyWith(showOnlyNotDone: value);
    await _prefs.setBool(_keyNotDone, value);
  }

  Future<void> setCompletionFilter(CompletionFilter filter) async {
    state = state.copyWith(completionFilter: filter);
    await _prefs.setInt(_keyCompletion, filter.index);
  }

  Future<void> setAuraSortOrder(AuraSortOrder order) async {
    state = state.copyWith(auraSortOrder: order);
    await _prefs.setInt(_keyAuraSort, order.index);
  }

  Future<void> setCompletionSortOrder(CompletionSortOrder order) async {
    state = state.copyWith(completionSortOrder: order);
    await _prefs.setInt(_keyCompletionSort, order.index);
  }

  Future<void> toggleLevelFilter(int level) async {
    final current = Set<int>.from(state.levelFilter);
    if (current.contains(level)) {
      current.remove(level);
    } else {
      current.add(level);
    }
    state = state.copyWith(levelFilter: current);
    await _prefs.setString(
        _keyLevelFilter, current.isEmpty ? '' : current.join(','));
  }

  Future<void> resetAdvancedFilters() async {
    state = state.copyWith(
      flirtFilter: FlirtFilter.all,
      environmentFilter: EnvironmentFilter.all,
      showOnlyNotDone: false,
      completionFilter: CompletionFilter.all,
      auraSortOrder: AuraSortOrder.none,
      completionSortOrder: CompletionSortOrder.none,
      levelFilter: {},
    );
    await _prefs.setInt(_keyFlirtV2, 0);
    await _prefs.setInt(_keyEnv, 0);
    await _prefs.setBool(_keyNotDone, false);
    await _prefs.setInt(_keyCompletion, 0);
    await _prefs.setInt(_keyAuraSort, 0);
    await _prefs.setInt(_keyCompletionSort, 0);
    await _prefs.setString(_keyLevelFilter, '');
  }
}

// ─── Displayed list (filtered + sorted, ready to render) ─────────────────────

/// Applies completion filter and sort on top of [filteredChallengesProvider].
/// Cached by Riverpod — only recomputes when inputs actually change.
final displayedChallengesProvider = Provider<AsyncValue<List<Challenge>>>((ref) {
  final baseAsync = ref.watch(filteredChallengesProvider);
  final filters = ref.watch(challengeFiltersProvider);
  final completedIds = ref.watch(completedChallengeIdsProvider).valueOrNull ?? {};
  final completionDates = ref.watch(latestCompletionDatesProvider).valueOrNull ?? {};

  return baseAsync.whenData((list) {
    var result = List<Challenge>.from(list);

    switch (filters.completionFilter) {
      case CompletionFilter.notDone:
        result = result.where((c) => !completedIds.contains(c.id)).toList();
      case CompletionFilter.done:
        result = result.where((c) => completedIds.contains(c.id)).toList();
      case CompletionFilter.all:
        break;
    }

    if (filters.completionSortOrder != CompletionSortOrder.none) {
      result.sort((a, b) {
        final da = completionDates[a.id];
        final db = completionDates[b.id];
        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;
        return filters.completionSortOrder == CompletionSortOrder.newestFirst
            ? db.compareTo(da)
            : da.compareTo(db);
      });
    } else if (filters.auraSortOrder != AuraSortOrder.none) {
      result.sort((a, b) => filters.auraSortOrder == AuraSortOrder.asc
          ? a.aura.compareTo(b.aura)
          : b.aura.compareTo(a.aura));
    }

    return result;
  });
});

// ─── Filtered list ────────────────────────────────────────────────────────────

/// Applies type, flirt, and environment filters.
/// Note: [showOnlyNotDone] is applied inside the widget since it needs the
/// completed-IDs set from the logbook.
final filteredChallengesProvider =
    Provider<AsyncValue<List<Challenge>>>((ref) {
  final czlFilteredAsync = ref.watch(czlFilteredChallengesProvider);
  final filters = ref.watch(challengeFiltersProvider);

  return czlFilteredAsync.whenData((list) {
    var filtered = List<Challenge>.from(list);

    // Type filter
    switch (filters.typeFilter) {
      case ChallengeTypeFilter.solo:
        filtered = filtered.where((c) => c.type == ChallengeType.solo).toList();
      case ChallengeTypeFilter.group:
        filtered = filtered.where((c) => c.type == ChallengeType.group).toList();
      case ChallengeTypeFilter.coop:
        filtered = filtered.where((c) => c.type == ChallengeType.coop).toList();
      case ChallengeTypeFilter.dare:
        filtered = filtered.where((c) => c.type == ChallengeType.dare).toList();
      case ChallengeTypeFilter.all:
        break;
    }

    // Flirt filter
    switch (filters.flirtFilter) {
      case FlirtFilter.showOnly:
        filtered = filtered.where((c) => c.flirt).toList();
      case FlirtFilter.exclude:
        filtered = filtered.where((c) => !c.flirt).toList();
      case FlirtFilter.all:
        break;
    }

    // Environment filter — challenges tagged 'all' always pass through
    if (filters.environmentFilter != EnvironmentFilter.all) {
      final envKey = filters.environmentFilter.name;
      filtered = filtered
          .where((c) => c.environment == 'all' || c.environment == envKey)
          .toList();
    }

    // Level filter — empty set means show all
    if (filters.levelFilter.isNotEmpty) {
      filtered = filtered.where((c) => filters.levelFilter.contains(c.level)).toList();
    }

    return filtered;
  });
});
