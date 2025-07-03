import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' as stats;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../static.dart';
import 'LogbookPage.dart';

class StatisticsScreen extends stats.StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  stats.Widget build(stats.BuildContext context) {
    return stats.Padding(
      padding: const stats.EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: stats.SingleChildScrollView(
        child: stats.Column(
          crossAxisAlignment: stats.CrossAxisAlignment.center,
          children: [
            stats.Text(
              'Your Statistics',
              style: stats.TextStyle(
                fontSize: 28,
                fontWeight: stats.FontWeight.bold,
                color: AppStatic.grape,
              ),
            ),
            stats.SizedBox(height: 16),
            stats.ElevatedButton.icon(
              icon: stats.Icon(stats.Icons.history),
              label: stats.Text('Challenge Logbook'),
              style: stats.ElevatedButton.styleFrom(
                backgroundColor: AppStatic.grape,
                foregroundColor: stats.Colors.white,
                padding: const stats.EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: stats.RoundedRectangleBorder(
                  borderRadius: stats.BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                stats.Navigator.of(context).push(
                  stats.MaterialPageRoute(
                    builder: (_) => LogbookPage(),
                  ),
                );
              },
            ),
            stats.SizedBox(height: 30),
            StatsOverviewContainer(),
            stats.SizedBox(height: 30),
            stats.Container(
              padding: stats.EdgeInsets.all(20),
              decoration: stats.BoxDecoration(
                color: AppStatic.marianBlueLight,
                borderRadius: stats.BorderRadius.circular(20),
              ),
              child: stats.FutureBuilder<List<int>>(
                // XP als int
                future: _fetchWeeklyXp(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData ||
                      snapshot.data == null ||
                      snapshot.data!.length != 7) {
                    return stats.Center(
                      child: stats.CircularProgressIndicator(),
                    );
                  }
                  final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  final xpList = snapshot.data!;
                  return stats.Column(
                    children: [
                      stats.Text(
                        'Weekly XP Progress',
                        style: stats.TextStyle(
                          fontSize: 18,
                          fontWeight: stats.FontWeight.bold,
                          color: AppStatic.marianBlue,
                        ),
                      ),
                      stats.SizedBox(height: 15),
                      stats.SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: true),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    int idx = value.toInt();
                                    if (idx < 0 || idx > 6)
                                      return stats.Container();
                                    return stats.Padding(
                                      padding: const stats.EdgeInsets.only(
                                        top: 8.0,
                                      ),
                                      child: stats.Text(
                                        days[idx],
                                        style: stats.TextStyle(fontSize: 12),
                                      ),
                                    );
                                  },
                                  interval: 1,
                                ),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            minX: 0,
                            maxX: 6,
                            maxY: (xpList.reduce((a, b) => a > b ? a : b) + 20)
                                .toDouble(),
                            lineBarsData: [
                              LineChartBarData(
                                spots: [
                                  for (int i = 0; i < 7; i++)
                                    FlSpot(i.toDouble(), xpList[i].toDouble()),
                                ],
                                isCurved: false,
                                color: AppStatic.marianBlue,
                                barWidth: 4,
                                dotData: FlDotData(show: true),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            stats.SizedBox(height: 30),
            stats.Container(
              padding: stats.EdgeInsets.all(20),
              decoration: stats.BoxDecoration(
                color: AppStatic.marianBlueLight,
                borderRadius: stats.BorderRadius.circular(20),
              ),
              child: stats.FutureBuilder<List<List<int>>>(
                future: _fetchWeeklyChallengeCounts(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData ||
                      snapshot.data == null ||
                      snapshot.data!.length != 2) {
                    return stats.Center(
                      child: stats.CircularProgressIndicator(),
                    );
                  }
                  final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  final completed = snapshot.data![0];
                  final failed = snapshot.data![1];
                  final maxY =
                      (([
                                ...completed,
                                ...failed,
                              ].reduce((a, b) => a > b ? a : b)) +
                              1)
                          .toDouble();
                  return stats.Column(
                    children: [
                      stats.Text(
                        'Weekly Challenges (completed/failed)',
                        style: stats.TextStyle(
                          fontSize: 18,
                          fontWeight: stats.FontWeight.bold,
                          color: AppStatic.marianBlue,
                        ),
                      ),
                      stats.SizedBox(height: 15),
                      stats.SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: true),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    int idx = value.toInt();
                                    if (idx < 0 || idx > 6)
                                      return stats.Container();
                                    return stats.Padding(
                                      padding: const stats.EdgeInsets.only(
                                        top: 8.0,
                                      ),
                                      child: stats.Text(
                                        days[idx],
                                        style: stats.TextStyle(fontSize: 12),
                                      ),
                                    );
                                  },
                                  interval: 1,
                                ),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            minX: 0,
                            maxX: 6,
                            minY: 0,
                            maxY: maxY,
                            lineBarsData: [
                              LineChartBarData(
                                spots: [
                                  for (int i = 0; i < 7; i++)
                                    FlSpot(
                                      i.toDouble(),
                                      completed[i].toDouble(),
                                    ),
                                ],
                                isCurved: false,
                                color: stats.Colors.green,
                                barWidth: 4,
                                dotData: FlDotData(show: true),
                              ),
                              LineChartBarData(
                                spots: [
                                  for (int i = 0; i < 7; i++)
                                    FlSpot(i.toDouble(), failed[i].toDouble()),
                                ],
                                isCurved: false,
                                color: stats.Colors.red,
                                barWidth: 4,
                                dotData: FlDotData(show: true),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            stats.SizedBox(height: 30),
            DebugDbButton(),
          ],
        ),
      ),
    );
  }

  stats.Widget _buildStatItem(String label, String value) {
    return stats.Row(
      mainAxisAlignment: stats.MainAxisAlignment.spaceBetween,
      children: [
        stats.Text(
          label,
          style: stats.TextStyle(fontSize: 16, color: AppStatic.textPrimary),
        ),
        stats.Text(
          value,
          style: stats.TextStyle(
            fontSize: 16,
            fontWeight: stats.FontWeight.bold,
            color: AppStatic.grape,
          ),
        ),
      ],
    );
  }

  Future<List<int>> _fetchWeeklyXp() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'challenge_database.db');
    final db = await openDatabase(path);
    final now = DateTime.now();
    final weekDay = now.weekday; // 1 = Montag, 7 = Sonntag
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

  Future<List<List<int>>> _fetchWeeklyChallengeCounts() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'challenge_database.db');
    final db = await openDatabase(path);
    final now = DateTime.now();
    final weekDay = now.weekday; // 1 = Montag, 7 = Sonntag
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
}

class StatsOverviewContainer extends stats.StatelessWidget {
  const StatsOverviewContainer({super.key});

  Future<int> _fetchTotalXp() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'challenge_database.db');
    final db = await openDatabase(path);
    final result = await db.rawQuery(
      'SELECT SUM(earned) as totalXp FROM logbook WHERE earned IS NOT NULL',
    );

    return (result.first['totalXp'] as int?) ?? 0;
  }

  Future<int> fetchTotalXpToday() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'challenge_database.db');
    final db = await openDatabase(path);
    final result = await db.rawQuery(
      "SELECT SUM(earned) as totalXpToday FROM logbook WHERE date(timestamp) = date('now') AND earned IS NOT NULL",
    );
    return (result.first['totalXpToday'] as int?) ?? 0;
  }

