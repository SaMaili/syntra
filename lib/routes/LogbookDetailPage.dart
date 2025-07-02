import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LogbookDetailPage extends StatelessWidget {
  final Map<String, dynamic> entry;
  const LogbookDetailPage({Key? key, required this.entry}) : super(key: key);

  Future<String> _getChallengeTitle(BuildContext context, String challengeId) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'challenge_database.db');
    final db = await openDatabase(path);
    final result = await db.rawQuery('SELECT title FROM challenges WHERE id = ?', [challengeId]);
    if (result.isNotEmpty) {
      return result.first['title']?.toString() ?? 'Unknown';
    }
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logbook Entry')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<String>(
          future: _getChallengeTitle(context, entry['challenge_id']?.toString() ?? ''),
          builder: (context, snapshot) {
            final challengeTitle = snapshot.data ?? '';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('Challenge', challengeTitle),
                _detailRow('Challenge ID', entry['challenge_id']?.toString()),
                _detailRow('Date', entry['timestamp']?.toString()),
                _detailRow('XP', entry['earned']?.toString()),
                _detailRow('Status', entry['status']?.toString()),
                _detailRow('Feeling', entry['feeling']?.toString()),
                _detailRow('Perception', entry['perception']?.toString()),
                _detailRow('Notes', entry['notes']?.toString()),
                const Spacer(),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text('Delete Entry'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Entry'),
                          content: const Text('Are you sure you want to delete this entry?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        final dbPath = await getDatabasesPath();
                        final path = join(dbPath, 'challenge_database.db');
                        final db = await openDatabase(path);
                        await db.delete('logbook', where: 'id = ?', whereArgs: [entry['id']]);
                        Navigator.of(context).pop(true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Entry deleted')),
                        );
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _detailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value ?? '-', style: const TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }
}

