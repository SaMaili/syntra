import 'package:flutter_test/flutter_test.dart';
import 'package:syntra/logic/prediction_gap_logic.dart';

/// Helper to build a logbook entry. preAnxiety on 1-5 (5 = very nervous),
/// feeling on 0-4 (4 = very satisfied/calm).
Map<String, dynamic> _entry({int? preAnxiety, int? feeling}) => {
      'pre_anxiety': preAnxiety,
      'feeling': feeling,
    };

void main() {
  group('PredictionGapLogic.compute — minimum attempts gate', () {
    test('returns null when no entries', () {
      expect(PredictionGapLogic.compute([]), isNull);
    });

    test('returns null below minAttempts threshold', () {
      final entries = List.generate(
        PredictionGapLogic.minAttempts - 1,
        (_) => _entry(preAnxiety: 5, feeling: 4),
      );
      expect(PredictionGapLogic.compute(entries), isNull);
    });

    test('returns insight at exactly minAttempts', () {
      final entries = List.generate(
        PredictionGapLogic.minAttempts,
        (_) => _entry(preAnxiety: 5, feeling: 4),
      );
      expect(PredictionGapLogic.compute(entries), isNotNull);
    });
  });

  group('PredictionGapLogic.compute — invalid entries are filtered', () {
    test('skips entries missing pre_anxiety', () {
      final entries = [
        _entry(preAnxiety: 5, feeling: 4),
        _entry(preAnxiety: 5, feeling: 4),
        _entry(preAnxiety: 5, feeling: 4),
        _entry(preAnxiety: null, feeling: 4),
      ];
      final insight = PredictionGapLogic.compute(entries);
      expect(insight, isNotNull);
      expect(insight!.attempts, 3);
    });

    test('skips entries missing feeling', () {
      final entries = [
        _entry(preAnxiety: 5, feeling: 4),
        _entry(preAnxiety: 5, feeling: 4),
        _entry(preAnxiety: 5, feeling: 4),
        _entry(preAnxiety: 5, feeling: null),
      ];
      final insight = PredictionGapLogic.compute(entries);
      expect(insight!.attempts, 3);
    });

    test('skips entries with non-int values', () {
      final entries = [
        _entry(preAnxiety: 5, feeling: 4),
        _entry(preAnxiety: 5, feeling: 4),
        _entry(preAnxiety: 5, feeling: 4),
        {'pre_anxiety': '5', 'feeling': '4'}, // strings, not ints
      ];
      final insight = PredictionGapLogic.compute(entries);
      expect(insight!.attempts, 3);
    });
  });

  group('PredictionGapLogic.compute — gap math', () {
    // The conversion: actualAnxiety = 5 - feeling
    // gap = preAnxiety - actualAnxiety = preAnxiety - (5 - feeling)

    test('predicted very nervous (5), felt very calm (4) → gap = +4', () {
      final insight = PredictionGapLogic.compute([
        _entry(preAnxiety: 5, feeling: 4),
        _entry(preAnxiety: 5, feeling: 4),
        _entry(preAnxiety: 5, feeling: 4),
      ]);
      expect(insight!.averageGap, 4.0);
      expect(insight.calmThanPredicted, 3);
    });

    test('predicted very calm (1), felt very nervous (0) → gap = -4', () {
      final insight = PredictionGapLogic.compute([
        _entry(preAnxiety: 1, feeling: 0),
        _entry(preAnxiety: 1, feeling: 0),
        _entry(preAnxiety: 1, feeling: 0),
      ]);
      expect(insight!.averageGap, -4.0);
      expect(insight.calmThanPredicted, 0);
    });

    test('accurate prediction (preAnxiety=3, feeling=2) → gap = 0', () {
      // actualAnxiety = 5 - 2 = 3, gap = 3 - 3 = 0
      final insight = PredictionGapLogic.compute([
        _entry(preAnxiety: 3, feeling: 2),
        _entry(preAnxiety: 3, feeling: 2),
        _entry(preAnxiety: 3, feeling: 2),
      ]);
      expect(insight!.averageGap, 0.0);
    });

    test('mixed entries — averages correctly', () {
      // Entry 1: gap = 5 - (5-4) = 4
      // Entry 2: gap = 3 - (5-2) = 0
      // Entry 3: gap = 1 - (5-0) = -4
      // Avg: 0
      final insight = PredictionGapLogic.compute([
        _entry(preAnxiety: 5, feeling: 4),
        _entry(preAnxiety: 3, feeling: 2),
        _entry(preAnxiety: 1, feeling: 0),
      ]);
      expect(insight!.averageGap, 0.0);
      expect(insight.calmThanPredicted, 1);
    });

    test('clamps out-of-range pre_anxiety values', () {
      // 99 should clamp to 5; -10 should clamp to 1
      final insight = PredictionGapLogic.compute([
        _entry(preAnxiety: 99, feeling: 4), // clamped to 5, gap = +4
        _entry(preAnxiety: 99, feeling: 4),
        _entry(preAnxiety: 99, feeling: 4),
      ]);
      expect(insight!.averageGap, 4.0);
    });

    test('clamps out-of-range feeling values', () {
      // feeling 99 clamps to 4
      final insight = PredictionGapLogic.compute([
        _entry(preAnxiety: 5, feeling: 99),
        _entry(preAnxiety: 5, feeling: 99),
        _entry(preAnxiety: 5, feeling: 99),
      ]);
      expect(insight!.averageGap, 4.0);
    });
  });

  group('ChallengeGapInsight.tone categorization', () {
    test('averageGap > 1.5 → veryCalm', () {
      const insight = ChallengeGapInsight(
        attempts: 3, averageGap: 2.0, calmThanPredicted: 3);
      expect(insight.tone, PredictionGapTone.veryCalm);
    });

    test('averageGap in (0.5, 1.5] → calm', () {
      const insight = ChallengeGapInsight(
        attempts: 3, averageGap: 1.0, calmThanPredicted: 2);
      expect(insight.tone, PredictionGapTone.calm);
    });

    test('|averageGap| < 0.5 → accurate', () {
      const insight = ChallengeGapInsight(
        attempts: 3, averageGap: 0.2, calmThanPredicted: 1);
      expect(insight.tone, PredictionGapTone.accurate);

      const insight2 = ChallengeGapInsight(
        attempts: 3, averageGap: -0.4, calmThanPredicted: 1);
      expect(insight2.tone, PredictionGapTone.accurate);
    });

    test('averageGap < -1.5 → tough', () {
      const insight = ChallengeGapInsight(
        attempts: 3, averageGap: -2.0, calmThanPredicted: 0);
      expect(insight.tone, PredictionGapTone.tough);
    });

    test('averageGap in [-1.5, -0.5] → nervous', () {
      const insight = ChallengeGapInsight(
        attempts: 3, averageGap: -1.0, calmThanPredicted: 1);
      expect(insight.tone, PredictionGapTone.nervous);
    });

    test('boundary: gap = 0.5 exactly is not accurate', () {
      const insight = ChallengeGapInsight(
        attempts: 3, averageGap: 0.5, calmThanPredicted: 2);
      // 0.5.abs() < 0.5 is false, so not accurate; 0.5 > 0.5 is false either,
      // so falls through to nervous branch
      expect(insight.tone, PredictionGapTone.nervous);
    });

    test('boundary: gap = -0.5 exactly is not accurate', () {
      const insight = ChallengeGapInsight(
        attempts: 3, averageGap: -0.5, calmThanPredicted: 1);
      expect(insight.tone, PredictionGapTone.nervous);
    });
  });

  group('PredictionGapLogic.compute — calmThanPredicted counter', () {
    test('counts only strictly positive gaps', () {
      final insight = PredictionGapLogic.compute([
        _entry(preAnxiety: 5, feeling: 4), // gap = +4
        _entry(preAnxiety: 3, feeling: 2), // gap = 0 (not counted)
        _entry(preAnxiety: 1, feeling: 0), // gap = -4 (not counted)
        _entry(preAnxiety: 4, feeling: 3), // gap = +2
      ]);
      expect(insight!.calmThanPredicted, 2);
    });
  });
}
