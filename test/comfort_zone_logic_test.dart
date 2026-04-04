import 'package:flutter_test/flutter_test.dart';
import 'package:syntra/challenge.dart';
import 'package:syntra/logic/comfort_zone_logic.dart';

Challenge _c(String id, int xp, {int level = 1, String type = 'solo', bool flirt = false}) =>
    Challenge(id: id, title: 'T', description: 'D', xp: xp, level: level, type: type, flirt: flirt);

void main() {
  group('ComfortZoneLogic.assignLevel', () {
    test('returns the challenge level field directly', () {
      final c = _c('a', 100, level: 3);
      expect(ComfortZoneLogic.assignLevel(c), 3);
    });

    test('defaults to level 1 when not specified', () {
      final c = _c('b', 50);
      expect(ComfortZoneLogic.assignLevel(c), 1);
    });
  });

  group('ComfortZoneLogic.filterByCzl', () {
    late List<Challenge> catalog;

    setUp(() {
      catalog = [
        _c('1', 10, level: 1),
        _c('2', 20, level: 1),
        _c('3', 30, level: 2),
        _c('4', 40, level: 3),
        _c('5', 50, level: 4),
        _c('6', 60, level: 5),
      ];
    });

    test('level 1 returns only level-1 challenges', () {
      final result = ComfortZoneLogic.filterByCzl(catalog, 1);
      expect(result.length, 2);
      expect(result.every((c) => c.level <= 1), isTrue);
    });

    test('level 3 returns challenges of levels 1–3', () {
      final result = ComfortZoneLogic.filterByCzl(catalog, 3);
      expect(result.length, 4);
    });

    test('level 5 returns all challenges', () {
      final result = ComfortZoneLogic.filterByCzl(catalog, 5);
      expect(result.length, catalog.length);
    });

    test('level higher than max still returns all', () {
      final result = ComfortZoneLogic.filterByCzl(catalog, 99);
      expect(result.length, catalog.length);
    });
  });

  group('ComfortZoneLogic constants', () {
    test('levelNames index 0 is empty sentinel', () {
      expect(ComfortZoneLogic.levelNames[0], '');
    });

    test('levelNames has an entry for every level up to maxLevel', () {
      expect(ComfortZoneLogic.levelNames.length, ComfortZoneLogic.maxLevel + 1);
    });

    test('completionsToUnlock is positive', () {
      expect(ComfortZoneLogic.completionsToUnlock, greaterThan(0));
    });

    test('maxLevel is 5', () {
      expect(ComfortZoneLogic.maxLevel, 5);
    });
  });
}
