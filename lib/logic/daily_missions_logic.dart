import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../challenge.dart';
import '../data/challenge_repository.dart';

/// The three mission tiers shown on the Mission Board each day.
enum MissionTier { comfort, growth, bold }

extension MissionTierX on MissionTier {
  String get key => name; // 'comfort' | 'growth' | 'bold'
}

/// One curated mission for the day.
class DailyMission {
  final MissionTier tier;
  final Challenge challenge;
  final bool completed;

  const DailyMission({
    required this.tier,
    required this.challenge,
    this.completed = false,
  });

  DailyMission copyWith({bool? completed}) =>
      DailyMission(tier: tier, challenge: challenge, completed: completed ?? this.completed);
}

/// Picks and persists 3 daily missions (one per tier) keyed by calendar date.
/// Challenge selection is XP-percentile–based so it adapts to any catalog size.
class DailyMissionsLogic {
  static const _keyDate = 'daily_missions_date';
  static const _keyComfortId = 'daily_missions_comfort_id';
  static const _keyGrowthId = 'daily_missions_growth_id';
  static const _keyBoldId = 'daily_missions_bold_id';
  static const _keyComfortDone = 'daily_missions_comfort_done';
  static const _keyGrowthDone = 'daily_missions_growth_done';
  static const _keyBoldDone = 'daily_missions_bold_done';

  static String _todayStr() {
    final t = DateTime.now();
    return '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';
  }

  Future<List<DailyMission>> getTodayMissions(
      String languageCode, SharedPreferences prefs) async {
    final today = _todayStr();
    final storedDate = prefs.getString(_keyDate);

    final all = await ChallengeRepository.instance.loadChallenges(languageCode);

    // Split catalog into three XP tiers (percentile-based, non-flirt preferred).
    final pool = all.where((c) => !c.flirt).toList()
      ..sort((a, b) => a.xp.compareTo(b.xp));

    final third = (pool.length / 3).ceil();
    final comfortPool = pool.sublist(0, third);
    final growthPool = pool.sublist(third, min(third * 2, pool.length));
    final boldPool = pool.sublist(min(third * 2, pool.length));

    // Bold tier may include flirt challenges if the pool is too small.
    final boldFallback = boldPool.isEmpty
        ? (all..sort((a, b) => b.xp.compareTo(a.xp))).take(5).toList()
        : boldPool;

    // New day — re-roll missions.
    final needsRoll = storedDate != today ||
        prefs.getString(_keyComfortId) == null ||
        prefs.getString(_keyGrowthId) == null ||
        prefs.getString(_keyBoldId) == null;

    if (needsRoll) {
      final comfortId = _pick(comfortPool).id;
      final growthId =
          _pick(growthPool.isEmpty ? comfortPool : growthPool).id;
      final boldId = _pick(boldFallback).id;

      await prefs.setString(_keyDate, today);
      await prefs.setString(_keyComfortId, comfortId);
      await prefs.setString(_keyGrowthId, growthId);
      await prefs.setString(_keyBoldId, boldId);
      await prefs.setBool(_keyComfortDone, false);
      await prefs.setBool(_keyGrowthDone, false);
      await prefs.setBool(_keyBoldDone, false);
    }

    final comfortId = prefs.getString(_keyComfortId) ?? comfortPool.first.id;
    final growthId = prefs.getString(_keyGrowthId) ??
        (growthPool.isEmpty ? comfortPool : growthPool).first.id;
    final boldId = prefs.getString(_keyBoldId) ?? boldFallback.first.id;

    Challenge findChallenge(String id) =>
        all.firstWhere((c) => c.id == id, orElse: () => all.first);

    return [
      DailyMission(
        tier: MissionTier.comfort,
        challenge: findChallenge(comfortId),
        completed: prefs.getBool(_keyComfortDone) ?? false,
      ),
      DailyMission(
        tier: MissionTier.growth,
        challenge: findChallenge(growthId),
        completed: prefs.getBool(_keyGrowthDone) ?? false,
      ),
      DailyMission(
        tier: MissionTier.bold,
        challenge: findChallenge(boldId),
        completed: prefs.getBool(_keyBoldDone) ?? false,
      ),
    ];
  }

  Future<void> markCompleted(MissionTier tier, SharedPreferences prefs) async {
    final key = switch (tier) {
      MissionTier.comfort => _keyComfortDone,
      MissionTier.growth => _keyGrowthDone,
      MissionTier.bold => _keyBoldDone,
    };
    await prefs.setBool(key, true);
  }

  Challenge _pick(List<Challenge> pool) => pool[Random().nextInt(pool.length)];
}
