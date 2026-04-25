import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../data/settings_repository.dart';
import '../logic/weekly_streak_logic.dart';

/// All reads and writes to the logbook SQLite table go through this class.
/// The challenge catalog tables are no longer read here — they live in JSON.
class LogbookRepository {
  static LogbookRepository? _instance;
  static LogbookRepository get instance =>
      _instance ??= LogbookRepository._();

  LogbookRepository._();

  Database? _db;

  static const _kCreateTable = '''
    CREATE TABLE IF NOT EXISTS logbook (
      id               INTEGER PRIMARY KEY AUTOINCREMENT,
      challenge_id     TEXT,
      status           TEXT,
      earned           INTEGER,
      timestamp        DATETIME,
      notes            TEXT,
      feeling          INTEGER,
      perception       INTEGER,
      duration_seconds INTEGER,
      pre_anxiety      INTEGER
    )
  ''';

  static Future<void> _createIndexes(Database db) async {
    await db.execute('CREATE INDEX IF NOT EXISTS idx_logbook_status_challenge ON logbook(status, challenge_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_logbook_timestamp ON logbook(timestamp)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_logbook_challenge ON logbook(challenge_id)');
  }

  Future<Database> get _database async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'logbook.db');
    _db = await openDatabase(
      path,
      version: 2,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) await _createIndexes(db);
      },
      onDowngrade: (db, oldVersion, newVersion) async {
        await db.execute('DROP TABLE IF EXISTS logbook');
        await db.execute(_kCreateTable);
        await _createIndexes(db);
      },
      onCreate: (db, version) async {
        await db.execute(_kCreateTable);
        await _createIndexes(db);
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
    int? preAnxiety,
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
      'pre_anxiety': preAnxiety,
    });
  }

  // ─── Read ─────────────────────────────────────────────────────────────────

  /// Returns entries filtered by [status] and/or [challengeIds].
  /// Pass null to skip a filter.
  Future<List<Map<String, dynamic>>> filteredEntries({
    int limit = 50,
    int offset = 0,
    String? status,              // 'success' | 'tried' | null = all
    Set<String>? challengeIds,   // restrict to these challenge IDs (title search)
  }) async {
    final db = await _database;
    final conditions = <String>[];
    final args = <dynamic>[];

    if (status != null) {
      conditions.add('status = ?');
      args.add(status);
    }
    if (challengeIds != null && challengeIds.isNotEmpty) {
      final placeholders = List.filled(challengeIds.length, '?').join(', ');
      conditions.add('challenge_id IN ($placeholders)');
      args.addAll(challengeIds);
    }

    final where = conditions.isEmpty ? null : conditions.join(' AND ');
    return db.query(
      'logbook',
      where: where,
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );
  }

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
    final totalSeconds = (row['totalSeconds'] as int?) ?? 0;
    final now = DateTime.now();
    final xpByWeek = await weeklyXpByWeek(weeks: 52);
    final frozenWeeks = await SettingsRepository.instance.loadFrozenWeeks();
    final weekStreak =
        WeeklyStreakLogic.countStreak(xpByWeek, now, frozenWeeks: frozenWeeks);
    // pendingWeekStreak: streak from last week — shown in grey when the current
    // week hasn't reached the threshold yet (grace period motivational cue).
    // Resets to 0 only when two or more consecutive weeks were missed.
    final pendingWeekStreak = weekStreak == 0
        ? WeeklyStreakLogic.countPendingStreak(xpByWeek, now,
            frozenWeeks: frozenWeeks)
        : 0;

    return {
      'totalXp': (row['totalXp'] as int?) ?? 0,
      'todayXp': (row['todayXp'] as int?) ?? 0,
      'completedAllTime': (row['completedAllTime'] as int?) ?? 0,
      'completedToday': (row['completedToday'] as int?) ?? 0,
      'weekStreak': weekStreak,
      'pendingWeekStreak': pendingWeekStreak,
      'minutesBrave': totalSeconds ~/ 60,
    };
  }

  /// XP earned per ISO year-week (e.g. `"2026-W14"`) for the last [weeks] weeks.
  /// Weeks with no entries are not included in the returned map.
  Future<Map<String, int>> weeklyXpByWeek({int weeks = 52}) async {
    final db = await _database;
    final now = DateTime.now();
    final cutoff = DateTime(now.year, now.month, now.day - weeks * 7)
        .toIso8601String()
        .substring(0, 10);

    final rows = await db.rawQuery('''
      SELECT timestamp, COALESCE(SUM(earned), 0) AS xp
      FROM logbook
      WHERE date(timestamp) >= ?
      GROUP BY strftime('%Y-%W', timestamp)
    ''', [cutoff]);

    final result = <String, int>{};
    for (final r in rows) {
      final ts = DateTime.parse(r['timestamp'] as String);
      final key = WeeklyStreakLogic.isoYearWeek(ts);
      result[key] = (result[key] ?? 0) + (r['xp'] as int);
    }
    return result;
  }

  /// Total XP earned in the current Mon–Sun week.
  Future<int> currentWeekXp() async {
    final db = await _database;
    final now = DateTime.now();
    final monday = WeeklyStreakLogic.startOfIsoWeek(now);
    final mondayStr = monday.toIso8601String().substring(0, 10);

    final rows = await db.rawQuery('''
      SELECT COALESCE(SUM(earned), 0) AS xp
      FROM logbook
      WHERE date(timestamp) >= ?
    ''', [mondayStr]);
    return (rows.first['xp'] as int?) ?? 0;
  }

  /// Pure daily-streak-counting logic, kept for the existing test suite.
  /// [successDates] must be distinct dates (time part ignored).
  /// [today] is the reference date (typically DateTime.now()).
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

  /// Returns the latest completion timestamp per challenge ID.
  Future<Map<String, DateTime>> latestCompletionDates() async {
    final db = await _database;
    final rows = await db.rawQuery(
      "SELECT challenge_id, MAX(timestamp) AS latest FROM logbook "
      "WHERE status = 'success' GROUP BY challenge_id",
    );
    return {
      for (final r in rows)
        r['challenge_id'] as String: DateTime.parse(r['latest'] as String),
    };
  }

  // ─── Delete ───────────────────────────────────────────────────────────────

  Future<void> deleteEntry(int id) async {
    final db = await _database;
    await db.delete('logbook', where: 'id = ?', whereArgs: [id]);
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM logbook'));
    if (count == 0) {
      await SettingsRepository.instance.saveFrozenWeeks({});
    }
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
        now.subtract(Duration(days: (weeks - 1) * 7 + (todayWeekday - 1)));
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

  /// Returns the last [limit] individual feeling scores with their timestamps,
  /// oldest first. Each entry is one challenge completion.
  Future<List<({DateTime date, double avg})>> averageMoodPerDay(
      {int days = 14}) async {
    final db = await _database;
    // Fetch last 20 individual entries so the chart shows a curve even when
    // all data is from a single day.
    final rows = await db.rawQuery('''
      SELECT timestamp, feeling
      FROM logbook
      WHERE feeling IS NOT NULL
      ORDER BY timestamp DESC
      LIMIT 20
    ''');
    return rows.reversed.map((r) {
      final date = DateTime.parse(r['timestamp'] as String);
      final avg = (r['feeling'] as num).toDouble();
      return (date: date, avg: avg);
    }).toList();
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
