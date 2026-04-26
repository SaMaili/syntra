import 'package:flutter_test/flutter_test.dart';
import 'package:syntra/logic/badges_logic.dart';

Map<String, int> _stats({
  int completedAllTime = 0,
  int totalAura = 0,
  int minutesBrave = 0,
  int czlLevel = 1,
}) => {
      'completedAllTime': completedAllTime,
      'totalAura': totalAura,
      'minutesBrave': minutesBrave,
      'czlLevel': czlLevel,
    };

bool _earned(String id, Map<String, int> stats, {int bestStreak = 0}) {
  final badge = BadgesLogic.all.firstWhere((b) => b.id == id);
  return badge.isEarned(stats, bestStreak);
}

void main() {
  group('BadgesLogic — first_step', () {
    test('not earned with 0 completions', () {
      expect(_earned('first_step', _stats()), isFalse);
    });
    test('earned at exactly 1 completion', () {
      expect(_earned('first_step', _stats(completedAllTime: 1)), isTrue);
    });
  });

  group('BadgesLogic — ten_challenges', () {
    test('not earned with 9 completions', () {
      expect(_earned('ten_challenges', _stats(completedAllTime: 9)), isFalse);
    });
    test('earned at exactly 10 completions', () {
      expect(_earned('ten_challenges', _stats(completedAllTime: 10)), isTrue);
    });
  });

  group('BadgesLogic — fifty_challenges', () {
    test('not earned with 49 completions', () {
      expect(_earned('fifty_challenges', _stats(completedAllTime: 49)), isFalse);
    });
    test('earned at exactly 50 completions', () {
      expect(_earned('fifty_challenges', _stats(completedAllTime: 50)), isTrue);
    });
  });

  group('BadgesLogic — three_week_streak', () {
    test('not earned with best streak of 2', () {
      expect(_earned('three_week_streak', _stats(), bestStreak: 2), isFalse);
    });
    test('earned at exactly 3 weeks', () {
      expect(_earned('three_week_streak', _stats(), bestStreak: 3), isTrue);
    });
  });

  group('BadgesLogic — seven_week_streak', () {
    test('not earned with best streak of 6', () {
      expect(_earned('seven_week_streak', _stats(), bestStreak: 6), isFalse);
    });
    test('earned at exactly 7 weeks', () {
      expect(_earned('seven_week_streak', _stats(), bestStreak: 7), isTrue);
    });
  });

  group('BadgesLogic — century_aura', () {
    test('not earned with 99 Aura', () {
      expect(_earned('century_aura', _stats(totalAura: 99)), isFalse);
    });
    test('earned at exactly 100 Aura', () {
      expect(_earned('century_aura', _stats(totalAura: 100)), isTrue);
    });
  });

  group('BadgesLogic — five_hundred_aura', () {
    test('not earned with 499 Aura', () {
      expect(_earned('five_hundred_aura', _stats(totalAura: 499)), isFalse);
    });
    test('earned at exactly 500 Aura', () {
      expect(_earned('five_hundred_aura', _stats(totalAura: 500)), isTrue);
    });
  });

  group('BadgesLogic — brave_minutes', () {
    test('not earned with 59 minutes', () {
      expect(_earned('brave_minutes', _stats(minutesBrave: 59)), isFalse);
    });
    test('earned at exactly 60 minutes', () {
      expect(_earned('brave_minutes', _stats(minutesBrave: 60)), isTrue);
    });
  });

  group('BadgesLogic — level badges', () {
    for (int lvl = 2; lvl <= 10; lvl++) {
      final id = 'level_$lvl';
      test('$id not earned at CZL ${lvl - 1}', () {
        expect(_earned(id, _stats(czlLevel: lvl - 1)), isFalse);
      });
      test('$id earned at CZL $lvl', () {
        expect(_earned(id, _stats(czlLevel: lvl)), isTrue);
      });
    }
  });

  group('BadgesLogic.computeEarned', () {
    test('returns empty set for a brand-new user', () {
      expect(BadgesLogic.computeEarned(_stats(), 0), isEmpty);
    });

    test('returns all non-level badges for a highly experienced user', () {
      final earned = BadgesLogic.computeEarned(
        _stats(
          completedAllTime: 100,
          totalAura: 1000,
          minutesBrave: 120,
          czlLevel: 10,
        ),
        10,
      );
      expect(earned, containsAll([
        'first_step',
        'ten_challenges',
        'fifty_challenges',
        'three_week_streak',
        'seven_week_streak',
        'century_aura',
        'five_hundred_aura',
        'brave_minutes',
      ]));
    });
  });
}
