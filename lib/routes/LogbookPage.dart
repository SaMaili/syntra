import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'LogbookDetailPage.dart';

class LogbookPage extends StatefulWidget {
  const LogbookPage({Key? key}) : super(key: key);

  @override
  State<LogbookPage> createState() => _LogbookPageState();
}

class _LogbookPageState extends State<LogbookPage> {
  List<Map<String, dynamic>> _entries = [];
  bool _loading = true;
  Map<String, String> _challengeTitles = {};
  static const int _pageSize = 50;
  int _currentPage = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries({bool append = false}) async {
    if (_isLoadingMore) return;
    setState(() {
      if (!append) _loading = true;
      _isLoadingMore = append;
    });
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'challenge_database.db');
    final db = await openDatabase(path);
    final offset = append ? _entries.length : 0;
    final result = await db.rawQuery(
      'SELECT * FROM logbook ORDER BY timestamp DESC LIMIT $_pageSize OFFSET $offset',
    );
    // Load all challenge titles
    if (_challengeTitles.isEmpty) {
      final challengeRows = await db.rawQuery('SELECT id, title FROM challenges');
      _challengeTitles = {
        for (final row in challengeRows)
          row['id'].toString(): row['title']?.toString() ?? 'Unknown'
      };
    }
    setState(() {
      if (append) {
        _entries = List<Map<String, dynamic>>.from(_entries)..addAll(List<Map<String, dynamic>>.from(result));
      } else {
        _entries = List<Map<String, dynamic>>.from(result);
        _currentPage = 0;
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
    return Scaffold(
      appBar: AppBar(title: const Text('Logbook')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) {
                if (_hasMore && !_isLoadingMore &&
                    scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                  _currentPage++;
                  _loadEntries(append: true);
                }
                return false;
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _entries.length + (_hasMore ? 1 : 0),
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, i) {
                  if (i >= _entries.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final entry = _entries[i];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    tileColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      child: Text(
                        (i + 1).toString(),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      _challengeTitles[entry['challenge_id']?.toString()] ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(_formatTimestamp(entry['timestamp']?.toString())),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          (entry['earned'] ?? 0).toString(),
                          style: TextStyle(
                            color: (entry['earned'] ?? 0) >= 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          _emotionIcon(entry['feeling'] as int?),
                          color: _emotionColor(entry['feeling'] as int?),
                          size: 28,
                        ),
                      ],
                    ),
                    onTap: () async {
                      final deleted = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => LogbookDetailPage(entry: entry),
                        ),
                      );
                      if (deleted == true) _loadEntries();
                    },
                  );
                },
              ),
            ),
    );
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
