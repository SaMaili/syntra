import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Single source of truth for all user preferences.
///
/// Previously settings were split between settings.json (documents dir) and
/// SharedPreferences. That caused divergence bugs when one write failed.
/// Now everything lives in SharedPreferences — both Dart and the Kotlin
/// BootReceiver can read it without any bridge code.
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

  static SettingsRepository? _instance;
  static SettingsRepository get instance =>
      _instance ??= SettingsRepository._();

  SettingsRepository._();

  // ─── Theme ────────────────────────────────────────────────────────────────

  Future<bool?> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode);
  }

  Future<void> saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, value);
  }

  // ─── Language ─────────────────────────────────────────────────────────────

  Future<String?> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguage);
  }

  Future<void> saveLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, code);
  }

  // ─── Notifications ────────────────────────────────────────────────────────

  Future<bool> loadNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotificationsEnabled) ?? false;
  }

  Future<void> saveNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationsEnabled, value);
  }

  Future<bool> loadSoundEffectsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySoundEffectsEnabled) ?? true;
  }

  Future<void> saveSoundEffectsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySoundEffectsEnabled, value);
  }

  Future<NotificationSlotSettings> loadSlot(int slot) async {
    assert(slot >= 1 && slot <= 3);
    final prefs = await SharedPreferences.getInstance();
    final enabledKey = _enabledKey(slot);
    final hourKey = _hourKey(slot);
    final minuteKey = _minuteKey(slot);
    return NotificationSlotSettings(
      enabled: prefs.getBool(enabledKey) ?? false,
      time: TimeOfDay(
        hour: prefs.getInt(hourKey) ?? _defaultHour(slot),
        minute: prefs.getInt(minuteKey) ?? 0,
      ),
    );
  }

  Future<void> saveSlot(int slot, NotificationSlotSettings s) async {
    assert(slot >= 1 && slot <= 3);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey(slot), s.enabled);
    await prefs.setInt(_hourKey(slot), s.time.hour);
    await prefs.setInt(_minuteKey(slot), s.time.minute);
  }

  // ─── Onboarding ───────────────────────────────────────────────────────────

  Future<bool> loadOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  Future<void> saveOnboardingComplete(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingComplete, value);
  }

  Future<int> loadComfortZoneLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyComfortZoneLevel) ?? 1;
  }

  Future<void> saveComfortZoneLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyComfortZoneLevel, level);
  }

  Future<String?> loadLastOpenedDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastOpenedDate);
  }

  Future<void> saveLastOpenedDate(String date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastOpenedDate, date);
  }

  Future<List<NotificationSlotSettings>> loadAllSlots() async {
    return Future.wait([loadSlot(1), loadSlot(2), loadSlot(3)]);
  }

  // ─── Streak milestones ───────────────────────────────────────────────────

  Future<int> loadLastCelebratedStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyLastCelebratedStreak) ?? 0;
  }

  Future<void> saveLastCelebratedStreak(int streak) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastCelebratedStreak, streak);
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
