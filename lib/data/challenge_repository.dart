import 'dart:convert';

import 'package:flutter/services.dart';

import '../challenge.dart';

/// Loads the challenge catalog from bundled JSON assets.
/// The challenge content (title, description, hint) is language-dependent and
/// lives in assets/data/translations/{lang}.json.
/// Metadata (XP, timer, type, flirt, frequency) lives in assets/data/challenges.json.
///
/// Falls back to English when a translation key is missing.
class ChallengeRepository {
  static ChallengeRepository? _instance;
  static ChallengeRepository get instance =>
      _instance ??= ChallengeRepository._();

  ChallengeRepository._();

  List<Challenge>? _cache;
  String? _cachedLang;

  /// Returns all challenges for [languageCode].
  /// Subsequent calls with the same language are served from memory.
  Future<List<Challenge>> loadChallenges(String languageCode) async {
    if (_cache != null && _cachedLang == languageCode) return _cache!;

    final metaJson =
        await rootBundle.loadString('assets/data/challenges.json');
    final List<dynamic> metaList = jsonDecode(metaJson) as List;

    Map<String, dynamic> trans = await _loadTranslations(languageCode);
    Map<String, dynamic> fallback = languageCode == 'en'
        ? trans
        : await _loadTranslations('en');

    _cache = metaList.map((raw) {
      final meta = raw as Map<String, dynamic>;
      final id = meta['id'].toString();
      final t = (trans[id] as Map<String, dynamic>?) ??
          (fallback[id] as Map<String, dynamic>?) ??
          <String, dynamic>{};

      final rawHints = t['hints'];
      final hints = rawHints is List
          ? rawHints.cast<String>()
          : const <String>[];

      return Challenge(
        id: id,
        title: (t['title'] as String?) ?? '',
        description: (t['description'] as String?) ?? '',
        hints: hints,
        level: (meta['level'] as num?)?.toInt() ?? 1,
        xp: (meta['xp'] as num).toInt(),
        time: (meta['timer'] as num).toInt(),
        type: (meta['type'] as String?) ?? 'both',
        flirt: (meta['flirt'] as bool?) ?? false,
        frequency: (meta['frequency'] as num?)?.toDouble() ?? 1.0,
        environment: (meta['environment'] as String?) ?? 'all',
      );
    }).toList();

    _cachedLang = languageCode;
    return _cache!;
  }

  /// Invalidates the cache so the next [loadChallenges] reloads from disk.
  void invalidate() {
    _cache = null;
    _cachedLang = null;
  }

  Future<Map<String, dynamic>> _loadTranslations(String lang) async {
    try {
      final raw =
          await rootBundle.loadString('assets/data/translations/$lang.json');
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}
