import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'data/settings_repository.dart';
import 'generated/l10n.dart';
import 'providers/router_notifier.dart';
import 'providers/settings_providers.dart';
import 'providers/shared_preferences_provider.dart';
import 'router.dart';
import 'services/sound_service.dart';
import 'services/syntra_notification_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  // Initialize SharedPreferences once at startup.
  // configure() makes it available to non-Riverpod code (NotificationManager).
  // The ProviderScope override makes it injectable for all Riverpod providers.
  final prefs = await SharedPreferences.getInstance();
  SettingsRepository.configure(prefs);

  await _migrateSettingsJson();
  final onboardingDone =
      await SettingsRepository.instance.loadOnboardingComplete();
  routerNotifier = RouterNotifier(onboardingDone);
  await SoundService.init();
  await SyntraNotificationService.instance.initialize();
  runApp(ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: const SyntraApp(),
  ));
}

// ─── Boot helpers ─────────────────────────────────────────────────────────────

/// One-time migration: if settings.json still exists from a previous install,
/// copy its values into SharedPreferences then delete the file.
Future<void> _migrateSettingsJson() async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/settings.json');
    if (!await file.exists()) return;

    final data =
        jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    final repo = SettingsRepository.instance;

    if (data['darkMode'] is bool) {
      await repo.saveDarkMode(data['darkMode'] as bool);
    }
    if (data['languageCode'] is String) {
      await repo.saveLanguage(data['languageCode'] as String);
    }
    if (data['notificationsEnabled'] is bool) {
      await repo.saveNotificationsEnabled(
          data['notificationsEnabled'] as bool);
    }
    // One notification a day: seed the single reminder time from the first
    // enabled legacy slot in the old settings.json (else leave the default).
    for (int slot = 1; slot <= 3; slot++) {
      if (data['notification${slot}Enabled'] == true) {
        await repo.saveReminderTime(TimeOfDay(
          hour: (data['notification${slot}TimeHour'] as int?) ??
              [9, 14, 19][slot - 1],
          minute: (data['notification${slot}TimeMinute'] as int?) ?? 0,
        ));
        break;
      }
    }

    await file.delete();
  } catch (_) {
    // Migration is best-effort; if it fails the user just starts with defaults.
  }
}

// ─── App ──────────────────────────────────────────────────────────────────────

class SyntraApp extends ConsumerWidget {
  const SyntraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Syntra',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        S.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('de')],
      routerConfig: appRouter,
      // Clamp the system font-size scaler so large accessibility settings
      // don't break layouts, while still allowing mild scaling.
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: MediaQuery.of(context).textScaler.clamp(
            minScaleFactor: 1.0,
            maxScaleFactor: 1.3,
          ),
        ),
        child: child!,
      ),
    );
  }
}

