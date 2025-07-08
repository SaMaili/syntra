// StatisticsLogic.dart
// Contains business logic and data fetching for StatisticsScreen

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class StatisticsLogic {
  /// Fetches the XP earned for each day of the current week (Monday-Sunday).
  Future<List<int>> fetchWeeklyXp() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'challenge_database.db');
    final db = await openDatabase(path);
    final now = DateTime.now();
    final weekDay = now.weekday; // 1 = Monday, 7 = Sunday
    final startOfWeek = now.subtract(Duration(days: weekDay - 1));
    final List<int> xpList = [];
    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      final dayStr = day.toIso8601String().substring(0, 10);
      final result = await db.rawQuery(
        "SELECT SUM(earned) as xp FROM logbook WHERE date(timestamp) = ? AND earned IS NOT NULL",
        [dayStr],
      );
      final xp = (result.first['xp'] as int?) ?? 0;
      xpList.add(xp);
    }
    return xpList;
  }

  /// Fetches the number of completed and failed challenges for each day of the current week.
  /// Returns a list with two lists: [completed, failed].
  Future<List<List<int>>> fetchWeeklyChallengeCounts() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'challenge_database.db');
    final db = await openDatabase(path);
    final now = DateTime.now();
    final weekDay = now.weekday; // 1 = Monday, 7 = Sunday
    final startOfWeek = now.subtract(Duration(days: weekDay - 1));
    final List<int> completed = [];
    final List<int> failed = [];
    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      final dayStr = day.toIso8601String().substring(0, 10);
      final resultCompleted = await db.rawQuery(
        "SELECT COUNT(*) as cnt FROM logbook WHERE date(timestamp) = ? AND status = 'success'",
        [dayStr],
      );
      final resultFailed = await db.rawQuery(
        "SELECT COUNT(*) as cnt FROM logbook WHERE date(timestamp) = ? AND status = 'failed'",
        [dayStr],
      );
      completed.add((resultCompleted.first['cnt'] as int?) ?? 0);
      failed.add((resultFailed.first['cnt'] as int?) ?? 0);
    }
    return [completed, failed];
  }

  /// Fetches the total XP earned (all time).
  Future<int> fetchTotalXp() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'challenge_database.db');
    final db = await openDatabase(path);
    final result = await db.rawQuery(
      'SELECT SUM(earned) as totalXp FROM logbook WHERE earned IS NOT NULL',
    );
    return (result.first['totalXp'] as int?) ?? 0;
  }

  /// Fetches the XP earned today (for the current date).
  Future<int> fetchTodayXp() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'challenge_database.db');
    final db = await openDatabase(path);
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final result = await db.rawQuery(
      "SELECT SUM(earned) as todayXp FROM logbook WHERE date(timestamp) = ? AND earned IS NOT NULL",
      [todayStr],
    );
    return (result.first['todayXp'] as int?) ?? 0;
  }

  /// Fetches the number of completed quests all time.
  Future<int> fetchCompletedAllTime() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'challenge_database.db');
    final db = await openDatabase(path);
    final result = await db.rawQuery(
      "SELECT COUNT(*) as completed FROM logbook WHERE status = 'success'",
    );
    return (result.first['completed'] as int?) ?? 0;
  }

  /// Fetches the number of completed quests today.
  Future<int> fetchCompletedToday() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'challenge_database.db');
    final db = await openDatabase(path);
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final result = await db.rawQuery(
      "SELECT COUNT(*) as completedToday FROM logbook WHERE status = 'success' AND date(timestamp) = ?",
      [todayStr],
    );
    return (result.first['completedToday'] as int?) ?? 0;
  }

  /// Fetches the current streak in days (consecutive days with at least one completed quest).
  Future<int> fetchCurrentStreak() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'challenge_database.db');
    final db = await openDatabase(path);
    int streak = 0;
    DateTime day = DateTime.now();
    while (true) {
      final dayStr = day.toIso8601String().substring(0, 10);
      final result = await db.rawQuery(
        "SELECT COUNT(*) as completed FROM logbook WHERE status = 'success' AND date(timestamp) = ?",
        [dayStr],
      );
      final completed = (result.first['completed'] as int?) ?? 0;
      if (completed > 0) {
        streak++;
        day = day.subtract(Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }
}
