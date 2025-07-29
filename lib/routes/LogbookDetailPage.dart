import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../generated/l10n.dart';

class LogbookDetailPage extends StatelessWidget {
  final Map<String, dynamic> entry;

  const LogbookDetailPage({super.key, required this.entry});

  Future<String> _getChallengeTitle(
    BuildContext context,
    String challengeId,
  ) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'challenge_database.db');
    final db = await openDatabase(path);
    
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
    final bgColor = isDark ? Colors.black : Colors.grey[100];
    final cardColor = isDark ? Colors.grey[900] : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.grey[400] : Colors.black87;
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).logbookEntry)),
      backgroundColor: bgColor,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<String>(
          future: _getChallengeTitle(
            context,
            entry['challenge_id']?.toString() ?? '',
          ),
          builder: (context, snapshot) {
            final challengeTitle = snapshot.data ?? '';
            return SingleChildScrollView(
              child: Card(
                elevation: 4,
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Icon(
                          Icons.emoji_events,
                          color: Colors.amber[700],
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _detailRow(
                        S.of(context).challenge,
                        challengeTitle,
                        icon: Icons.flag,
                        textColor: textColor,
                        context: context,
                      ),
                      _detailRow(
                        S.of(context).date,
                        _formatDate(entry['timestamp']?.toString()),
                        icon: Icons.calendar_today,
                        textColor: textColor,
                        context: context,
                      ),
                      _detailRow(
                        S.of(context).xp,
                        entry['earned']?.toString(),
                        icon: Icons.star,
                        textColor: textColor,
                        context: context,
                      ),
                      _detailRow(
                        S.of(context).status,
                        entry['status']?.toString(),
                        icon: Icons.info,
                        textColor: textColor,
                        context: context,
                      ),
                      _detailRow(
                        S.of(context).feeling,
                        entry['feeling']?.toString(),
                        icon: Icons.mood,
                        textColor: textColor,
                        context: context,
                      ),
                      _detailRow(
                        S.of(context).perception,
                        entry['perception']?.toString(),
                        icon: Icons.visibility,
                        textColor: textColor,
                        context: context,
                      ),
                      _detailRow(
                        S.of(context).challengeId,
                        entry['challenge_id']?.toString() ?? '-',
                        icon: Icons.confirmation_number,
                        textColor: textColor,
                        context: context,
                      ),
                      if ((entry['notes']?.toString() ?? '').isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 24, bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.blueGrey[900]
                                : Colors.blue[50],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.blueAccent.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('📝', style: TextStyle(fontSize: 22)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  entry['notes'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.delete, color: Colors.white),
          label: Text(
            S.of(context).deleteEntry,
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(S.of(context).deleteEntry),
                content: Text(S.of(context).deleteEntryQuestion),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text(S.of(context).cancel),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: Text(
                      S.of(context).delete,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              final dbPath = await getDatabasesPath();
              final path = join(dbPath, 'challenge_database.db');
              final db = await openDatabase(path);
              await db.delete(
                'logbook',
                where: 'id = ?',
                whereArgs: [entry['id']],
              );
              Navigator.of(context).pop(true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(S.of(context).entryDeleted),
                  duration: Duration(milliseconds: 800),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  String _formatDate(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return '-';
    try {
      final dt = DateTime.parse(timestamp);
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    } catch (_) {
      return timestamp;
    }
  }

  Widget _detailRow(
    String label,
    String? value, {
    IconData? icon,
    Color? textColor,
    required BuildContext context,
  }) {
    // Special case for Feeling: show emoji + name
    if (label == S.of(context).feeling) {
      final int? feelingValue = int.tryParse(value ?? '');
      final iconData = _emotionIcon(feelingValue);
      final feelingName = _feelingName(feelingValue, context);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(iconData, size: 24, color: _emotionColor(feelingValue)),
            const SizedBox(width: 8),
            Text(
              '$label: ',
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
            Text(feelingName, style: TextStyle(color: textColor)),
          ],
        ),
      );
    }
    // Special case for Perception: show emoji + name
    if (label == S.of(context).perception) {
      final int? perceptionValue = int.tryParse(value ?? '');
      final iconData = _emotionIcon(perceptionValue);
      final perceptionName = _perceptionName(perceptionValue, context);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(iconData, size: 24, color: _emotionColor(perceptionValue)),
            const SizedBox(width: 8),
            Text(
              '$label: ',
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
            Text(perceptionName, style: TextStyle(color: textColor)),
          ],
        ),
      );
    }
    // Default case
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Colors.blueGrey),
            const SizedBox(width: 8),
          ],
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
          ),
          Expanded(
            child: Text(value ?? '-', style: TextStyle(color: textColor)),
          ),
        ],
      ),
    );
  }

  IconData _emotionIcon(int? value) {
    switch (value) {
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

  Color _emotionColor(int? value) {
    switch (value) {
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

  String _feelingName(int? value, BuildContext context) {
    switch (value) {
      case 0:
        return S.of(context).veryBad;
      case 1:
        return S.of(context).bad;
      case 2:
        return S.of(context).neutral;
      case 3:
        return S.of(context).good;
      case 4:
        return S.of(context).veryGood;
      default:
        return '-';
    }
  }

  String _perceptionName(int? value, BuildContext context) {
    switch (value) {
      case 0:
        return S.of(context).veryNegative;
      case 1:
        return S.of(context).negative;
      case 2:
        return S.of(context).neutral;
      case 3:
        return S.of(context).positive;
      case 4:
        return S.of(context).veryPositive;
      default:
        return '-';
    }
  }
}