  Future<int> _fetchQuestsCompleted() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'challenge_database.db');
    final db = await openDatabase(path);
    final result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM logbook WHERE status = 'success'",
    );

    return (result.first['count'] as int?) ?? 0;
  }

  Future<int> _fetchDaysActive() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'challenge_database.db');
    final db = await openDatabase(path);
    final result = await db.rawQuery(
      'SELECT COUNT(DISTINCT date(timestamp)) as days FROM logbook',
    );

    return (result.first['days'] as int?) ?? 0;
  }

  Future<int> _fetchCurrentStreak() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'challenge_database.db');
    final db = await openDatabase(path);
    final result = await db.rawQuery('''
      WITH days AS (
        SELECT DISTINCT date(timestamp) as d FROM logbook
      ),
      numbered AS (
        SELECT d, ROW_NUMBER() OVER (ORDER BY d DESC) as rn FROM days
      ),
      streaks AS (
        SELECT d, rn, DATE('now', '-'||(rn-1)||' day') as expected
        FROM numbered
      )
      SELECT COUNT(*) as streak FROM streaks WHERE d = expected;
    ''');
    return (result.first['streak'] as int?) ?? 0;
  }

  @override
  stats.Widget build(stats.BuildContext context) {
    return stats.Container(
      padding: stats.EdgeInsets.all(20),
      decoration: stats.BoxDecoration(
        color: AppStatic.grapeLight,
        borderRadius: stats.BorderRadius.circular(20),
      ),
      child: stats.FutureBuilder<List<int>>(
        future: Future.wait([
          _fetchTotalXp(),
          _fetchQuestsCompleted(),
          _fetchDaysActive(),
          _fetchCurrentStreak(),
          fetchTotalXpToday(),
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data!.length < 5) {
            return stats.Center(child: stats.CircularProgressIndicator());
          }
          final totalXp = snapshot.data![0];
          final questsCompleted = snapshot.data![1];
          final daysActive = snapshot.data![2];
          final currentStreak = snapshot.data![3];
          final totalXpToday = snapshot.data![4];
          return stats.Column(
            children: [
              _buildStatItem('Total XP', totalXp.toString()),
              stats.SizedBox(height: 15),
              _buildStatItem('Total XP today', totalXpToday.toString()),
              stats.SizedBox(height: 15),
              _buildStatItem('Quests Completed', questsCompleted.toString()),
              stats.SizedBox(height: 15),
              _buildStatItem('Days Active', daysActive.toString()),
              stats.SizedBox(height: 15),
              _buildStatItem('Current Streak', '$currentStreak days'),
            ],
          );
        },
      ),
    );
  }

  stats.Widget _buildStatItem(String label, String value) {
    return stats.Row(
      mainAxisAlignment: stats.MainAxisAlignment.spaceBetween,
      children: [
        stats.Text(
          label,
          style: stats.TextStyle(fontSize: 16, color: AppStatic.textPrimary),
        ),
        stats.Text(
          value,
          style: stats.TextStyle(
            fontSize: 16,
            fontWeight: stats.FontWeight.bold,
            color: AppStatic.grape,
          ),
        ),
      ],
    );
  }
}

