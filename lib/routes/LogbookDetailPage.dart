import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LogbookDetailPage extends StatelessWidget {
  final Map<String, dynamic> entry;

  const LogbookDetailPage({Key? key, required this.entry}) : super(key: key);

  Future<String> _getChallengeTitle(
    BuildContext context,
    String challengeId,
  ) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'challenge_database.db');
    final db = await openDatabase(path);
    final result = await db.rawQuery(
      'SELECT title FROM challenges WHERE id = ?',
      [challengeId],
    );
    if (result.isNotEmpty) {
      return result.first['title']?.toString() ?? 'Unknown';
    }
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logbook Entry')),
      backgroundColor: Colors.grey[100],
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
                      _detailRow('Challenge', challengeTitle, icon: Icons.flag),
                      _detailRow(
                        'Date',
                        _formatDate(entry['timestamp']?.toString()),
                        icon: Icons.calendar_today,
                      ),
                      _detailRow(
                        'XP',
                        entry['earned']?.toString(),
                        icon: Icons.star,
                      ),
                      _detailRow(
                        'Status',
                        entry['status']?.toString(),
                        icon: Icons.info,
                      ),
                      _detailRow(
                        'Feeling',
                        entry['feeling']?.toString(),
                        icon: Icons.mood,
                      ),
                      _detailRow(
                        'Perception',
                        entry['perception']?.toString(),
                        icon: Icons.visibility,
                      ),
                      _detailRow(
                        'Challenge ID',
                        entry['challenge_id']?.toString() ?? '-',
                        icon: Icons.confirmation_number,
                      ),
                      if ((entry['notes']?.toString() ?? '').isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 24, bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
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
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.black87,
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
          label: const Text('Delete Entry'),
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
                title: const Text('Delete Entry'),
                content: const Text(
                  'Are you sure you want to delete this entry?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text(
                      'Delete',
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
                const SnackBar(
                  content: Text('Entry deleted'),
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

  Widget _detailRow(String label, String? value, {IconData? icon}) {
    // Special case for Feeling: show emoji + name
    if (label == 'Feeling') {
      final int? feelingValue = int.tryParse(value ?? '');
      final iconData = _emotionIcon(feelingValue);
      final feelingName = _feelingName(feelingValue);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(iconData, size: 24, color: _emotionColor(feelingValue)),
            const SizedBox(width: 8),
            Text(
              '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(feelingName, style: const TextStyle(color: Colors.black87)),
          ],
        ),
      );
    }
    // Special case for Perception: show emoji + name
    if (label == 'Perception') {
      final int? perceptionValue = int.tryParse(value ?? '');
      final iconData = _emotionIcon(perceptionValue);
      final perceptionName = _perceptionName(perceptionValue);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(iconData, size: 24, color: _emotionColor(perceptionValue)),
            const SizedBox(width: 8),
            Text(
              '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(perceptionName, style: const TextStyle(color: Colors.black87)),
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
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value ?? '-',
              style: const TextStyle(color: Colors.black87),
            ),
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

  String _feelingName(int? value) {
    switch (value) {
      case 0:
        return 'Very bad';
      case 1:
        return 'Bad';
      case 2:
        return 'Neutral';
      case 3:
        return 'Good';
      case 4:
        return 'Very good';
      default:
        return '-';
    }
  }

  String _perceptionName(int? value) {
    switch (value) {
      case 0:
        return 'Very negative';
      case 1:
        return 'Negative';
      case 2:
        return 'Neutral';
      case 3:
        return 'Positive';
      case 4:
        return 'Very positive';
      default:
        return '-';
    }
  }
}
