import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../generated/l10n.dart';
import '../static.dart';
import 'AddChallengeScreen.dart';
import 'LogbookDetailPage.dart';

class LogbookPage extends StatefulWidget {
  const LogbookPage({super.key});

  @override
  State<LogbookPage> createState() => _LogbookPageState();
}

class _LogbookPageState extends State<LogbookPage>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _entries = [];
  bool _loading = true;
  Map<String, String> _challengeTitles = {};
  static const int _pageSize = 50;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  // Animation controllers for beautiful UI
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _listController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadEntries();

    // Initialize animation controllers
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Define animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    _listController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _listController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries({bool append = false}) async {
    if (_isLoadingMore) return;
    setState(() {
      if (!append) _loading = true;
      _isLoadingMore = append;
    });
    final dbPath = await getDatabasesPath();
    final dbFilePath = path.join(dbPath, 'challenge_database.db');
    final db = await openDatabase(dbFilePath);

    // Check if custom_title column exists before adding it
    final tableInfo = await db.rawQuery("PRAGMA table_info(logbook)");
    final hasCustomTitle = tableInfo.any((column) => column['name'] == 'custom_title');

    if (!hasCustomTitle) {
      try {
        await db.execute("ALTER TABLE logbook ADD COLUMN custom_title TEXT");
      } catch (e) {
        // Column might already exist, ignore error
        print('Info: custom_title column already exists or could not be added: $e');
      }
    }

    final offset = append ? _entries.length : 0;
    final result = await db.rawQuery(
      'SELECT * FROM logbook ORDER BY timestamp DESC LIMIT $_pageSize OFFSET $offset',
    );
    // Load all challenge titles
    if (_challengeTitles.isEmpty) {
      // Get current locale
      final locale = Localizations.localeOf(context).languageCode;
      final challengeRows = await db.rawQuery(
        '''SELECT c.id, ct.title 
           FROM challenges c 
           LEFT JOIN challenge_translations ct ON c.id = ct.challenge_id 
           WHERE ct.language_code = ? OR ct.language_code = 'en'
           GROUP BY c.id
           ORDER BY CASE WHEN ct.language_code = ? THEN 0 ELSE 1 END''',
        [locale, locale],
      );
      _challengeTitles = {
        for (final row in challengeRows)
          row['id'].toString(): row['title']?.toString() ?? 'Unknown',
      };
    }
    setState(() {
      if (append) {
        _entries = List<Map<String, dynamic>>.from(_entries)
          ..addAll(List<Map<String, dynamic>>.from(result));
      } else {
        _entries = List<Map<String, dynamic>>.from(result);
      }
      _hasMore = result.length == _pageSize;
      _loading = false;
      _isLoadingMore = false;
    });
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return '-';
    try {
      final dt = DateTime.parse(timestamp);
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Beautiful gradient backgrounds
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
    final accentColor = isDark ? Colors.cyanAccent : AppStatic.marianBlue;

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
              Icon(Icons.book, color: titleColor, size: 24),
              SizedBox(width: 8),
              Text(
                S.of(context).logbook,
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
                      child: _loading
                          ? Center(
                              child: Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: titleColor.withValues(alpha: 0.2),
                                      blurRadius: 20,
                                      offset: Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          titleColor),
                                      strokeWidth: 3,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Loading logbook...',
                                      style: TextStyle(
                                        color: titleColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : _entries.isEmpty
                              ? _buildEmptyState(cardColor, titleColor, isDark)
                              : NotificationListener<ScrollNotification>(
                                  onNotification: (scrollInfo) {
                                    if (_hasMore &&
                                        !_isLoadingMore &&
                                        scrollInfo.metrics.pixels >=
                                            scrollInfo.metrics.maxScrollExtent - 200) {
                                      _loadEntries(append: true);
                                    }
                                    return false;
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      children: [
                                        SizedBox(height: 20),

                                        // Stats Header
                                        Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.all(24),
                                          decoration: BoxDecoration(
                                            color: cardColor,
                                            borderRadius: BorderRadius.circular(28),
                                            boxShadow: [
                                              BoxShadow(
                                                color: titleColor.withValues(alpha: 0.2),
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
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              _buildStatItem(
                                                Icons.assignment,
                                                'Total Entries',
                                                '${_entries.length}',
                                                titleColor,
                                                isDark,
                                              ),
                                              Container(
                                                width: 1,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.transparent,
                                                      titleColor.withValues(alpha: 0.3),
                                                      Colors.transparent,
                                                    ],
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                  ),
                                                ),
                                              ),
                                              _buildStatItem(
                                                Icons.star,
                                                'Total XP',
                                                '${_entries.fold<int>(0, (sum, entry) => sum + (entry['earned'] as int? ?? 0))}',
                                                accentColor,
                                                isDark,
                                              ),
                                            ],
                                          ),
                                        ),

                                        SizedBox(height: 24),

                                        // Entries List
                                        Expanded(
                                          child: AnimatedList(
                                            initialItemCount: _entries.length + (_hasMore ? 1 : 0),
                                            itemBuilder: (context, index, animation) {
                                              if (index >= _entries.length) {
                                                return _buildLoadingItem(cardColor, titleColor);
                                              }

                                              return SlideTransition(
                                                position: animation.drive(
                                                  Tween(begin: Offset(1, 0), end: Offset.zero).chain(
                                                    CurveTween(curve: Curves.easeOutCubic),
                                                  ),
                                                ),
                                                child: FadeTransition(
                                                  opacity: animation,
                                                  child: Padding(
                                                    padding: EdgeInsets.only(bottom: 16),
                                                    child: _buildLogbookEntry(index, cardColor, accentColor, isDark),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
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
      floatingActionButton: Container(
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
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Icon(Icons.add, color: Colors.white, size: 28),
          tooltip: S.of(context).addCustomChallenge,
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => AddChallengeScreen()),
            );
            _loadEntries();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color cardColor, Color titleColor, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Container(
          padding: EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: titleColor.withValues(alpha: 0.2),
                blurRadius: 25,
                spreadRadius: 2,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: titleColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.book_outlined,
                  size: 64,
                  color: titleColor,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'No Entries Yet',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Complete some challenges to see them here!',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color, bool isDark) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLogbookEntry(int index, Color cardColor, Color accentColor, bool isDark) {
    final entry = _entries[index];
    final isCustom = entry['status'] == 'custom';
    final displayTitle = isCustom && entry['custom_title'] != null
        ? entry['custom_title']
        : (_challengeTitles[entry['challenge_id']?.toString()] ?? 'Unknown');

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.1),
            blurRadius: 15,
            spreadRadius: 1,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            final deleted = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => LogbookDetailPage(entry: entry),
              ),
            );
            if (deleted == true) _loadEntries();
          },
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                // Entry Number Badge
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        accentColor.withValues(alpha: 0.8),
                        accentColor.withValues(alpha: 0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 16),

                // Challenge Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6),
                      Text(
                        _formatTimestamp(entry['timestamp']?.toString()),
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 16),

                // XP and Emotion
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getXPColor(entry['earned']).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${(entry['earned'] ?? 0) >= 0 ? '+' : ''}${entry['earned'] ?? 0}',
                        style: TextStyle(
                          color: _getXPColor(entry['earned']),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _emotionColor(entry['feeling'] as int?).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _emotionIcon(entry['feeling'] as int?),
                        color: _emotionColor(entry['feeling'] as int?),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingItem(Color cardColor, Color titleColor) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(titleColor),
            strokeWidth: 2,
          ),
          SizedBox(width: 16),
          Text(
            'Loading more entries...',
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getXPColor(dynamic earned) {
    final xp = earned as int? ?? 0;
    if (xp > 0) return Colors.green;
    if (xp < 0) return Colors.red;
    return Colors.amber;
  }

  IconData _emotionIcon(int? feeling) {
    switch (feeling) {
      case 0:
        return Icons.sentiment_very_dissatisfied;
      case 1:
        return Icons.sentiment_dissatisfied;
      case 2:
        return Icons.sentiment_neutral;
      case 3:
        return Icons.sentiment_satisfied;
      case 4:
        return Icons.sentiment_very_satisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  Color _emotionColor(int? feeling) {
    switch (feeling) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.amber;
      case 3:
        return Colors.lightGreen;
      case 4:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
