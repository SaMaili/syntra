import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'database/challenge_database.dart';
import 'logic/NotificationManager.dart';
import 'routes/ChallengesScreen.dart';
import 'routes/DailyChallengeScreen.dart';
import 'routes/SettingsScreen.dart';
import 'routes/StatisticsScreen.dart';
import 'static.dart';

final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

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

Future<void> initializeThemeMode() async {
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
    }
  } catch (_) {}
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone data
  tz.initializeTimeZones();

  await initializeThemeMode();
  await copyDatabaseFromAssets();
  final challenges = await ChallengeDatabase.instance.readAllChallenges();
  AppStatic.CHALLENGES = challenges.toList();

  // Initialize notifications but only start background service if not already running
  await NotificationManager.initialize();

  // Check if service is already running before starting it
  try {
    final isServiceRunning = await FlutterBackgroundService().isRunning();
    if (!isServiceRunning) {
      print('Starting background service...');
      await NotificationManager.startBackgroundService();
    } else {
      print('Background service already running, skipping initialization');
    }
  } catch (e) {
    print('Error checking/starting background service: $e');
    // Continue app startup even if background service fails
  }

  runApp(SyntraApp());
}

class SyntraApp extends StatelessWidget {
  const SyntraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
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
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Challenge',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Daily',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
