import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../Challenge.dart';

class ChallengeDatabase {
  static final ChallengeDatabase instance = ChallengeDatabase._init();
  static Database? _database;

  ChallengeDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('challenge_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    final exists = await databaseExists(path);
    if (!exists) {
      // Copy database from asset
      ByteData data = await rootBundle.load('assets/challenge_database.db');
      List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await File(path).writeAsBytes(bytes, flush: true);
    }
    return await openDatabase(path, version: 1);
  }

  Future<int> create(Challenge challenge) async {
    final db = await instance.database;
    return await db.insert('challenges', challenge.toMap());
  }

  Future<List<Challenge>> readAllChallenges([String? languageCode]) async {
    try {
      final db = await instance.database;

      // Default to English if no language code provided
      final locale = languageCode ?? 'en';

      final result = await db.rawQuery(
        '''
        SELECT 
          c.id,
          c.timer,
          c.xp,
          c.type,
          c.flirt,
          c.tags,
          c.frequency,
          ct.title,
          ct.description,
          ct.notSureWhatToSay
        FROM challenges c
        LEFT JOIN challenge_translations ct ON c.id = ct.challenge_id
        WHERE ct.language_code = ? OR ct.language_code = 'en'
        GROUP BY c.id
        ORDER BY CASE WHEN ct.language_code = ? THEN 0 ELSE 1 END
      ''',
        [locale, locale],
      );

      final challenges = result.map((json) => Challenge.fromMap(json)).toList();
      print(
        challenges.isEmpty
            ? 'No challenges found.'
            : 'Challenges loaded: \n${challenges.map((c) => c.title).join(', ')}',
      );
      return challenges;
    } catch (e, stack) {
      print(
        'Error when loading challenges: $e\nStacktrace:\n${stack.toString()}',
      );
      return [];
    }
  }

  Future<int> update(Challenge challenge) async {
    final db = await instance.database;
    return db.update(
      'challenges',
      challenge.toMap(),
      where: 'id = ?',
      whereArgs: [challenge.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('challenges', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> addLogbookEntry(Map<String, dynamic> entry) async {
    final db = await instance.database;
    return await db.insert('logbook', entry);
  }

  Future<Map<String, dynamic>?> readLogbookEntry(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'logbook',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
