import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syntra/logic/NotificationManager.dart';

import '../generated/l10n.dart';
import '../main.dart';
import '../static.dart';
import 'AboutPage.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguageCode = 'en';

  Future<String> get _settingsPath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/settings.json';
  }

  Future<File> get _settingsFile async {
    final path = await _settingsPath;
    return File(path);
  }

  Future<void> _loadSettings() async {
    try {
      final file = await _settingsFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final data = jsonDecode(contents);
        setState(() {
          _darkModeEnabled = data['darkMode'] ?? _darkModeEnabled;
          _notificationsEnabled =
              data['notificationsEnabled'] ?? _notificationsEnabled;
          _selectedLanguageCode = data['languageCode'] ?? _selectedLanguageCode;
        });
        if (_darkModeEnabled) {
          themeModeNotifier.value = ThemeMode.dark;
        } else {
          themeModeNotifier.value = ThemeMode.light;
        }
        // Initialize or cancel notifications based on setting
        if (_notificationsEnabled) {
          NotificationManager.startBackgroundService();
        } else {
          NotificationManager.stopBackgroundService();
        }
      }
    } catch (_) {}
  }

  Future<void> _saveSettings() async {
    final file = await _settingsFile;
    final dir = file.parent;
    // Check if the directory path is not empty and not root
    if (dir.path.isNotEmpty && dir.path != '/') {
      if (!(await dir.exists())) {
        await dir.create(recursive: true);
      }
    }
    final data = {
      'darkMode': _darkModeEnabled,
      'notificationsEnabled': _notificationsEnabled,
      'languageCode': _selectedLanguageCode,
    };
    await file.writeAsString(jsonEncode(data));
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgGradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF232526), Color(0xFF414345)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFFe0c3fc), Color(0xFF8ec5fc)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
    final cardColor = isDark ? Colors.grey[900] : AppStatic.grapeLight;
    final card2Color = isDark
        ? Colors.blueGrey[900]
        : AppStatic.marianBlueLight;
    final textPrimary = isDark ? Colors.white : AppStatic.textPrimary;
    final textSecondary = isDark
        ? Colors.grey[400]
        : AppStatic.textSecondaryLight;
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(gradient: bgGradient),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.settings, color: AppStatic.grape, size: 32),
                  const SizedBox(width: 10),
                  Text(
                    S.of(context).settingsTitle,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppStatic.grape,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppStatic.grape.withOpacity(0.08),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildSettingItem(
                      S.of(context).notifications,
                      S.of(context).notificationsSubtitle,
                      Icons.notifications,
                      Switch(
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                          _saveSettings();
                        },
                        activeColor: AppStatic.grape,
                      ),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    Divider(color: AppStatic.grape.withOpacity(0.3)),
                    _buildSettingItem(
                      S.of(context).darkMode,
                      S.of(context).darkModeSubtitle,
                      Icons.dark_mode,
                      Switch(
                        value: _darkModeEnabled,
                        onChanged: (value) {
                          setState(() {
                            _darkModeEnabled = value;
                          });
                          if (value) {
                            themeModeNotifier.value = ThemeMode.dark;
                          } else {
                            themeModeNotifier.value = ThemeMode.light;
                          }
                          _saveSettings();
                        },
                        activeColor: AppStatic.grape,
                      ),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    Divider(color: AppStatic.grape.withOpacity(0.3)),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(S.of(context).comingSoon),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Opacity(
                        opacity: 0.4,
                        child: _buildSettingItem(
                          S.of(context).soundEffects,
                          S.of(context).soundEffectsSubtitle,
                          Icons.volume_up,
                          Icon(Icons.toggle_off, color: Colors.grey, size: 32),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: card2Color,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppStatic.marianBlue.withOpacity(0.08),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildSettingItem(
                      S.of(context).language,
                      S.of(context).languageSubtitle,
                      Icons.language,
                      DropdownButton<String>(
                        value: _selectedLanguageCode,
                        underline: Container(),
                        items: [
                          DropdownMenuItem<String>(
                            value: 'en',
                            child: Text(S.of(context).languageEnglish),
                          ),
                          DropdownMenuItem<String>(
                            value: 'de',
                            child: Text(S.of(context).languageGerman),
                          ),
                        ],
                        onChanged: (value) async {
                          if (value != null) {
                            setState(() {
                              _selectedLanguageCode = value;
                            });
                            // Update the app locale immediately
                            localeNotifier.value = Locale(value);
                            _saveSettings();

                            // Reload challenges in the new language
                            await reloadChallengesForLanguage(value);
                          }
                        },
                      ),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    Divider(color: AppStatic.marianBlue.withOpacity(0.3)),
                    _buildSettingItem(
                      S.of(context).about,
                      S.of(context).aboutSubtitle,
                      Icons.info,
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const AboutNotePage(),
                            ),
                          );
                        },
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: AppStatic.marianBlue,
                          size: 16,
                        ),
                      ),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                tooltip: S.of(context).debugDeleteTooltip,
                onPressed: () {
                  // TODO: Implement delete logic here
                  debugPrint('Debug delete button pressed');
                },
              ),
              // Debug: Zeige die nächsten beiden Motivation-Benachrichtigungszeiten
              FutureBuilder<List<DateTime>>(
                future: getNextMotivationNotificationTimes(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  final times = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nächste Motivation 1: ${_formatTime(times[0])}'),
                      Text('Nächste Motivation 2: ${_formatTime(times[1])}'),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    String subtitle,
    IconData icon,
    Widget trailing, {
    Color? textPrimary,
    Color? textSecondary,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppStatic.grape, size: 24),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textPrimary ?? AppStatic.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary ?? AppStatic.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<List<DateTime>> getNextMotivationNotificationTimes() async {
    // Simuliere die gleiche Logik wie in NotificationManager
    final now = DateTime.now();
    final random = Random(
      now.day + now.month + now.year,
    ); // deterministisch für heute
    final int firstHour =
        AppStatic.motivationFirstHourStart +
        random.nextInt(AppStatic.motivationFirstHourRange);
    final int secondHour =
        AppStatic.motivationSecondHourStart +
        random.nextInt(AppStatic.motivationSecondHourRange);
    final DateTime t1 = DateTime(
      now.year,
      now.month,
      now.day,
      firstHour,
      random.nextInt(60),
    );
    final DateTime t2 = DateTime(
      now.year,
      now.month,
      now.day,
      secondHour,
      random.nextInt(60),
    );
    return [t1, t2];
  }
}
