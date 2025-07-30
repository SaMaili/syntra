// StatisticsScreen.dart
// This file defines the StatisticsScreen and StatsOverviewContainer widgets for displaying user statistics in the Syntra app.
// It includes logic for fetching and displaying XP, completed quests, and streaks, as well as a debug button for database inspection.

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../generated/l10n.dart';
import '../logic/StatisticsLogic.dart';
import '../static.dart';
import 'LogbookPage.dart';

// Main statistics screen widget
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with TickerProviderStateMixin {
  // Logic class instance for all data fetching
  static final StatisticsLogic logic = StatisticsLogic();

  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start animations when screen loads
    _fadeController.forward();
    _scaleController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgGradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFFe0c3fc), Color(0xFF8ec5fc), Color(0xFF74b9ff)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
    final cardColor = isDark
        ? Colors.grey[900]!.withValues(alpha: 0.95)
        : Colors.white.withValues(alpha: 0.95);
    final titleColor = isDark ? Colors.pinkAccent : AppStatic.grape;
    final statTitleColor = isDark ? Colors.pinkAccent : AppStatic.marianBlue;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: isDark ? 0.1 : 0.2),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bar_chart, color: titleColor, size: 24),
              SizedBox(width: 8),
              Text(
                S.of(context).yourStatistics,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: isDark ? Colors.black : AppStatic.grapeLight,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Overview container with all crucial stats
                              AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _pulseAnimation.value,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(28),
                                        boxShadow: [
                                          BoxShadow(
                                            color: titleColor.withValues(
                                              alpha: 0.2,
                                            ),
                                            blurRadius: 25,
                                            spreadRadius: 2,
                                            offset: Offset(0, 12),
                                          ),
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.1,
                                            ),
                                            blurRadius: 15,
                                            offset: Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: StatsOverviewContainer(
                                        cardColor: cardColor,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 28),
                              // Button to open the challenge logbook
                              Container(
                                width: double.infinity,
                                height: 65,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    colors: [
                                      titleColor,
                                      titleColor.withValues(alpha: 0.8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: titleColor.withValues(alpha: 0.4),
                                      blurRadius: 20,
                                      spreadRadius: 1,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  icon: Icon(
                                    Icons.history,
                                    size: 28,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    S.of(context).challengeLogbook,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => LogbookPage(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 28),
                              // Weekly XP chart container
                              Container(
                                padding: EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: statTitleColor.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 25,
                                      spreadRadius: 2,
                                      offset: Offset(0, 12),
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 15,
                                      offset: Offset(0, 8),
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
                                      return Center(
                                        child: Container(
                                          padding: EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: 0.9,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.1,
                                                ),
                                                blurRadius: 20,
                                                offset: Offset(0, 10),
                                              ),
                                            ],
                                          ),
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  statTitleColor,
                                                ),
                                            strokeWidth: 3,
                                          ),
                                        ),
                                      );
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
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.trending_up,
                                              color: statTitleColor,
                                              size: 24,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              S.of(context).weeklyXpProgress,
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: statTitleColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 20),
                                        SizedBox(
                                          height: 200,
                                          child: LineChart(
                                            LineChartData(
                                              gridData: FlGridData(
                                                show: true,
                                                drawVerticalLine: true,
                                                horizontalInterval: 1,
                                                verticalInterval: 1,
                                                getDrawingHorizontalLine:
                                                    (value) {
                                                      return FlLine(
                                                        color: Colors.grey
                                                            .withValues(
                                                              alpha: 0.2,
                                                            ),
                                                        strokeWidth: 1,
                                                      );
                                                    },
                                                getDrawingVerticalLine:
                                                    (value) {
                                                      return FlLine(
                                                        color: Colors.grey
                                                            .withValues(
                                                              alpha: 0.2,
                                                            ),
                                                        strokeWidth: 1,
                                                      );
                                                    },
                                              ),
                                              titlesData: FlTitlesData(
                                                leftTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles: true,
                                                    reservedSize: 40,
                                                    getTitlesWidget:
                                                        (value, meta) {
                                                          return Text(
                                                            value
                                                                .toInt()
                                                                .toString(),
                                                            style: TextStyle(
                                                              color: isDark
                                                                  ? Colors
                                                                        .white70
                                                                  : Colors
                                                                        .black87,
                                                              fontSize: 12,
                                                            ),
                                                          );
                                                        },
                                                  ),
                                                ),
                                                bottomTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles: true,
                                                    getTitlesWidget: (value, meta) {
                                                      int idx = value.toInt();
                                                      if (idx < 0 || idx > 6) {
                                                        return Container();
                                                      }
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 8.0,
                                                            ),
                                                        child: Text(
                                                          days[idx],
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: isDark
                                                                ? Colors.white70
                                                                : Colors
                                                                      .black87,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    interval: 1,
                                                  ),
                                                ),
                                                rightTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles: false,
                                                  ),
                                                ),
                                                topTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles: false,
                                                  ),
                                                ),
                                              ),
                                              borderData: FlBorderData(
                                                show: true,
                                                border: Border.all(
                                                  color: Colors.grey.withValues(
                                                    alpha: 0.3,
                                                  ),
                                                  width: 1,
                                                ),
                                              ),
                                              minX: 0,
                                              maxX: 6,
                                              maxY:
                                                  (xpList.reduce(
                                                            (a, b) =>
                                                                a > b ? a : b,
                                                          ) +
                                                          20)
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
                                                  isCurved: true,
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      statTitleColor,
                                                      statTitleColor.withValues(
                                                        alpha: 0.7,
                                                      ),
                                                    ],
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                  ),
                                                  barWidth: 4,
                                                  isStrokeCapRound: true,
                                                  dotData: FlDotData(
                                                    show: true,
                                                    getDotPainter:
                                                        (
                                                          spot,
                                                          percent,
                                                          barData,
                                                          index,
                                                        ) {
                                                          return FlDotCirclePainter(
                                                            radius: 6,
                                                            color: Colors.white,
                                                            strokeWidth: 3,
                                                            strokeColor:
                                                                statTitleColor,
                                                          );
                                                        },
                                                  ),
                                                  belowBarData: BarAreaData(
                                                    show: true,
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        statTitleColor
                                                            .withValues(
                                                              alpha: 0.3,
                                                            ),
                                                        statTitleColor
                                                            .withValues(
                                                              alpha: 0.1,
                                                            ),
                                                      ],
                                                      begin:
                                                          Alignment.topCenter,
                                                      end: Alignment
                                                          .bottomCenter,
                                                    ),
                                                  ),
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
                              SizedBox(height: 28),
                              // Weekly challenges chart container
                              Container(
                                padding: EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: statTitleColor.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 25,
                                      spreadRadius: 2,
                                      offset: Offset(0, 12),
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 15,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: FutureBuilder<List<List<int>>>(
                                  future: logic.fetchWeeklyChallengeCounts(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData ||
                                        snapshot.data == null ||
                                        snapshot.data!.length != 2) {
                                      return Center(
                                        child: Container(
                                          padding: EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: 0.9,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.1,
                                                ),
                                                blurRadius: 20,
                                                offset: Offset(0, 10),
                                              ),
                                            ],
                                          ),
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  statTitleColor,
                                                ),
                                            strokeWidth: 3,
                                          ),
                                        ),
                                      );
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
                                        (([...completed, ...failed].reduce(
                                                  (a, b) => a > b ? a : b,
                                                )) +
                                                1)
                                            .toDouble();
                                    return Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.assessment,
                                              color: statTitleColor,
                                              size: 24,
                                            ),
                                            SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                S.of(context).weeklyChallenges,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: statTitleColor,
                                                ),
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 12),
                                        Wrap(
                                          alignment: WrapAlignment.center,
                                          spacing: 12,
                                          runSpacing: 8,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.greenAccent
                                                    .withValues(alpha: 0.2),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: 12,
                                                    height: 12,
                                                    decoration: BoxDecoration(
                                                      color: Colors.greenAccent,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  SizedBox(width: 6),
                                                  Text(
                                                    S.of(context).completed,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: isDark
                                                          ? Colors.white70
                                                          : Colors.black87,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.red.withValues(
                                                  alpha: 0.2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: 12,
                                                    height: 12,
                                                    decoration: BoxDecoration(
                                                      color: Colors.red,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  SizedBox(width: 6),
                                                  Text(
                                                    S.of(context).failed,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: isDark
                                                          ? Colors.white70
                                                          : Colors.black87,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 20),
                                        SizedBox(
                                          height: 200,
                                          child: LineChart(
                                            LineChartData(
                                              gridData: FlGridData(
                                                show: true,
                                                drawVerticalLine: true,
                                                horizontalInterval: 1,
                                                verticalInterval: 1,
                                                getDrawingHorizontalLine:
                                                    (value) {
                                                      return FlLine(
                                                        color: Colors.grey
                                                            .withValues(
                                                              alpha: 0.2,
                                                            ),
                                                        strokeWidth: 1,
                                                      );
                                                    },
                                                getDrawingVerticalLine:
                                                    (value) {
                                                      return FlLine(
                                                        color: Colors.grey
                                                            .withValues(
                                                              alpha: 0.2,
                                                            ),
                                                        strokeWidth: 1,
                                                      );
                                                    },
                                              ),
                                              titlesData: FlTitlesData(
                                                leftTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles: true,
                                                    reservedSize: 40,
                                                    getTitlesWidget:
                                                        (value, meta) {
                                                          return Text(
                                                            value
                                                                .toInt()
                                                                .toString(),
                                                            style: TextStyle(
                                                              color: isDark
                                                                  ? Colors
                                                                        .white70
                                                                  : Colors
                                                                        .black87,
                                                              fontSize: 12,
                                                            ),
                                                          );
                                                        },
                                                  ),
                                                ),
                                                bottomTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles: true,
                                                    getTitlesWidget: (value, meta) {
                                                      int idx = value.toInt();
                                                      if (idx < 0 || idx > 6) {
                                                        return Container();
                                                      }
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 8.0,
                                                            ),
                                                        child: Text(
                                                          days[idx],
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: isDark
                                                                ? Colors.white70
                                                                : Colors
                                                                      .black87,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    interval: 1,
                                                  ),
                                                ),
                                                rightTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles: false,
                                                  ),
                                                ),
                                                topTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles: false,
                                                  ),
                                                ),
                                              ),
                                              borderData: FlBorderData(
                                                show: true,
                                                border: Border.all(
                                                  color: Colors.grey.withValues(
                                                    alpha: 0.3,
                                                  ),
                                                  width: 1,
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
                                                  isCurved: true,
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.greenAccent,
                                                      Colors.green.withValues(
                                                        alpha: 0.7,
                                                      ),
                                                    ],
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                  ),
                                                  barWidth: 4,
                                                  isStrokeCapRound: true,
                                                  dotData: FlDotData(
                                                    show: true,
                                                    getDotPainter:
                                                        (
                                                          spot,
                                                          percent,
                                                          barData,
                                                          index,
                                                        ) {
                                                          return FlDotCirclePainter(
                                                            radius: 6,
                                                            color: Colors.white,
                                                            strokeWidth: 3,
                                                            strokeColor: Colors
                                                                .greenAccent,
                                                          );
                                                        },
                                                  ),
                                                  belowBarData: BarAreaData(
                                                    show: true,
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Colors.greenAccent
                                                            .withValues(
                                                              alpha: 0.3,
                                                            ),
                                                        Colors.greenAccent
                                                            .withValues(
                                                              alpha: 0.1,
                                                            ),
                                                      ],
                                                      begin:
                                                          Alignment.topCenter,
                                                      end: Alignment
                                                          .bottomCenter,
                                                    ),
                                                  ),
                                                ),
                                                LineChartBarData(
                                                  spots: [
                                                    for (int i = 0; i < 7; i++)
                                                      FlSpot(
                                                        i.toDouble(),
                                                        failed[i].toDouble(),
                                                      ),
                                                  ],
                                                  isCurved: true,
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.red,
                                                      Colors.redAccent
                                                          .withValues(
                                                            alpha: 0.7,
                                                          ),
                                                    ],
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                  ),
                                                  barWidth: 4,
                                                  isStrokeCapRound: true,
                                                  dotData: FlDotData(
                                                    show: true,
                                                    getDotPainter:
                                                        (
                                                          spot,
                                                          percent,
                                                          barData,
                                                          index,
                                                        ) {
                                                          return FlDotCirclePainter(
                                                            radius: 6,
                                                            color: Colors.white,
                                                            strokeWidth: 3,
                                                            strokeColor:
                                                                Colors.red,
                                                          );
                                                        },
                                                  ),
                                                  belowBarData: BarAreaData(
                                                    show: true,
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Colors.red.withValues(
                                                          alpha: 0.3,
                                                        ),
                                                        Colors.red.withValues(
                                                          alpha: 0.1,
                                                        ),
                                                      ],
                                                      begin:
                                                          Alignment.topCenter,
                                                      end: Alignment
                                                          .bottomCenter,
                                                    ),
                                                  ),
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
                              DebugDbButton(
                                cardColor: cardColor,
                                titleColor: titleColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Container widget that displays all crucial user stats
class StatsOverviewContainer extends StatelessWidget {
  final Color cardColor;

  const StatsOverviewContainer({super.key, required this.cardColor});

  static final StatisticsLogic logic = StatisticsLogic();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([logic.fetchAllOverviewStats()]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            height: 120,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppStatic.grape),
                  strokeWidth: 3,
                ),
              ),
            ),
          );
        }
        final stats = snapshot.data![0] as Map<String, int>;
        final totalXp = stats['totalXp']!;
        final todayXp = stats['todayXp']!;
        final completedAllTime = stats['completedAllTime']!;
        final completedToday = stats['completedToday']!;
        final streak = stats['streak']!;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatTile(
                icon: Icons.stars,
                label: S.of(context).total,
                value: totalXp.toString(),
                color: AppStatic.grape,
              ),
              _StatTile(
                icon: Icons.flash_on,
                label: S.of(context).today,
                value: todayXp.toString(),
                color: AppStatic.marianBlue,
              ),
              _StatTile(
                icon: Icons.check_circle,
                label: S.of(context).done,
                value: completedAllTime.toString(),
                color: Colors.green,
              ),
              _StatTile(
                icon: Icons.today,
                label: S.of(context).today,
                value: completedToday.toString(),
                color: Colors.orange,
              ),
              _StatTile(
                icon: Icons.local_fire_department,
                label: S.of(context).streak,
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.2),
                color.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: color.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Debug button to print the logbook table from the database
class DebugDbButton extends StatefulWidget {
  final Color cardColor;
  final Color titleColor;

  const DebugDbButton({
    super.key,
    required this.cardColor,
    required this.titleColor,
  });

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
    await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: widget.titleColor.withValues(alpha: 0.2),
            blurRadius: 25,
            spreadRadius: 2,
            offset: Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bug_report, color: widget.titleColor, size: 24),
              SizedBox(width: 8),
              Text(
                'Debug Database',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: widget.titleColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Button to trigger DB print
          Container(
            height: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  widget.titleColor,
                  widget.titleColor.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.titleColor.withValues(alpha: 0.4),
                  blurRadius: 15,
                  spreadRadius: 1,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _loading ? null : _printDbContent,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: _loading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      S.of(context).dbDebugShow,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          if (_output.isNotEmpty) ...[
            SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.titleColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              constraints: BoxConstraints(maxHeight: 300),
              child: SingleChildScrollView(
                child: SelectableText(
                  _output,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
