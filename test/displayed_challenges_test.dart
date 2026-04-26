import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syntra/challenge.dart';
import 'package:syntra/providers/challenge_providers.dart';
import 'package:syntra/providers/shared_preferences_provider.dart';
import 'package:syntra/providers/statistics_providers.dart';

Challenge _c(String id, {int aura = 50}) => Challenge(
      id: id,
      title: 'T',
      description: 'D',
      aura: aura,
    );

/// Creates a container where [challengeFiltersProvider] starts with [prefs] values.
Future<ProviderContainer> _container({
  required List<Challenge> catalog,
  Map<String, Object> filterPrefs = const {},
  Set<String> completedIds = const {},
  Map<String, DateTime> completionDates = const {},
}) async {
  SharedPreferences.setMockInitialValues(filterPrefs);
  final prefs = await SharedPreferences.getInstance();

  final c = ProviderContainer(overrides: [
    filteredChallengesProvider.overrideWithValue(AsyncData(catalog)),
    sharedPreferencesProvider.overrideWithValue(prefs),
    completedChallengeIdsProvider.overrideWith((_) async => completedIds),
    latestCompletionDatesProvider.overrideWith((_) async => completionDates),
  ]);
  // Pump the FutureProviders so their values are available synchronously.
  await c.read(completedChallengeIdsProvider.future);
  await c.read(latestCompletionDatesProvider.future);
  return c;
}

/// Key used by [ChallengeFiltersNotifier] for the completion filter pref.
const _kCompletionKey = 'filter_completion';
const _kAuraSortKey = 'filter_aura_sort';
const _kCompletionSortKey = 'filter_completion_sort';

void main() {
  group('displayedChallengesProvider — completion filter', () {
    final catalog = [_c('1'), _c('2'), _c('3')];

    test('CompletionFilter.all returns all challenges', () async {
      final c = await _container(catalog: catalog, completedIds: {'1'});
      addTearDown(c.dispose);
      expect(c.read(displayedChallengesProvider).valueOrNull?.length, 3);
    });

    test('CompletionFilter.notDone excludes completed ids', () async {
      final c = await _container(
        catalog: catalog,
        filterPrefs: {_kCompletionKey: CompletionFilter.notDone.index},
        completedIds: {'1', '3'},
      );
      addTearDown(c.dispose);
      final ids = c.read(displayedChallengesProvider).valueOrNull?.map((ch) => ch.id);
      expect(ids?.toList(), ['2']);
    });

    test('CompletionFilter.done returns only completed ids', () async {
      final c = await _container(
        catalog: catalog,
        filterPrefs: {_kCompletionKey: CompletionFilter.done.index},
        completedIds: {'2'},
      );
      addTearDown(c.dispose);
      final ids = c.read(displayedChallengesProvider).valueOrNull?.map((ch) => ch.id);
      expect(ids?.toList(), ['2']);
    });
  });

  group('displayedChallengesProvider — aura sort', () {
    final catalog = [_c('a', aura: 30), _c('b', aura: 10), _c('c', aura: 20)];

    test('AuraSortOrder.asc sorts ascending by Aura', () async {
      final c = await _container(
        catalog: catalog,
        filterPrefs: {_kAuraSortKey: AuraSortOrder.asc.index},
      );
      addTearDown(c.dispose);
      final ids = c.read(displayedChallengesProvider).valueOrNull?.map((ch) => ch.id);
      expect(ids?.toList(), ['b', 'c', 'a']);
    });

    test('AuraSortOrder.desc sorts descending by Aura', () async {
      final c = await _container(
        catalog: catalog,
        filterPrefs: {_kAuraSortKey: AuraSortOrder.desc.index},
      );
      addTearDown(c.dispose);
      final ids = c.read(displayedChallengesProvider).valueOrNull?.map((ch) => ch.id);
      expect(ids?.toList(), ['a', 'c', 'b']);
    });
  });

  group('displayedChallengesProvider — completion date sort', () {
    final now = DateTime(2026, 1, 10);
    final catalog = [_c('x'), _c('y'), _c('z')];
    final dates = {
      'x': now,
      'y': now.subtract(const Duration(days: 5)),
    };

    test('newestFirst puts most recently completed first', () async {
      final c = await _container(
        catalog: catalog,
        filterPrefs: {
          _kCompletionSortKey: CompletionSortOrder.newestFirst.index,
        },
        completionDates: dates,
      );
      addTearDown(c.dispose);
      final ids = c.read(displayedChallengesProvider).valueOrNull?.map((ch) => ch.id).toList();
      expect(ids?.first, 'x');
      expect(ids?.elementAt(1), 'y');
    });

    test('oldestFirst puts oldest completion first', () async {
      final c = await _container(
        catalog: catalog,
        filterPrefs: {
          _kCompletionSortKey: CompletionSortOrder.oldestFirst.index,
        },
        completionDates: dates,
      );
      addTearDown(c.dispose);
      final ids = c.read(displayedChallengesProvider).valueOrNull?.map((ch) => ch.id).toList();
      expect(ids?.first, 'y');
      expect(ids?.elementAt(1), 'x');
    });
  });
}
