import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../challenge.dart';
import '../data/challenge_repository.dart';
import '../logic/comfort_zone_logic.dart';
import 'settings_providers.dart';
import 'shared_preferences_provider.dart';

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

enum ChallengeTypeFilter { solo, group, both }

enum FlirtFilter { all, showOnly, exclude }

enum SortMode { frequency, difficulty }

/// Persisted filter state for the challenges screen.
final challengeFiltersProvider =
    StateNotifierProvider<ChallengeFiltersNotifier, ChallengeFilters>(
  (ref) => ChallengeFiltersNotifier(ref.watch(sharedPreferencesProvider)),
);

class ChallengeFilters {
  final ChallengeTypeFilter typeFilter;
  final FlirtFilter flirtFilter;
  final bool showOnlyNotDone;
  final SortMode sortBy;

  const ChallengeFilters({
    this.typeFilter = ChallengeTypeFilter.solo,
    this.flirtFilter = FlirtFilter.all,
    this.showOnlyNotDone = false,
    this.sortBy = SortMode.frequency,
  });

  ChallengeFilters copyWith({
    ChallengeTypeFilter? typeFilter,
    FlirtFilter? flirtFilter,
    bool? showOnlyNotDone,
    SortMode? sortBy,
  }) =>
      ChallengeFilters(
        typeFilter: typeFilter ?? this.typeFilter,
        flirtFilter: flirtFilter ?? this.flirtFilter,
        showOnlyNotDone: showOnlyNotDone ?? this.showOnlyNotDone,
        sortBy: sortBy ?? this.sortBy,
      );

  /// Number of non-default advanced filters active (shown as badge).
  int get activeFilterCount {
    int n = 0;
    if (flirtFilter != FlirtFilter.all) n++;
    if (showOnlyNotDone) n++;
    if (sortBy != SortMode.frequency) n++;
    return n;
  }
}

class ChallengeFiltersNotifier extends StateNotifier<ChallengeFilters> {
  final SharedPreferences _prefs;

  ChallengeFiltersNotifier(this._prefs) : super(const ChallengeFilters()) {
    _load();
  }

  static const _keyType = 'filter_type';
  static const _keyFlirtV2 = 'filter_flirt_v2'; // v2 to avoid old bool key conflict
  static const _keyNotDone = 'filter_not_done';
  static const _keySortBy = 'filter_sort_by';

  Future<void> _load() async {
    final typeIdx = _prefs.getInt(_keyType) ?? 0;
    final flirtIdx = _prefs.getInt(_keyFlirtV2) ?? 0;
    final notDone = _prefs.getBool(_keyNotDone) ?? false;
    final sortIdx = _prefs.getInt(_keySortBy) ?? 0;
    state = ChallengeFilters(
      typeFilter: ChallengeTypeFilter.values[typeIdx.clamp(0, 2)],
      flirtFilter:
          FlirtFilter.values[flirtIdx.clamp(0, FlirtFilter.values.length - 1)],
      showOnlyNotDone: notDone,
      sortBy: SortMode.values[sortIdx.clamp(0, SortMode.values.length - 1)],
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

  Future<void> setShowOnlyNotDone(bool value) async {
    state = state.copyWith(showOnlyNotDone: value);
    await _prefs.setBool(_keyNotDone, value);
  }

  Future<void> setSortBy(SortMode mode) async {
    state = state.copyWith(sortBy: mode);
    await _prefs.setInt(_keySortBy, mode.index);
  }

  Future<void> resetAdvancedFilters() async {
    state = state.copyWith(
      flirtFilter: FlirtFilter.all,
      showOnlyNotDone: false,
      sortBy: SortMode.frequency,
    );
    await _prefs.setInt(_keyFlirtV2, 0);
    await _prefs.setBool(_keyNotDone, false);
    await _prefs.setInt(_keySortBy, 0);
  }
}

// ─── Filtered list (used by external consumers) ───────────────────────────────

/// Applies all current filters. Note: [showOnlyNotDone] is applied inside
/// the widget since it needs the completed-IDs set from the logbook.
final filteredChallengesProvider =
    Provider<AsyncValue<List<Challenge>>>((ref) {
  final czlFilteredAsync = ref.watch(czlFilteredChallengesProvider);
  final filters = ref.watch(challengeFiltersProvider);

  return czlFilteredAsync.whenData((list) {
    var filtered = List<Challenge>.from(list);

    switch (filters.typeFilter) {
      case ChallengeTypeFilter.solo:
        filtered = filtered.where((c) => c.type != 'group').toList();
      case ChallengeTypeFilter.group:
        filtered = filtered.where((c) => c.type == 'group').toList();
      case ChallengeTypeFilter.both:
        break;
    }

    switch (filters.flirtFilter) {
      case FlirtFilter.showOnly:
        filtered = filtered.where((c) => c.flirt).toList();
      case FlirtFilter.exclude:
        filtered = filtered.where((c) => !c.flirt).toList();
      case FlirtFilter.all:
        break;
    }

    switch (filters.sortBy) {
      case SortMode.frequency:
        filtered.sort((a, b) => b.frequency.compareTo(a.frequency));
      case SortMode.difficulty:
        filtered.sort((a, b) => a.xp.compareTo(b.xp));
    }

    return filtered;
  });
});
