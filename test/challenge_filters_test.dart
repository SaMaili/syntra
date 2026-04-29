import 'package:flutter_test/flutter_test.dart';
import 'package:syntra/providers/challenge_providers.dart';

void main() {
  group('ChallengeFilters', () {
    test('default state is all, flirt=all', () {
      const f = ChallengeFilters();
      expect(f.typeFilter, ChallengeTypeFilter.all);
      expect(f.flirtFilter, FlirtFilter.all);
    });

    test('copyWith preserves unchanged fields', () {
      const original = ChallengeFilters(
        typeFilter: ChallengeTypeFilter.group,
        flirtFilter: FlirtFilter.showOnly,
      );
      final updated = original.copyWith(typeFilter: ChallengeTypeFilter.all);
      expect(updated.typeFilter, ChallengeTypeFilter.all);
      expect(updated.flirtFilter, FlirtFilter.showOnly);
    });

    test('copyWith flirtFilter changes only that field', () {
      const original = ChallengeFilters(typeFilter: ChallengeTypeFilter.all);
      final updated = original.copyWith(flirtFilter: FlirtFilter.showOnly);
      expect(updated.typeFilter, ChallengeTypeFilter.all);
      expect(updated.flirtFilter, FlirtFilter.showOnly);
    });
  });
}
