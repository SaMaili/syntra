import 'package:flutter_test/flutter_test.dart';
import 'package:syntra/routes/challenge_done_screen.dart';

void main() {
  group('socialProofCount', () {
    test('always returns a value in range 800–4499', () {
      for (final id in ['1', '42', 'abc', '999', 'challenge_101']) {
        final count = socialProofCount(id);
        expect(count, greaterThanOrEqualTo(800));
        expect(count, lessThan(4500));
      }
    });

    test('is deterministic — same ID always returns same count', () {
      expect(socialProofCount('test_id'), socialProofCount('test_id'));
      expect(socialProofCount('42'), socialProofCount('42'));
    });

    test('different IDs produce different counts (no trivial collision)', () {
      final counts = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10'}
          .map(socialProofCount)
          .toSet();
      // At least half should be unique across 10 samples
      expect(counts.length, greaterThan(5));
    });
  });
}
