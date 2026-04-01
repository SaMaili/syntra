import 'package:flutter_test/flutter_test.dart';
import 'package:syntra/challenge.dart';
import 'package:syntra/logic/comfort_zone_logic.dart';

Challenge _c(String id, int xp, {String type = 'solo', bool flirt = false}) =>
    Challenge(id: id, title: 'T', description: 'D', xp: xp, type: type, flirt: flirt);

void main() {
  group('ComfortZoneLogic.assignLevel', () {
    test('assigns level 1 to lowest-XP challenges', () {
      final catalog = List.generate(10, (i) => _c('$i', (i + 1) * 10));
      // XP 10 is at index 0 → 0% → level 1
      expect(ComfortZoneLogic.assignLevel(catalog[0], catalog), 1);
    });

    test('assigns level 5 to highest-XP challenges', () {
      final catalog = List.generate(10, (i) => _c('$i', (i + 1) * 10));
      // XP 100 is at index 9 → 90% → level 5
      expect(ComfortZoneLogic.assignLevel(catalog[9], catalog), 5);
    });

    test('distributes evenly across 5 levels for 10 challenges', () {
      final catalog = List.generate(10, (i) => _c('$i', (i + 1) * 10));
      final levels = catalog.map((c) => ComfortZoneLogic.assignLevel(c, catalog)).toList();
      // Level 1: indices 0-1 (XP 10,20 → pct 0%, 10%)
      // Level 2: indices 2-3 (XP 30,40 → pct 20%, 30%)
      // Level 3: indices 4-5 (XP 50,60 → pct 40%, 50%)
      // Level 4: indices 6-7 (XP 70,80 → pct 60%, 70%)
      // Level 5: indices 8-9 (XP 90,100 → pct 80%, 90%)
      expect(levels[0], 1);
      expect(levels[1], 1);
      expect(levels[2], 2);
      expect(levels[3], 2);
      expect(levels[4], 3);
      expect(levels[5], 3);
      expect(levels[6], 4);
      expect(levels[7], 4);
      expect(levels[8], 5);
      expect(levels[9], 5);
    });

    test('single-item catalog returns level 1', () {
      final catalog = [_c('a', 50)];
      expect(ComfortZoneLogic.assignLevel(catalog[0], catalog), 1);
    });

    test('empty catalog returns 1', () {
      expect(ComfortZoneLogic.assignLevel(_c('x', 50), []), 1);
    });
  });

  group('ComfortZoneLogic.filterByCzl', () {
    late List<Challenge> catalog;

    setUp(() {
      // 10 challenges, evenly distributed across 5 levels
      catalog = List.generate(10, (i) => _c('$i', (i + 1) * 10));
    });

    test('level 1 returns only level-1 challenges', () {
      final result = ComfortZoneLogic.filterByCzl(catalog, 1);
      expect(result.length, 2);
      expect(result.every((c) => ComfortZoneLogic.assignLevel(c, catalog) <= 1), isTrue);
    });

    test('level 3 returns challenges of levels 1-3', () {
      final result = ComfortZoneLogic.filterByCzl(catalog, 3);
      expect(result.length, 6);
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
    test('level names has correct count', () {
      // Index 0 unused; indices 1-5 are the levels
      expect(ComfortZoneLogic.levelNames.length, 6);
    });

    test('completionsToUnlock is positive', () {
      expect(ComfortZoneLogic.completionsToUnlock, greaterThan(0));
    });

    test('maxLevel is 5', () {
      expect(ComfortZoneLogic.maxLevel, 5);
    });
  });
}
