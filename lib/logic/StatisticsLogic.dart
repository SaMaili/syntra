// StatisticsLogic.dart
// Contains business logic and data fetching for StatisticsScreen

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class StatisticsLogic {
  // Cache the database instance to avoid repeated opens
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'challenge_database.db');
    return await openDatabase(path);
  }

  /// Fetches the XP earned for each day of the current week (Monday-Sunday).
  /// OPTIMIZED: Single query instead of 7 separate queries
  Future<List<int>> fetchWeeklyXp() async {
    final db = await database;
    final now = DateTime.now();
    final weekDay = now.weekday;
    final startOfWeek = now.subtract(Duration(days: weekDay - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));

    final startStr = startOfWeek.toIso8601String().substring(0, 10);
    final endStr = endOfWeek.toIso8601String().substring(0, 10);

    // Single query to get all week data
    final result = await db.rawQuery('''
      SELECT 
        date(timestamp) as day,
        SUM(CASE WHEN earned IS NOT NULL THEN earned ELSE 0 END) as xp
      FROM logbook 
      WHERE date(timestamp) BETWEEN ? AND ?
      GROUP BY date(timestamp)
      ORDER BY date(timestamp)
    ''', [startStr, endStr]);

    // Create map for quick lookup
    final Map<String, int> xpMap = {};
    for (final row in result) {
      xpMap[row['day'] as String] = (row['xp'] as int?) ?? 0;
    }

    // Build the week array (Monday to Sunday)
    final List<int> xpList = [];
    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      final dayStr = day.toIso8601String().substring(0, 10);
      xpList.add(xpMap[dayStr] ?? 0);
    }

    return xpList;
  }

  /// Fetches the number of completed and failed challenges for each day of the current week.
  /// OPTIMIZED: Single query instead of 14 separate queries
  Future<List<List<int>>> fetchWeeklyChallengeCounts() async {
    final db = await database;
    final now = DateTime.now();
    final weekDay = now.weekday;
    final startOfWeek = now.subtract(Duration(days: weekDay - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));

    final startStr = startOfWeek.toIso8601String().substring(0, 10);
    final endStr = endOfWeek.toIso8601String().substring(0, 10);

    // Single query to get all week data with conditional counting
    final result = await db.rawQuery('''
      SELECT 
        date(timestamp) as day,
        SUM(CASE WHEN status = 'success' THEN 1 ELSE 0 END) as completed,
        SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) as failed
      FROM logbook 
      WHERE date(timestamp) BETWEEN ? AND ?
      GROUP BY date(timestamp)
      ORDER BY date(timestamp)
    ''', [startStr, endStr]);

    // Create maps for quick lookup
    final Map<String, int> completedMap = {};
    final Map<String, int> failedMap = {};
    for (final row in result) {
      final day = row['day'] as String;
      completedMap[day] = (row['completed'] as int?) ?? 0;
      failedMap[day] = (row['failed'] as int?) ?? 0;
    }

    // Build the week arrays (Monday to Sunday)
    final List<int> completed = [];
    final List<int> failed = [];
    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      final dayStr = day.toIso8601String().substring(0, 10);
      completed.add(completedMap[dayStr] ?? 0);
      failed.add(failedMap[dayStr] ?? 0);
    }

    return [completed, failed];
  }

  /// Fetches all overview statistics in a single optimized query
  /// OPTIMIZED: Single query instead of 5 separate queries
  Future<Map<String, int>> fetchAllOverviewStats() async {
    final db = await database;
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);

    // Single comprehensive query for all overview stats
    final result = await db.rawQuery('''
      SELECT 
        SUM(CASE WHEN earned IS NOT NULL THEN earned ELSE 0 END) as totalXp,
        SUM(CASE WHEN earned IS NOT NULL AND date(timestamp) = ? THEN earned ELSE 0 END) as todayXp,
        SUM(CASE WHEN status = 'success' THEN 1 ELSE 0 END) as completedAllTime,
        SUM(CASE WHEN status = 'success' AND date(timestamp) = ? THEN 1 ELSE 0 END) as completedToday
      FROM logbook
    ''', [todayStr, todayStr]);

    final row = result.first;

    // Calculate streak separately (more complex logic)
    final streak = await _fetchCurrentStreakOptimized();

    return {
      'totalXp': (row['totalXp'] as int?) ?? 0,
      'todayXp': (row['todayXp'] as int?) ?? 0,
      'completedAllTime': (row['completedAllTime'] as int?) ?? 0,
      'completedToday': (row['completedToday'] as int?) ?? 0,
      'streak': streak,
    };
  }

  /// Optimized streak calculation
  Future<int> _fetchCurrentStreakOptimized() async {
    final db = await database;

    // Get dates with completed challenges, ordered by date descending
    final result = await db.rawQuery('''
      SELECT DISTINCT date(timestamp) as day
      FROM logbook 
      WHERE status = 'success'
      ORDER BY date(timestamp) DESC
      LIMIT 100
    ''');

    if (result.isEmpty) return 0;

    final completedDates = result.map((row) => DateTime.parse(row['day'] as String)).toList();
    final today = DateTime.now();
    final todayStr = today.toIso8601String().substring(0, 10);

    int streak = 0;
    DateTime checkDate = today;

    for (int i = 0; i < 100; i++) { // Reasonable limit to prevent infinite loops
      final checkDateStr = checkDate.toIso8601String().substring(0, 10);

      // Check if this date has completed challenges
      if (completedDates.any((date) => date.toIso8601String().substring(0, 10) == checkDateStr)) {
        streak++;
        checkDate = checkDate.subtract(Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  // Keep individual methods for backward compatibility
  Future<int> fetchTotalXp() async {
    final stats = await fetchAllOverviewStats();
    return stats['totalXp']!;
  }

  Future<int> fetchTodayXp() async {
    final stats = await fetchAllOverviewStats();
    return stats['todayXp']!;
  }

  Future<int> fetchCompletedAllTime() async {
    final stats = await fetchAllOverviewStats();
    return stats['completedAllTime']!;
  }

  Future<int> fetchCompletedToday() async {
    final stats = await fetchAllOverviewStats();
    return stats['completedToday']!;
  }

  Future<int> fetchCurrentStreak() async {
    final stats = await fetchAllOverviewStats();
    return stats['streak']!;
  }

  // Clean up database connection when done
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
