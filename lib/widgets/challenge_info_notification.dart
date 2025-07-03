import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ChallengeInfoNotification {
  static Future<void> showLastNotesNotification(
    BuildContext context,
    String challengeId,
  ) async {
    // Open DB and get last logbook entry for this challenge
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'challenge_database.db');
    final db = await openDatabase(path);
    final result = await db.rawQuery(
      'SELECT notes, timestamp FROM logbook WHERE challenge_id = ? AND notes IS NOT NULL AND notes != "" ORDER BY timestamp DESC LIMIT 1',
      [challengeId],
    );
    String notes = '';
    String time = '';
    if (result.isNotEmpty) {
      notes = result.first['notes']?.toString() ?? '';
      time = result.first['timestamp']?.toString() ?? '';
    }
    String body;
    String formattedTime = '';
    if (time.isNotEmpty) {
      try {
        final dt = DateTime.parse(time);
        formattedTime =
            '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
      } catch (_) {
        formattedTime = time;
      }
    }
    if (notes.isNotEmpty) {
      body = '📝 Last note:\n"$notes"\n\n📅 Last completed: $formattedTime';
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'You have already completed this challenge!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.green,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📝', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        notes,
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
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.blueGrey,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Last completed: $formattedTime',
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blueAccent, size: 20),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'You can repeat this challenge as often as you like!',
                      style: TextStyle(fontSize: 14, color: Colors.blueGrey),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('OK', style: TextStyle(color: Colors.blueAccent)),
            ),
          ],
        ),
      );
    } else {
      // Show snackbar if no notes found
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You don\'t have any notes for this challenge yet.'),
        ),
      );
    }
  }
}
