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
  static const _keyDarkMode = 'settings_dark_mode';
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
  static const _keyAllTimeMaxStreak = 'all_time_max_streak';

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
