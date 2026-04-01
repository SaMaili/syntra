import 'package:flutter_test/flutter_test.dart';
import 'package:syntra/data/logbook_repository.dart';

void main() {
  group('LogbookRepository.countStreak', () {
    final today = DateTime(2026, 3, 30);

    test('returns 0 for empty list', () {
      expect(LogbookRepository.countStreak([], today), 0);
    });

    test('returns 1 when only today has a success', () {
      final dates = [DateTime(2026, 3, 30)];
      expect(LogbookRepository.countStreak(dates, today), 1);
    });

    test('returns 3 for three consecutive days ending today', () {
      final dates = [
        DateTime(2026, 3, 30),
        DateTime(2026, 3, 29),
        DateTime(2026, 3, 28),
      ];
      expect(LogbookRepository.countStreak(dates, today), 3);
    });

    test('breaks streak on gap day', () {
      // Day 30, 29, 27 — gap on 28
      final dates = [
        DateTime(2026, 3, 30),
        DateTime(2026, 3, 29),
        DateTime(2026, 3, 27),
      ];
      expect(LogbookRepository.countStreak(dates, today), 2);
    });

    test('returns 0 when today has no success (streak broken)', () {
      // Only yesterday and the day before
      final dates = [
        DateTime(2026, 3, 29),
        DateTime(2026, 3, 28),
      ];
      expect(LogbookRepository.countStreak(dates, today), 0);
    });

    test('handles 7-day streak correctly', () {
      final dates = List.generate(
        7,
        (i) => DateTime(today.year, today.month, today.day - i),
      );
      expect(LogbookRepository.countStreak(dates, today), 7);
    });

    test('ignores dates after today', () {
      final dates = [
        DateTime(2026, 3, 31), // future
        DateTime(2026, 3, 30), // today
        DateTime(2026, 3, 29),
      ];
      // Only today and yesterday count (future is ignored by the algorithm)
      expect(LogbookRepository.countStreak(dates, today), 2);
    });

    test('handles duplicate dates gracefully', () {
      final dates = [
        DateTime(2026, 3, 30),
        DateTime(2026, 3, 30), // duplicate
        DateTime(2026, 3, 29),
      ];
      expect(LogbookRepository.countStreak(dates, today), 2);
    });

    test('handles unordered dates', () {
      final dates = [
        DateTime(2026, 3, 28),
        DateTime(2026, 3, 30),
        DateTime(2026, 3, 29),
      ];
      expect(LogbookRepository.countStreak(dates, today), 3);
    });
  });
}
