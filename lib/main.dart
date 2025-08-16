import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

import 'database/challenge_database.dart';
import 'generated/l10n.dart';
import 'logic/NotificationManager.dart';
import 'routes/ChallengesScreen.dart';
import 'routes/DailyChallengeScreen.dart';
import 'routes/SettingsScreen.dart';
import 'routes/StatisticsScreen.dart';
import 'services/syntra_notification_service.dart';
import 'static.dart';

final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);
final localeNotifier = ValueNotifier<Locale>(Locale('en'));
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

// Function to reload challenges when language changes
Future<void> reloadChallengesForLanguage(String languageCode) async {
  print("Reloading challenges for language: $languageCode");
  final challenges = await ChallengeDatabase.instance.readAllChallenges(
    languageCode,
  );
  AppStatic.CHALLENGES = challenges.toList();
  print("Challenges reloaded successfully");
}

Future<void> copyDatabaseFromAssets() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'challenge_database.db');
  final exists = await databaseExists(path);
  print('DB-Pfad: $path'); // <-- Hier wird der Pfad ausgegeben
  if (!exists) {
    ByteData data = await rootBundle.load('assets/challenge_database.db');
    List<int> bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    await File(path).writeAsBytes(bytes, flush: true);
  }
}

Future<void> initializeSettings() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/settings.json');
    if (await file.exists()) {
      final contents = await file.readAsString();
      final data = jsonDecode(contents);
      if (data['darkMode'] == true) {
        themeModeNotifier.value = ThemeMode.dark;
      } else {
        themeModeNotifier.value = ThemeMode.light;
      }
      if (data['languageCode'] != null) {
        localeNotifier.value = Locale(data['languageCode']);
      }

      // NEW: Mirror notificationsEnabled into SharedPreferences for NotificationManager
      try {
        if (data.containsKey('notificationsEnabled')) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('notifications_enabled', data['notificationsEnabled'] == true);
          print("initializeSettings: notifications_enabled set to ${data['notificationsEnabled']}");
        }
      } catch (e) {
        print('Warning: Failed to sync notificationsEnabled to SharedPreferences: $e');
      }
    }
  } catch (_) {}
}

