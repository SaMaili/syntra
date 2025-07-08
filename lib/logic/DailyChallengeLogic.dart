import 'package:shared_preferences/shared_preferences.dart';
import 'package:syntra/Challenge.dart';
import '../database/challenge_database.dart';
import 'dart:math';

class DailyChallengeData {
  final String title;
  final String description;
  final bool completed;

  DailyChallengeData({
    required this.title,
    required this.description,
    this.completed = false,
  });
}

class DailyChallengeLogic {
  static const String _challengeIdKey = 'daily_challenge_id';
  static const String _challengeDateKey = 'daily_challenge_date';
  static const String _challengeAcceptedKey = 'daily_challenge_accepted';
  static const String _challengeCompletedKey = 'daily_challenge_completed';

  // Get today's challenge, picking a new one if needed
  Future<Challenge?> getTodayChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    final storedDate = prefs.getString(_challengeDateKey);
    String? challengeId = prefs.getString(_challengeIdKey);

    if (storedDate != todayStr || challengeId == null) {
      // Pick a new random challenge
      final allChallenges = await ChallengeDatabase.instance.readAllChallenges();
      final random = Random();
      final challenge = allChallenges[random.nextInt(allChallenges.length)];
      challengeId = challenge.id;
      await prefs.setString(_challengeIdKey, challengeId);
      await prefs.setString(_challengeDateKey, todayStr);
      await prefs.setBool(_challengeAcceptedKey, false);
      await prefs.setBool(_challengeCompletedKey, false);
      return challenge;
    } else {
      // Load the challenge by ID
      final allChallenges = await ChallengeDatabase.instance.readAllChallenges();
      final challenge = allChallenges.firstWhere((c) => c.id == challengeId, orElse: () => allChallenges.first);
      return challenge;
    }
  }

  Future<bool> isAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_challengeAcceptedKey) ?? false;
  }

  Future<bool> isCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_challengeCompletedKey) ?? false;
  }

  Future<void> acceptChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_challengeAcceptedKey, true);
  }

  Future<void> markAsCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_challengeCompletedKey, true);
  }
}
