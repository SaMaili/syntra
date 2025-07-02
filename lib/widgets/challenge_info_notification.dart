import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ChallengeInfoNotification {
  static Future<void> showLastNotesNotification(BuildContext context, String challengeId) async {
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
    if (notes.isNotEmpty) {
      body = 'Last note: "$notes"\nLast done: $time';
      // Show as dialog/alarm note
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Challenge Info'),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // Show snackbar if no notes found
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You never did this challenge. Time to do it!'),
        ),
      );
    }
  }
}