void main() async {
  print("Starting Syntra App...");

  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize timezone data with error handling
    try {
      tz.initializeTimeZones();
      print("Timezone data initialized successfully");
    } catch (e) {
      print("Warning: Timezone initialization failed: $e");
      // Continue anyway, app can work without timezone data
    }

    // Initialize settings with error handling
    try {
      await initializeSettings();
      print("Settings initialized successfully");
    } catch (e) {
      print("Warning: Settings initialization failed: $e");
      // Use default settings if loading fails
      themeModeNotifier.value = ThemeMode.system;
      localeNotifier.value = Locale('en');
    }

    // Copy database with proper error handling
    try {
      await copyDatabaseFromAssets();
      print("Database copied successfully");
    } catch (e) {
      print("Error copying database: $e");
      // This is critical, but let's continue and see if we can recover
    }

    // Determine language code with proper priority and error handling
    String languageCode = 'en'; // Default fallback

    try {
      if (localeNotifier.value.languageCode != 'en' ||
          (localeNotifier.value.languageCode == 'en' &&
              await _hasUserSetLanguageExplicitly())) {
        languageCode = localeNotifier.value.languageCode;
        print("Using user's saved language preference: $languageCode");
      } else {
        final deviceLocale = ui.PlatformDispatcher.instance.locale;
        languageCode = deviceLocale.languageCode;
        print("Using device language: $languageCode");
        localeNotifier.value = Locale(languageCode);
      }
    } catch (e) {
      print("Error determining language: $e, using default 'en'");
      languageCode = 'en';
      localeNotifier.value = Locale('en');
    }

    // Load challenges with error handling
    try {
      final challenges = await ChallengeDatabase.instance.readAllChallenges(languageCode);
      AppStatic.CHALLENGES = challenges.toList();
      print("Challenges loaded successfully: ${AppStatic.CHALLENGES.length} challenges");
    } catch (e) {
      print("Error loading challenges: $e");
      // Initialize with empty list to prevent null errors
      AppStatic.CHALLENGES = [];
    }

    // Initialize notification systems with proper error handling
    await _initializeNotificationSystems();

    print("App initialization completed successfully");
    runApp(SyntraApp());

  } catch (e, stackTrace) {
    print("Critical error during app initialization: $e");
    print("Stack trace: $stackTrace");

    // Create a minimal app that shows an error message
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'App Initialization Error',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Please restart the app. If the problem persists, clear app data.',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

/// Initialize notification systems with proper error handling
Future<void> _initializeNotificationSystems() async {
  print('Initializing notification systems...');

  try {
    // Initialize the professional notification system
    print('Initializing professional notification system...');
    final notificationInitialized = await SyntraNotificationService.instance.initialize();

    if (notificationInitialized) {
      print('Professional notification system initialized successfully');

      // Schedule daily reminders using the professional system (in main app thread)
      try {
        await NotificationManager.scheduleDailyReminders();
        print('Daily reminders scheduled successfully with professional system');
        
        // Set up periodic reschedule to ensure notifications continue working
        _setupPeriodicNotificationReschedule();
      } catch (e) {
        print('Warning: Failed to schedule daily reminders: $e');
      }
    } else {
      print('Failed to initialize professional notification system');
    }
  } catch (e) {
    print('Error initializing professional notification system: $e');
  }

  // Background service is no longer needed - native notifications handle everything!
  print('✅ No background service needed - using native Android notifications');
}

class SyntraApp extends StatelessWidget {
  const SyntraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, locale, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeModeNotifier,
          builder: (context, mode, _) {
            return MaterialApp(
              locale: locale,
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                S.delegate, // generated localization delegate
              ],
              supportedLocales: const [Locale('en'), Locale('de')],

              // locale is managed by localeNotifier
              title: 'Syntra',
              theme: ThemeData(
                scaffoldBackgroundColor: AppStatic.snow,
                appBarTheme: AppBarTheme(
                  backgroundColor: AppStatic.snow,
                  titleTextStyle: TextStyle(
                    color: AppStatic.grape,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  iconTheme: IconThemeData(color: AppStatic.grape),
                ),
                bottomNavigationBarTheme: BottomNavigationBarThemeData(
                  backgroundColor: AppStatic.snow,
                  selectedItemColor: AppStatic.grape,
                  unselectedItemColor: AppStatic.marianBlue,
                ),
                primaryColor: AppStatic.grape,
                colorScheme: ColorScheme.light(
                  primary: AppStatic.grape,
                  secondary: AppStatic.marianBlue,
                ),
                textTheme: TextTheme(
                  bodyLarge: TextStyle(color: AppStatic.textPrimary),
                  bodyMedium: TextStyle(color: AppStatic.textPrimary),
                ),
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: Colors.black,
                appBarTheme: AppBarTheme(
                  backgroundColor: Colors.black,
                  titleTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  iconTheme: IconThemeData(color: Colors.white),
                ),
                bottomNavigationBarTheme: BottomNavigationBarThemeData(
                  backgroundColor: Colors.black,
                  selectedItemColor: Colors.amberAccent,
                  unselectedItemColor: Colors.grey,
                ),
              ),
              themeMode: mode,
              navigatorObservers: [routeObserver],
              home: HomeBar(),
            );
          },
        );
      },
    );
  }
}

class HomeBar extends StatefulWidget {
  const HomeBar({super.key});

  @override
  _HomeBarState createState() => _HomeBarState();
}

class _HomeBarState extends State<HomeBar> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    ChallengesScreen(),
    DailyChallengeScreen(),
    StatisticsScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppStatic.grape,
        unselectedItemColor: AppStatic.marianBlue,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: S.of(context).navChallenge,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: S.of(context).navDaily,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: S.of(context).navStats,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: S.of(context).navSettings,
          ),
        ],
      ),
    );
  }
}

// Helper function to check if user has explicitly set a language
Future<bool> _hasUserSetLanguageExplicitly() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/settings.json');
    if (await file.exists()) {
      final contents = await file.readAsString();
      final data = jsonDecode(contents);
      return data['languageCode'] != null;
    }
  } catch (_) {}
  return false;
}

/// Set up periodic notification reschedule to ensure notifications continue working
/// even if the app isn't opened frequently
void _setupPeriodicNotificationReschedule() {
  print('Setting up periodic notification reschedule every 6 hours');
  
  Timer.periodic(const Duration(hours: 6), (timer) async {
    try {
      print('⏰ Periodic reschedule: Checking and rescheduling daily reminders');
      
      // Only reschedule if the app is in the foreground (method channels available)
      // This prevents issues when the timer fires while app is in background
      final binding = WidgetsBinding.instance;
      if (binding.lifecycleState == AppLifecycleState.resumed || 
          binding.lifecycleState == AppLifecycleState.inactive) {
        
        await NotificationManager.scheduleDailyReminders();
        print('✅ Periodic reschedule completed successfully');
      } else {
        print('📱 App in background, skipping reschedule (will retry in 6 hours)');
      }
    } catch (e) {
      print('⚠️ Error during periodic reschedule: $e');
    }
  });
  
  print('✅ Periodic notification reschedule setup complete');
}
