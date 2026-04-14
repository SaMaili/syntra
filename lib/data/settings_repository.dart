import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Single source of truth for all user preferences.
///
/// Previously settings were split between settings.json (documents dir) and
/// SharedPreferences. That caused divergence bugs when one write failed.
/// Now everything lives in SharedPreferences — both Dart and the Kotlin
/// BootReceiver can read it without any bridge code.
///
/// The [SharedPreferences] instance is injected via the constructor rather
/// than fetched per-call. Use [sharedPreferencesProvider] and
/// [settingsRepositoryProvider] in Riverpod contexts. For non-Riverpod code
/// (e.g. [NotificationManager]) call [SettingsRepository.instance] after
/// [SettingsRepository.configure] has been called in [main].
class SettingsRepository {
  static const _keyDarkMode = 'settings_dark_mode'; // legacy bool
  static const _keyThemeMode = 'settings_theme_mode'; // "light" | "dark" | "system"
  static const _keyLanguage = 'settings_language';
  static const _keyNotificationsEnabled = 'notifications_enabled';
  static const _keySoundEffectsEnabled = 'sound_effects_enabled';
  static const _keySlot1Enabled = 'notification1Enabled';
  static const _keySlot1TimeH = 'notification1TimeHour';
  static const _keySlot1TimeM = 'notification1TimeMinute';
  static const _keySlot2Enabled = 'notification2Enabled';
  static const _keySlot2TimeH = 'notification2TimeHour';
  static const _keySlot2TimeM = 'notification2TimeMinute';
  static const _keySlot3Enabled = 'notification3Enabled';
  static const _keySlot3TimeH = 'notification3TimeHour';
  static const _keySlot3TimeM = 'notification3TimeMinute';
  static const _keyOnboardingComplete = 'onboarding_complete';
  static const _keyComfortZoneLevel = 'comfort_zone_level';
  static const _keyLastOpenedDate = 'last_opened_date';
  static const _keyLastCelebratedStreak = 'last_celebrated_streak';
  static const _keyWeeklyGoal = 'weekly_goal';
  static const _keyAllTimeMaxStreak = 'all_time_max_streak';
  static const _keyBestWeeklyStreak = 'best_weekly_streak';
  /// ISO year-week (e.g. "2026-W15") of the last week where the weekly XP
  /// goal was reached and the flame celebration was shown.
  static const _keyLastGoalWeek = 'last_goal_week';
  /// Comma-separated badge IDs that have already been celebrated.
  static const _keySeenBadges = 'seen_badges';

  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  // ─── Static accessor for non-Riverpod callers (NotificationManager etc.) ──

  static SettingsRepository? _instance;

  /// The app-wide instance set by [configure]. Available after [main] has run.
  static SettingsRepository get instance {
    assert(_instance != null,
        'SettingsRepository.configure() must be called before accessing .instance');
    return _instance!;
  }

  /// Call once in [main] before [runApp] to make [instance] available to
  /// non-Riverpod code (e.g. [NotificationManager]).
  static void configure(SharedPreferences prefs) {
    _instance = SettingsRepository(prefs);
  }

  // ─── Theme ────────────────────────────────────────────────────────────────

  /// Returns "light", "dark", or "system". Migrates from the legacy bool key
  /// on first call after upgrade. Returns null if nothing is stored yet.
  Future<String?> loadThemeMode() async {
    final saved = _prefs.getString(_keyThemeMode);
    if (saved != null) return saved;
    // Migrate from legacy bool preference.
    final legacy = _prefs.getBool(_keyDarkMode);
    if (legacy != null) {
      final migrated = legacy ? 'dark' : 'light';
      await _prefs.setString(_keyThemeMode, migrated);
      return migrated;
    }
    return null;
  }

  Future<void> saveThemeMode(String mode) async =>
      _prefs.setString(_keyThemeMode, mode);

  // Keep for backwards compat with any remaining callers.
  Future<bool?> loadDarkMode() async => _prefs.getBool(_keyDarkMode);

  Future<void> saveDarkMode(bool value) async =>
      _prefs.setBool(_keyDarkMode, value);

  // ─── Language ─────────────────────────────────────────────────────────────

  Future<String?> loadLanguage() async => _prefs.getString(_keyLanguage);

  Future<void> saveLanguage(String code) async =>
      _prefs.setString(_keyLanguage, code);

  // ─── Notifications ────────────────────────────────────────────────────────

  Future<bool> loadNotificationsEnabled() async =>
      _prefs.getBool(_keyNotificationsEnabled) ?? false;

  Future<void> saveNotificationsEnabled(bool value) async =>
      _prefs.setBool(_keyNotificationsEnabled, value);

  Future<bool> loadSoundEffectsEnabled() async =>
      _prefs.getBool(_keySoundEffectsEnabled) ?? true;

