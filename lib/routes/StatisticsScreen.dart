// StatisticsScreen.dart
// This file defines the StatisticsScreen and StatsOverviewContainer widgets for displaying user statistics in the Syntra app.
// It includes logic for fetching and displaying XP, completed quests, and streaks, as well as a debug button for database inspection.

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../static.dart';
import 'LogbookPage.dart';
import '../logic/StatisticsLogic.dart';

// Main statistics screen widget
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  // Logic class instance for all data fetching
  static final StatisticsLogic logic = StatisticsLogic();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgGradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF232526), Color(0xFF414345)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFFe0c3fc), Color(0xFF8ec5fc)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
    final cardColor = isDark ? Colors.grey[900] : AppStatic.marianBlueLight;
    final statTitleColor = isDark ? Colors.pinkAccent : AppStatic.marianBlue;
    return Container(
      decoration: BoxDecoration(
        gradient: bgGradient,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, color: statTitleColor, size: 32),
                  const SizedBox(width: 10),
                  Text(
                    'Your Statistics',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: statTitleColor,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Overview container with all crucial stats
              SizedBox(height: 18),
              Row(children: [Expanded(child: StatsOverviewContainer())]),
              SizedBox(height: 18),
              // Button to open the challenge logbook
              ElevatedButton.icon(
                icon: Icon(Icons.history),
                label: Text('Challenge Logbook'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStatic.grape,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 6,
                  shadowColor: AppStatic.grape.withOpacity(0.18),
                ),
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => LogbookPage()));
                },
              ),
              SizedBox(height: 28),
              // Weekly XP chart container
              Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppStatic.marianBlue.withOpacity(0.08),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: FutureBuilder<List<int>>(
                  // XP as int, now uses logic class
                  future: logic.fetchWeeklyXp(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData ||
                        snapshot.data == null ||
                        snapshot.data!.length != 7) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final days = [
                      'Mon',
                      'Tue',
                      'Wed',
                      'Thu',
                      'Fri',
                      'Sat',
                      'Sun',
                    ];
                    final xpList = snapshot.data!;
                    return Column(
                      children: [
                        Text(
                          'Weekly XP Progress',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppStatic.marianBlue,
                          ),
                        ),
                        SizedBox(height: 15),
                        SizedBox(
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
                                        return Container();
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8.0,
                                        ),
                                        child: Text(
                                          days[idx],
                                          style: TextStyle(fontSize: 12),
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
                              maxY:
                                  (xpList.reduce((a, b) => a > b ? a : b) + 20)
                                      .toDouble(),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: [
                                    for (int i = 0; i < 7; i++)
                                      FlSpot(
                                        i.toDouble(),
                                        xpList[i].toDouble(),
                                      ),
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
              SizedBox(height: 30),
              // Weekly challenges chart container
              Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppStatic.marianBlue.withOpacity(0.08),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: FutureBuilder<List<List<int>>>(
                  future: logic.fetchWeeklyChallengeCounts(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData ||
                        snapshot.data == null ||
                        snapshot.data!.length != 2) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final days = [
                      'Mon',
                      'Tue',
                      'Wed',
                      'Thu',
                      'Fri',
                      'Sat',
                      'Sun',
                    ];
                    final completed = snapshot.data![0];
                    final failed = snapshot.data![1];
                    final maxY =
                        (([
                                  ...completed,
                                  ...failed,
                                ].reduce((a, b) => a > b ? a : b)) +
                                1)
                            .toDouble();
                    return Column(
                      children: [
                        Text(
                          'Weekly Challenges (completed/failed)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppStatic.marianBlue,
                          ),
                        ),
                        SizedBox(height: 15),
                        SizedBox(
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
                                        return Container();
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8.0,
                                        ),
                                        child: Text(
                                          days[idx],
                                          style: TextStyle(fontSize: 12),
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
                                  color: Colors.greenAccent,
                                  barWidth: 4,
                                  dotData: FlDotData(show: true),
                                ),
                                LineChartBarData(
                                  spots: [
                                    for (int i = 0; i < 7; i++)
                                      FlSpot(
                                        i.toDouble(),
                                        failed[i].toDouble(),
                                      ),
                                  ],
                                  isCurved: false,
                                  color: Colors.red,
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
              SizedBox(height: 30),
              // Debug database button
              DebugDbButton(),
            ],
          ),
        ),
      ),
    );
  }
}

// Container widget that displays all crucial user stats
class StatsOverviewContainer extends StatelessWidget {
  const StatsOverviewContainer({super.key});

  static final StatisticsLogic logic = StatisticsLogic();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey[900] : Colors.white;
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        logic.fetchTotalXp(),
        logic.fetchTodayXp(),
        logic.fetchCompletedAllTime(),
        logic.fetchCompletedToday(),
        logic.fetchCurrentStreak(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final totalXp = snapshot.data![0] as int;
        final todayXp = snapshot.data![1] as int;
        final completedAllTime = snapshot.data![2] as int;
        final completedToday = snapshot.data![3] as int;
        final streak = snapshot.data![4] as int;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
          decoration: BoxDecoration(
            color: cardColor, // Better contrast background
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppStatic.grape.withOpacity(0.10),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatTile(
                icon: Icons.stars,
                label: 'Total XP',
                value: totalXp.toString(),
                color: AppStatic.grape,
              ),
              _StatTile(
                icon: Icons.flash_on,
                label: 'XP Today',
                value: todayXp.toString(),
                color: AppStatic.marianBlue,
              ),
              _StatTile(
                icon: Icons.check_circle,
                label: 'Done',
                value: completedAllTime.toString(),
                color: Colors.green,
              ),
              _StatTile(
                icon: Icons.today,
                label: 'Today',
                value: completedToday.toString(),
                color: Colors.orange,
              ),
              _StatTile(
                icon: Icons.local_fire_department,
                label: 'Streak',
                value: streak.toString(),
                color: Colors.redAccent,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: color.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Debug button to print the logbook table from the database
class DebugDbButton extends StatefulWidget {
  const DebugDbButton({super.key});

  @override
  State<DebugDbButton> createState() => _DebugDbButtonState();
}

// State for DebugDbButton, handles DB output and loading state
class _DebugDbButtonState extends State<DebugDbButton> {
  String _output = '';
  bool _loading = false;

  // Prints the content of the logbook table to the UI
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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Button to trigger DB print
        ElevatedButton(
          onPressed: _loading ? null : _printDbContent,
          child: Text('DB Debug: Show all logbook table'),
        ),
        if (_loading)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (_output.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            constraints: BoxConstraints(maxHeight: 300),
            child: SingleChildScrollView(
              child: SelectableText(_output, style: TextStyle(fontSize: 12)),
            ),
          ),
      ],
    );
  }
}
