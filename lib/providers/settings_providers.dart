import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../challenge.dart';
import '../data/settings_repository.dart';
import '../logic/comfort_zone_logic.dart';

// ─── Theme ────────────────────────────────────────────────────────────────────

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final dark = await SettingsRepository.instance.loadDarkMode();
    if (dark != null) {
      state = dark ? ThemeMode.dark : ThemeMode.light;
    }
  }

  Future<void> setDark(bool dark) async {
    state = dark ? ThemeMode.dark : ThemeMode.light;
    await SettingsRepository.instance.saveDarkMode(dark);
  }
}

// ─── Locale ───────────────────────────────────────────────────────────────────

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(),
);

/// Exposes just the language code string to avoid rebuilding the entire locale
/// object when only the language code is needed (e.g. for DB queries).
final activeLocaleProvider = Provider<String>((ref) {
  return ref.watch(localeProvider).languageCode;
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    _load();
  }

  Future<void> _load() async {
    final saved = await SettingsRepository.instance.loadLanguage();
    if (saved != null && saved.isNotEmpty) {
      state = Locale(saved);
    } else {
      // Fall back to device locale (first preference only)
      final device = WidgetsBinding
          .instance.platformDispatcher.locale.languageCode;
      state = Locale(device);
      await SettingsRepository.instance.saveLanguage(device);
    }
  }

  Future<void> setLanguage(String code) async {
    state = Locale(code);
    await SettingsRepository.instance.saveLanguage(code);
  }
}

// ─── Notifications ────────────────────────────────────────────────────────────

final notificationsEnabledProvider =
    StateNotifierProvider<NotificationsEnabledNotifier, bool>(
  (ref) => NotificationsEnabledNotifier(),
);

class NotificationsEnabledNotifier extends StateNotifier<bool> {
  NotificationsEnabledNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    state = await SettingsRepository.instance.loadNotificationsEnabled();
  }

  Future<void> set(bool value) async {
    state = value;
    await SettingsRepository.instance.saveNotificationsEnabled(value);
  }
}

final soundEffectsEnabledProvider =
    StateNotifierProvider<SoundEffectsEnabledNotifier, bool>(
  (ref) => SoundEffectsEnabledNotifier(),
);

class SoundEffectsEnabledNotifier extends StateNotifier<bool> {
  SoundEffectsEnabledNotifier() : super(true) {
    _load();
  }

  Future<void> _load() async {
    state = await SettingsRepository.instance.loadSoundEffectsEnabled();
  }

  Future<void> set(bool value) async {
    state = value;
    await SettingsRepository.instance.saveSoundEffectsEnabled(value);
  }
}

// ─── Comfort Zone Level ───────────────────────────────────────────────────────

final comfortZoneLevelProvider =
    StateNotifierProvider<ComfortZoneNotifier, int>(
  (ref) => ComfortZoneNotifier(),
);

class ComfortZoneNotifier extends StateNotifier<int> {
  ComfortZoneNotifier() : super(1) {
    _load();
  }

  Future<void> _load() async {
    state = await SettingsRepository.instance.loadComfortZoneLevel();
  }

  Future<void> setLevel(int level) async {
    state = level;
    await SettingsRepository.instance.saveComfortZoneLevel(level);
  }

  /// Records a successful completion and levels up if threshold is reached.
  /// Returns the new level if a level-up occurred, null otherwise.
  Future<int?> recordSuccessAndCheckLevelUp(Challenge completed) async {
    final newLevel =
        await ComfortZoneLogic().recordSuccessAndCheckLevelUp(state, completed);
    if (newLevel != null) {
      await setLevel(newLevel);
      return newLevel;
    }
    return null;
  }

  Future<int> getCompletionsAtCurrentLevel() async =>
      ComfortZoneLogic().getCompletionsAtLevel(state);
}

final notificationSlotsProvider =
    StateNotifierProvider<NotificationSlotsNotifier,
        List<NotificationSlotSettings>>(
  (ref) => NotificationSlotsNotifier(),
);

class NotificationSlotsNotifier
    extends StateNotifier<List<NotificationSlotSettings>> {
  NotificationSlotsNotifier()
      : super([
          const NotificationSlotSettings(
              enabled: false, time: TimeOfDay(hour: 9, minute: 0)),
          const NotificationSlotSettings(
              enabled: false, time: TimeOfDay(hour: 14, minute: 0)),
          const NotificationSlotSettings(
              enabled: false, time: TimeOfDay(hour: 19, minute: 0)),
        ]) {
    _load();
  }

  Future<void> _load() async {
    state = await SettingsRepository.instance.loadAllSlots();
  }

  Future<void> updateSlot(int index, NotificationSlotSettings settings) async {
    final updated = [...state];
    updated[index] = settings;
    state = updated;
    await SettingsRepository.instance.saveSlot(index + 1, settings);
  }
}
