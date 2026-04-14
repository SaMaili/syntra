import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../challenge.dart';
import '../data/challenge_repository.dart';
import '../data/settings_repository.dart';
import '../logic/comfort_zone_logic.dart';
import 'shared_preferences_provider.dart';

// ─── Settings repository ──────────────────────────────────────────────────────

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(sharedPreferencesProvider)),
);

// ─── Theme ────────────────────────────────────────────────────────────────────

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(ref.watch(settingsRepositoryProvider)),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SettingsRepository _repo;

  ThemeModeNotifier(this._repo) : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final saved = await _repo.loadThemeMode();
    state = _parse(saved);
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await _repo.saveThemeMode(_serialize(mode));
  }

  static ThemeMode _parse(String? value) => switch (value) {
        'dark' => ThemeMode.dark,
        'light' => ThemeMode.light,
        _ => ThemeMode.system,
      };

  static String _serialize(ThemeMode mode) => switch (mode) {
        ThemeMode.dark => 'dark',
        ThemeMode.light => 'light',
        _ => 'system',
      };
}

// ─── Locale ───────────────────────────────────────────────────────────────────

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(ref.watch(settingsRepositoryProvider)),
);

/// Exposes just the language code string to avoid rebuilding the entire locale
/// object when only the language code is needed (e.g. for DB queries).
final activeLocaleProvider = Provider<String>((ref) {
  return ref.watch(localeProvider).languageCode;
});

class LocaleNotifier extends StateNotifier<Locale> {
  final SettingsRepository _repo;

  LocaleNotifier(this._repo) : super(const Locale('en')) {
    _load();
  }

  Future<void> _load() async {
    final saved = await _repo.loadLanguage();
    if (saved != null && saved.isNotEmpty) {
      state = Locale(saved);
    } else {
      final device = WidgetsBinding
          .instance.platformDispatcher.locale.languageCode;
      state = Locale(device);
      await _repo.saveLanguage(device);
    }
  }

  Future<void> setLanguage(String code) async {
    state = Locale(code);
    await _repo.saveLanguage(code);
  }
}

// ─── Notifications ────────────────────────────────────────────────────────────

final notificationsEnabledProvider =
    StateNotifierProvider<NotificationsEnabledNotifier, bool>(
  (ref) => NotificationsEnabledNotifier(ref.watch(settingsRepositoryProvider)),
);

class NotificationsEnabledNotifier extends StateNotifier<bool> {
  final SettingsRepository _repo;

  NotificationsEnabledNotifier(this._repo) : super(false) {
    _load();
  }

  Future<void> _load() async {
    state = await _repo.loadNotificationsEnabled();
  }

  Future<void> set(bool value) async {
    state = value;
    await _repo.saveNotificationsEnabled(value);
  }
}

final soundEffectsEnabledProvider =
    StateNotifierProvider<SoundEffectsEnabledNotifier, bool>(
  (ref) => SoundEffectsEnabledNotifier(ref.watch(settingsRepositoryProvider)),
);

class SoundEffectsEnabledNotifier extends StateNotifier<bool> {
  final SettingsRepository _repo;

  SoundEffectsEnabledNotifier(this._repo) : super(true) {
    _load();
  }

  Future<void> _load() async {
    state = await _repo.loadSoundEffectsEnabled();
  }

  Future<void> set(bool value) async {
    state = value;
    await _repo.saveSoundEffectsEnabled(value);
  }
}

// ─── Comfort Zone Level ───────────────────────────────────────────────────────

final comfortZoneLevelProvider =
    StateNotifierProvider<ComfortZoneNotifier, int>(
  (ref) => ComfortZoneNotifier(
    ref.watch(settingsRepositoryProvider),
    ref.watch(sharedPreferencesProvider),
  ),
);

class ComfortZoneNotifier extends StateNotifier<int> {
  final SettingsRepository _repo;
  final SharedPreferences _prefs;

  ComfortZoneNotifier(this._repo, this._prefs) : super(1) {
    _load();
  }

  Future<void> _load() async {
    state = await _repo.loadComfortZoneLevel();
  }

  Future<void> setLevel(int level) async {
    await ComfortZoneLogic().resetCompletionsAtLevel(level, _prefs);
    state = level;
    await _repo.saveComfortZoneLevel(level);
  }

  /// Records a successful completion and levels up if threshold is reached.
  /// Returns the new level if a level-up occurred, null otherwise.
  Future<int?> recordSuccessAndCheckLevelUp(
      Challenge completed, String languageCode) async {
    final catalog =
        await ChallengeRepository.instance.loadChallenges(languageCode);
    final newLevel = await ComfortZoneLogic()
        .recordSuccessAndCheckLevelUp(state, completed, catalog, _prefs);
    if (newLevel != null) {
      await setLevel(newLevel);
      return newLevel;
    }
    return null;
  }

  int getCompletionsAtCurrentLevel() =>
      ComfortZoneLogic().getCompletionsAtLevel(state, _prefs);
}

final notificationSlotsProvider =
    StateNotifierProvider<NotificationSlotsNotifier,
        List<NotificationSlotSettings>>(
  (ref) => NotificationSlotsNotifier(ref.watch(settingsRepositoryProvider)),
);

class NotificationSlotsNotifier
    extends StateNotifier<List<NotificationSlotSettings>> {
  final SettingsRepository _repo;

  NotificationSlotsNotifier(this._repo)
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
    state = await _repo.loadAllSlots();
  }

  Future<void> updateSlot(int index, NotificationSlotSettings settings) async {
    final updated = [...state];
    updated[index] = settings;
    state = updated;
    await _repo.saveSlot(index + 1, settings);
  }
}