class DebugDbButton extends stats.StatefulWidget {
  const DebugDbButton({super.key});

  @override
  stats.State<DebugDbButton> createState() => _DebugDbButtonState();
}

class _DebugDbButtonState extends stats.State<DebugDbButton> {
  String _output = '';
  bool _loading = false;

  Future<void> _printDbContent() async {
    setState(() {
      _loading = true;
      _output = '';
    });
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'challenge_database.db');
    StringBuffer buffer = StringBuffer();
    buffer.writeln('DB path: $path');
    final db = await openDatabase(path);
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );
    buffer.writeln('Tables:');
    buffer.writeln('logbook');
    final rows = await db.rawQuery('SELECT * FROM logbook');
    buffer.writeln('Content of logbook (${rows.length} rows):');
    for (final row in rows) {
      buffer.writeln(row.toString());
    }
    setState(() {
      _output = buffer.toString();
      _loading = false;
    });
  }

  @override
  stats.Widget build(stats.BuildContext context) {
    return stats.Column(
      crossAxisAlignment: stats.CrossAxisAlignment.stretch,
      children: [
        stats.ElevatedButton(
          onPressed: _loading ? null : _printDbContent,
          child: stats.Text('DB Debug: Show all logbook table'),
        ),
        if (_loading)
          stats.Padding(
            padding: const stats.EdgeInsets.all(8.0),
            child: stats.Center(child: stats.CircularProgressIndicator()),
          ),
        if (_output.isNotEmpty)
          stats.Container(
            margin: const stats.EdgeInsets.only(top: 12),
            padding: const stats.EdgeInsets.all(8),
            decoration: stats.BoxDecoration(
              color: stats.Colors.black.withOpacity(0.05),
              borderRadius: stats.BorderRadius.circular(8),
            ),
            constraints: stats.BoxConstraints(maxHeight: 300),
            child: stats.SingleChildScrollView(
              child: stats.SelectableText(
                _output,
                style: stats.TextStyle(fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }
}
