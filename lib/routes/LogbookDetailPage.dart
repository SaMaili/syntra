import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

import '../generated/l10n.dart';
import '../static.dart';

class LogbookDetailPage extends StatefulWidget {
  final Map<String, dynamic> entry;

  const LogbookDetailPage({super.key, required this.entry});

  @override
  State<LogbookDetailPage> createState() => _LogbookDetailPageState();
}

class _LogbookDetailPageState extends State<LogbookDetailPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _staggerController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late List<Animation<double>> _staggerAnimations;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Define animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Create stagger animations for each section
    _staggerAnimations = List.generate(5, (index) {
      final begin = index * 0.15;
      final end = (begin + 0.3).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(begin, end, curve: Curves.easeInOut),
        ),
      );
    });

    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    _staggerController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  Future<String> _getChallengeTitle(
    BuildContext context,
    String challengeId,
  ) async {
    final dbPath = await getDatabasesPath();
    final dbFilePath = path.join(dbPath, 'challenge_database.db');
    final db = await openDatabase(dbFilePath);

    // Get current locale
    final locale = Localizations.localeOf(context).languageCode;

    final result = await db.rawQuery(
      '''SELECT ct.title 
         FROM challenges c 
         LEFT JOIN challenge_translations ct ON c.id = ct.challenge_id 
         WHERE c.id = ? AND (ct.language_code = ? OR ct.language_code = 'en')
         ORDER BY CASE WHEN ct.language_code = ? THEN 0 ELSE 1 END
         LIMIT 1''',
      [challengeId, locale, locale],
    );
    if (result.isNotEmpty) {
      return result.first['title']?.toString() ?? 'Unknown';
    }
    return 'Unknown';
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
              Icon(Icons.bookmark, color: titleColor, size: 24),
              SizedBox(width: 8),
              Text(
                S.of(context).logbookEntry,
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
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: FutureBuilder<String>(
                          future: _getChallengeTitle(
                            context,
                            widget.entry['challenge_id']?.toString() ?? '',
                          ),
                          builder: (context, snapshot) {
                            final challengeTitle = snapshot.data ?? '';
                            final isCustom = widget.entry['status'] == 'custom';
                            final displayTitle = isCustom && widget.entry['custom_title'] != null
                                ? widget.entry['custom_title']
                                : challengeTitle;

                            return SingleChildScrollView(
                              child: Column(
                                children: [
                                  SizedBox(height: 20),

                                  // Hero Header with Trophy
                                  AnimatedBuilder(
                                    animation: _staggerAnimations[0],
                                    builder: (context, child) {
                                      return Transform.translate(
                                        offset: Offset(0, 50 * (1 - _staggerAnimations[0].value)),
                                        child: Opacity(
                                          opacity: _staggerAnimations[0].value,
                                          child: Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.all(32),
                                            decoration: BoxDecoration(
                                              color: cardColor,
                                              borderRadius: BorderRadius.circular(28),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: titleColor.withValues(alpha: 0.3),
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
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(20),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Colors.amber.withValues(alpha: 0.2),
                                                        Colors.orange.withValues(alpha: 0.1),
                                                      ],
                                                    ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.emoji_events,
                                                    color: Colors.amber[700],
                                                    size: 64,
                                                  ),
                                                ),
                                                SizedBox(height: 20),
                                                Text(
                                                  displayTitle,
                                                  style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                    color: titleColor,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                SizedBox(height: 8),
                                                Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                  decoration: BoxDecoration(
                                                    color: _getStatusColor(widget.entry['earned']).withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.star,
                                                        color: _getStatusColor(widget.entry['earned']),
                                                        size: 20,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        '${(widget.entry['earned'] ?? 0) >= 0 ? '+' : ''}${widget.entry['earned'] ?? 0} XP',
                                                        style: TextStyle(
                                                          color: _getStatusColor(widget.entry['earned']),
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      );
                                    },
                                  ),

                                  SizedBox(height: 24),

                                  // Details Card
                                  AnimatedBuilder(
                                    animation: _staggerAnimations[1],
                                    builder: (context, child) {
                                      return Transform.translate(
                                        offset: Offset(0, 50 * (1 - _staggerAnimations[1].value)),
                                        child: Opacity(
                                          opacity: _staggerAnimations[1].value,
                                          child: _buildDetailsCard(cardColor, accentColor, isDark),
                                        ),
                                      );
                                    },
                                  ),

                                  SizedBox(height: 24),

                                  // Feelings Card
                                  AnimatedBuilder(
                                    animation: _staggerAnimations[2],
                                    builder: (context, child) {
                                      return Transform.translate(
                                        offset: Offset(0, 50 * (1 - _staggerAnimations[2].value)),
                                        child: Opacity(
                                          opacity: _staggerAnimations[2].value,
                                          child: _buildFeelingsCard(cardColor, titleColor, isDark),
                                        ),
                                      );
                                    },
                                  ),

                                  if (widget.entry['notes'] != null && widget.entry['notes'].toString().isNotEmpty) ...[
                                    SizedBox(height: 24),
                                    AnimatedBuilder(
                                      animation: _staggerAnimations[3],
                                      builder: (context, child) {
                                        return Transform.translate(
                                          offset: Offset(0, 50 * (1 - _staggerAnimations[3].value)),
                                          child: Opacity(
                                            opacity: _staggerAnimations[3].value,
                                            child: _buildNotesCard(cardColor, accentColor, isDark),
                                          ),
                                        );
                                      },
                                    ),
                                  ],

                                  SizedBox(height: 32),

                                  // Delete Button
                                  AnimatedBuilder(
                                    animation: _staggerAnimations[4],
                                    builder: (context, child) {
                                      return Transform.translate(
                                        offset: Offset(0, 50 * (1 - _staggerAnimations[4].value)),
                                        child: Opacity(
                                          opacity: _staggerAnimations[4].value,
                                          child: _buildDeleteButton(isDark),
                                        ),
                                      );
                                    },
                                  ),

                                  SizedBox(height: 20),
                                ],
                              ),
                            );
                          },
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

  Widget _buildDetailsCard(Color cardColor, Color accentColor, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.2),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, color: accentColor, size: 28),
              SizedBox(width: 12),
              Text(
                'Details',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          _buildDetailRow(
            Icons.calendar_today,
            'Date',
            _formatDate(widget.entry['timestamp']?.toString()),
            accentColor,
            isDark,
          ),
          _buildDetailRow(
            Icons.info,
            'Status',
            _capitalizeFirst(widget.entry['status']?.toString() ?? 'Unknown'),
            accentColor,
            isDark,
          ),
          if (widget.entry['reward_factor'] != null)
            _buildDetailRow(
              Icons.trending_up,
              'Reward Factor',
              '${(widget.entry['reward_factor'] * 100).toInt()}%',
              accentColor,
              isDark,
            ),
        ],
      ),
    );
  }

  Widget _buildFeelingsCard(Color cardColor, Color titleColor, bool isDark) {
    return Container(
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite, color: titleColor, size: 28),
              SizedBox(width: 12),
              Text(
                'Feelings',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          _buildFeelingRow(
            'How did you feel?',
            widget.entry['feeling'],
            titleColor,
            isDark,
          ),
          _buildFeelingRow(
            'How were you perceived?',
            widget.entry['perception'],
            titleColor,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(Color cardColor, Color accentColor, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.2),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.note_alt, color: accentColor, size: 28),
              SizedBox(width: 12),
              Text(
                'Notes',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              widget.entry['notes']?.toString() ?? '',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.red.withValues(alpha: 0.8),
            Colors.red.shade700.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 1,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        icon: Icon(Icons.delete, size: 24, color: Colors.white),
        label: Text(
          'Delete Entry',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () => _showDeleteDialog(),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color accentColor, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeelingRow(String label, dynamic value, Color titleColor, bool isDark) {
    final feeling = value as int?;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _emotionColor(feeling).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _emotionIcon(feeling),
              color: _emotionColor(feeling),
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _emotionText(feeling),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _emotionColor(feeling),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Entry'),
        content: Text('Are you sure you want to delete this logbook entry? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _deleteEntry(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEntry() async {
    try {
      final dbPath = await getDatabasesPath();
      final dbFilePath = path.join(dbPath, 'challenge_database.db');
      final db = await openDatabase(dbFilePath);

      await db.delete(
        'logbook',
        where: 'id = ?',
        whereArgs: [widget.entry['id']],
      );

      if (mounted) {
        Navigator.of(context).pop(); // Close dialog
        Navigator.of(context).pop(true); // Return to logbook with deleted flag
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting entry: $e')),
        );
      }
    }
  }

  // Helper methods
  String _formatDate(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return 'Unknown';
    try {
      final dt = DateTime.parse(timestamp);
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return timestamp;
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Color _getStatusColor(dynamic earned) {
    final xp = earned as int? ?? 0;
    if (xp > 0) return Colors.green;
    if (xp < 0) return Colors.red;
    return Colors.amber;
  }

  IconData _emotionIcon(int? feeling) {
    switch (feeling) {
      case 0: return Icons.sentiment_very_dissatisfied;
      case 1: return Icons.sentiment_dissatisfied;
      case 2: return Icons.sentiment_neutral;
      case 3: return Icons.sentiment_satisfied;
      case 4: return Icons.sentiment_very_satisfied;
      default: return Icons.sentiment_neutral;
    }
  }

  Color _emotionColor(int? feeling) {
    switch (feeling) {
      case 0: return Colors.red;
      case 1: return Colors.orange;
      case 2: return Colors.amber;
      case 3: return Colors.lightGreen;
      case 4: return Colors.green;
      default: return Colors.grey;
    }
  }

  String _emotionText(int? feeling) {
    switch (feeling) {
      case 0: return 'Very Bad';
      case 1: return 'Bad';
      case 2: return 'Neutral';
      case 3: return 'Good';
      case 4: return 'Very Good';
      default: return 'Unknown';
    }
  }
}
