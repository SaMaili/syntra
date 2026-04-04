import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// All reads and writes to the logbook SQLite table go through this class.
/// The challenge catalog tables are no longer read here — they live in JSON.
class LogbookRepository {
  static LogbookRepository? _instance;
  static LogbookRepository get instance =>
      _instance ??= LogbookRepository._();

  LogbookRepository._();

  Database? _db;

  Future<Database> get _database async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'challenge_database.db');
    _db = await openDatabase(
      path,
      version: 4,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE logbook ADD COLUMN duration_seconds INTEGER',
          );
        }
        if (oldVersion < 3) {
          // Guard against devices where these columns were added outside of a
          // proper migration (e.g. during development on an earlier build).
          try {
            await db.execute(
              'ALTER TABLE logbook ADD COLUMN feeling INTEGER',
            );
          } catch (_) {}
          try {
            await db.execute(
              'ALTER TABLE logbook ADD COLUMN perception INTEGER',
            );
          } catch (_) {}
        }
        if (oldVersion < 4) {
          // Rebuild the table to change challenge_id from INTEGER to TEXT.
          // SQLite does not support ALTER COLUMN, so we use the recommended
          // rename-copy-drop pattern.
          await db.execute('''
            CREATE TABLE logbook_new (
              id               INTEGER PRIMARY KEY AUTOINCREMENT,
              challenge_id     TEXT,
              status           TEXT,
              earned           INTEGER,
              timestamp        DATETIME,
              notes            TEXT,
              feeling          INTEGER,
              perception       INTEGER,
              duration_seconds INTEGER
            )
          ''');
          // Use explicit column names so order mismatches never cause failures.
          await db.execute('''
            INSERT INTO logbook_new
              (id, challenge_id, status, earned, timestamp, notes,
               feeling, perception, duration_seconds)
            SELECT id, challenge_id, status, earned, timestamp, notes,
               feeling, perception, duration_seconds
            FROM logbook
          ''');
          await db.execute('DROP TABLE logbook');
          await db.execute('ALTER TABLE logbook_new RENAME TO logbook');
        }
      },
    );
    return _db!;
  }

  // ─── Write ────────────────────────────────────────────────────────────────

  Future<int> addEntry({
    required String challengeId,
    required String status,
    required int earned,
    required DateTime timestamp,
    String? notes,
    int? feeling,
    int? perception,
    int? durationSeconds,
  }) async {
    final db = await _database;
    return db.insert('logbook', {
      'challenge_id': challengeId,
      'status': status,
      'earned': earned,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
      'feeling': feeling,
      'perception': perception,
      'duration_seconds': durationSeconds,
    });
  }

  // ─── Read ─────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> allEntries({
    int limit = 50,
    int offset = 0,
  }) async {
    final db = await _database;
    return db.query(
      'logbook',
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );
  }

  Future<Map<String, dynamic>?> entryById(int id) async {
    final db = await _database;
    final rows = await db.query(
      'logbook',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isNotEmpty ? rows.first : null;
  }

  /// Returns aggregated statistics in a single SQL round-trip.
  Future<Map<String, int>> overviewStats() async {
    final db = await _database;
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final rows = await db.rawQuery('''
      SELECT
        COALESCE(SUM(earned), 0)                                          AS totalXp,
        COALESCE(SUM(CASE WHEN date(timestamp) = ? THEN earned ELSE 0 END), 0) AS todayXp,
        COALESCE(SUM(CASE WHEN status = 'success' THEN 1 ELSE 0 END), 0) AS completedAllTime,
        COALESCE(SUM(CASE WHEN status = 'success' AND date(timestamp) = ? THEN 1 ELSE 0 END), 0) AS completedToday,
        COALESCE(SUM(duration_seconds), 0) AS totalSeconds
      FROM logbook
    ''', [today, today]);

    final row = rows.first;
    final streak = await _currentStreak();
    final totalSeconds = (row['totalSeconds'] as int?) ?? 0;

    return {
      'totalXp': (row['totalXp'] as int?) ?? 0,
      'todayXp': (row['todayXp'] as int?) ?? 0,
      'completedAllTime': (row['completedAllTime'] as int?) ?? 0,
      'completedToday': (row['completedToday'] as int?) ?? 0,
      'streak': streak,
      'minutesBrave': totalSeconds ~/ 60,
    };
  }

  Future<int> _currentStreak() async {
    final db = await _database;
    final rows = await db.rawQuery('''
      SELECT DISTINCT date(timestamp) AS day
      FROM logbook
      WHERE status = 'success'
      ORDER BY date(timestamp) DESC
      LIMIT 100
    ''');

    if (rows.isEmpty) return 0;

    final dates = rows
        .map((r) => DateTime.parse(r['day'] as String))
        .toList();

    return countStreak(dates, DateTime.now());
  }

  /// Pure streak-counting logic, separated for testability.
  /// [successDates] must be distinct dates (time part ignored).
  /// [today] is the reference date (typically DateTime.now()).
  /// Uses calendar-day arithmetic to avoid DST edge cases.
  static int countStreak(List<DateTime> successDates, DateTime today) {
    if (successDates.isEmpty) return 0;

    String ymd(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    final dateStrings = successDates.map(ymd).toSet();

    int streak = 0;
    for (int i = 0; i < 100; i++) {
      final check = DateTime(today.year, today.month, today.day - i);
      if (dateStrings.contains(ymd(check))) {
        streak++;
      } else {
        if (i == 0) {
          // It's okay if today is missed, but yesterday must be present.
          continue;
        } else {
          break;
        }
      }
    }
    return streak;
  }

  /// XP per day for [days] days ending today (index 0 = oldest day).
  Future<List<int>> weeklyXp({int days = 7}) async {
    final db = await _database;
    final now = DateTime.now();
    final start = now.subtract(Duration(days: days - 1));
    final startStr = start.toIso8601String().substring(0, 10);
    final endStr = now.toIso8601String().substring(0, 10);

    final rows = await db.rawQuery('''
      SELECT date(timestamp) AS day, COALESCE(SUM(earned), 0) AS xp
      FROM logbook
      WHERE date(timestamp) BETWEEN ? AND ?
      GROUP BY date(timestamp)
    ''', [startStr, endStr]);

    final map = {for (final r in rows) r['day'] as String: r['xp'] as int};
    return List.generate(days, (i) {
      final d = start.add(Duration(days: i)).toIso8601String().substring(0, 10);
      return map[d] ?? 0;
    });
  }

  /// Last notes entry for a given challenge (for the "already completed" dialog).
  Future<Map<String, dynamic>?> lastNotesForChallenge(String challengeId) async {
    final db = await _database;
    final rows = await db.rawQuery(
      'SELECT notes, timestamp FROM logbook '
      'WHERE challenge_id = ? AND notes IS NOT NULL AND notes != "" '
      'ORDER BY timestamp DESC LIMIT 1',
      [challengeId],
    );
    return rows.isNotEmpty ? rows.first : null;
  }

  /// Returns all challenge IDs the user has ever completed (status = 'success').
  Future<Set<String>> completedChallengeIds() async {
    final db = await _database;
    final rows = await db.rawQuery(
      "SELECT DISTINCT challenge_id FROM logbook WHERE status = 'success'",
    );
    return {for (final r in rows) r['challenge_id'] as String};
  }

  // ─── Delete ───────────────────────────────────────────────────────────────

  Future<void> deleteEntry(int id) async {
    final db = await _database;
    await db.delete('logbook', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<List<int>>> weeklyChallengeCounts({int days = 7}) async {
    final db = await _database;
    final now = DateTime.now();
    final start = now.subtract(Duration(days: days - 1));
    final startStr = start.toIso8601String().substring(0, 10);
    final endStr = now.toIso8601String().substring(0, 10);

    final rows = await db.rawQuery('''
      SELECT
        date(timestamp) AS day,
        SUM(CASE WHEN status = 'success' THEN 1 ELSE 0 END) AS completed,
        SUM(CASE WHEN status = 'tried'   THEN 1 ELSE 0 END) AS failed
      FROM logbook
      WHERE date(timestamp) BETWEEN ? AND ?
      GROUP BY date(timestamp)
    ''', [startStr, endStr]);

    final completedMap = <String, int>{};
    final failedMap = <String, int>{};
    for (final r in rows) {
      completedMap[r['day'] as String] = (r['completed'] as int?) ?? 0;
      failedMap[r['day'] as String] = (r['failed'] as int?) ?? 0;
    }

    final completed = <int>[];
    final failed = <int>[];
    for (int i = 0; i < days; i++) {
      final d = start.add(Duration(days: i)).toIso8601String().substring(0, 10);
      completed.add(completedMap[d] ?? 0);
      failed.add(failedMap[d] ?? 0);
    }
    return [completed, failed];
  }

  /// Activity counts per day for the past [weeks] weeks (Mon-aligned grid).
  /// Returns a map of ISO date string → attempt count.
  Future<Map<String, int>> activityHeatmap({int weeks = 12}) async {
    final db = await _database;
    final now = DateTime.now();
    // Align to Monday of the earliest week
    final todayWeekday = now.weekday; // 1=Mon
    final endOfGrid = now;
    final startOfGrid =
        now.subtract(Duration(days: (weeks * 7) - 1 + (todayWeekday - 1)));
    final startStr = startOfGrid.toIso8601String().substring(0, 10);
    final endStr = endOfGrid.toIso8601String().substring(0, 10);

    final rows = await db.rawQuery('''
      SELECT date(timestamp) AS day, COUNT(*) AS cnt
      FROM logbook
      WHERE date(timestamp) BETWEEN ? AND ?
      GROUP BY date(timestamp)
    ''', [startStr, endStr]);

    return {for (final r in rows) r['day'] as String: r['cnt'] as int};
  }

  /// Returns feeling scores (0–4) for [challengeId], oldest first.
  /// Only rows where feeling IS NOT NULL are included.
  Future<List<int>> moodHistoryForChallenge(String challengeId) async {
    final db = await _database;
    final rows = await db.rawQuery('''
      SELECT feeling
      FROM logbook
      WHERE challenge_id = ? AND feeling IS NOT NULL
      ORDER BY timestamp ASC
    ''', [challengeId]);
    return rows.map((r) => r['feeling'] as int).toList();
  }

  /// Returns the number of successfully completed challenges since last Monday.
  Future<int> challengesCompletedThisWeek() async {
    final db = await _database;
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final mondayStr = monday.toIso8601String().substring(0, 10);
    final rows = await db.rawQuery('''
      SELECT COUNT(*) AS cnt
      FROM logbook
      WHERE status = 'success' AND date(timestamp) >= ?
    ''', [mondayStr]);
    return (rows.first['cnt'] as int?) ?? 0;
  }
}