  Future<void> saveSoundEffectsEnabled(bool value) async =>
      _prefs.setBool(_keySoundEffectsEnabled, value);

  Future<NotificationSlotSettings> loadSlot(int slot) async {
    assert(slot >= 1 && slot <= 3);
    return NotificationSlotSettings(
      enabled: _prefs.getBool(_enabledKey(slot)) ?? false,
      time: TimeOfDay(
        hour: _prefs.getInt(_hourKey(slot)) ?? _defaultHour(slot),
        minute: _prefs.getInt(_minuteKey(slot)) ?? 0,
      ),
    );
  }

  Future<void> saveSlot(int slot, NotificationSlotSettings s) async {
    assert(slot >= 1 && slot <= 3);
    await _prefs.setBool(_enabledKey(slot), s.enabled);
    await _prefs.setInt(_hourKey(slot), s.time.hour);
    await _prefs.setInt(_minuteKey(slot), s.time.minute);
  }

  // ─── Onboarding ───────────────────────────────────────────────────────────

  Future<bool> loadOnboardingComplete() async =>
      _prefs.getBool(_keyOnboardingComplete) ?? false;

  Future<void> saveOnboardingComplete(bool value) async =>
      _prefs.setBool(_keyOnboardingComplete, value);

  Future<int> loadComfortZoneLevel() async =>
      _prefs.getInt(_keyComfortZoneLevel) ?? 1;

  Future<void> saveComfortZoneLevel(int level) async =>
      _prefs.setInt(_keyComfortZoneLevel, level);

  Future<String?> loadLastOpenedDate() async =>
      _prefs.getString(_keyLastOpenedDate);

  Future<void> saveLastOpenedDate(String date) async =>
      _prefs.setString(_keyLastOpenedDate, date);

  Future<List<NotificationSlotSettings>> loadAllSlots() =>
      Future.wait([loadSlot(1), loadSlot(2), loadSlot(3)]);

  // ─── Streak milestones ───────────────────────────────────────────────────

  Future<int> loadLastCelebratedStreak() async =>
      _prefs.getInt(_keyLastCelebratedStreak) ?? 0;

  Future<void> saveLastCelebratedStreak(int streak) async =>
      _prefs.setInt(_keyLastCelebratedStreak, streak);

  // ─── All-time best streak ─────────────────────────────────────────────────

  Future<int> loadAllTimeMaxStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyAllTimeMaxStreak) ?? 0;
  }

  Future<void> saveAllTimeMaxStreak(int streak) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyAllTimeMaxStreak, streak);
  }

  // ─── Best weekly streak ───────────────────────────────────────────────────

  Future<int> loadBestWeeklyStreak() async =>
      _prefs.getInt(_keyBestWeeklyStreak) ?? 0;

  Future<void> saveBestWeeklyStreak(int streak) async =>
      _prefs.setInt(_keyBestWeeklyStreak, streak);

  Future<String?> loadLastGoalWeek() async =>
      _prefs.getString(_keyLastGoalWeek);

  Future<void> saveLastGoalWeek(String isoWeek) async =>
      _prefs.setString(_keyLastGoalWeek, isoWeek);

  // ─── Seen badges ──────────────────────────────────────────────────────────

  Future<Set<String>> loadSeenBadges() async {
    final raw = _prefs.getString(_keySeenBadges) ?? '';
    if (raw.isEmpty) return {};
    return raw.split(',').toSet();
  }

  Future<void> saveSeenBadges(Set<String> badges) async =>
      _prefs.setString(_keySeenBadges, badges.join(','));

  // ─── Weekly goal ─────────────────────────────────────────────────────────

  Future<int> loadWeeklyGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyWeeklyGoal) ?? 5;
  }

  Future<void> saveWeeklyGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyWeeklyGoal, goal);
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _enabledKey(int slot) =>
      [_keySlot1Enabled, _keySlot2Enabled, _keySlot3Enabled][slot - 1];

  String _hourKey(int slot) =>
      [_keySlot1TimeH, _keySlot2TimeH, _keySlot3TimeH][slot - 1];

  String _minuteKey(int slot) =>
      [_keySlot1TimeM, _keySlot2TimeM, _keySlot3TimeM][slot - 1];

  int _defaultHour(int slot) => [9, 14, 19][slot - 1];
}

class NotificationSlotSettings {
  final bool enabled;
  final TimeOfDay time;

  const NotificationSlotSettings({required this.enabled, required this.time});

  NotificationSlotSettings copyWith({bool? enabled, TimeOfDay? time}) =>
      NotificationSlotSettings(
        enabled: enabled ?? this.enabled,
        time: time ?? this.time,
      );

  String get formatted {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
