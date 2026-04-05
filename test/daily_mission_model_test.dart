import 'package:flutter_test/flutter_test.dart';
import 'package:syntra/challenge.dart';
import 'package:syntra/logic/daily_missions_logic.dart';

Challenge _make(String id, {int xp = 50}) => Challenge(
      id: id,
      title: 'T',
      description: 'D',
      xp: xp,
      time: 60,
      type: 'solo',
      flirt: false,
      environment: 'street',
    );

void main() {
  group('MissionTier', () {
    test('has 3 values', () {
      expect(MissionTier.values.length, 3);
    });

    test('key returns name string', () {
      expect(MissionTier.comfort.key, 'comfort');
      expect(MissionTier.growth.key, 'growth');
      expect(MissionTier.bold.key, 'bold');
    });
  });

  group('DailyMission', () {
    test('defaults to not completed', () {
      final m = DailyMission(tier: MissionTier.comfort, challenge: _make('1'));
      expect(m.completed, false);
    });

    test('copyWith toggles completed', () {
      final m = DailyMission(tier: MissionTier.bold, challenge: _make('2'));
      final done = m.copyWith(completed: true);
      expect(done.completed, true);
      expect(done.tier, MissionTier.bold);
      expect(done.challenge.id, '2');
    });

    test('copyWith without args preserves state', () {
      final m = DailyMission(
          tier: MissionTier.growth, challenge: _make('3'), completed: true);
      final same = m.copyWith();
      expect(same.completed, true);
      expect(same.tier, MissionTier.growth);
    });
  });
}
