import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

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
  bool _soundEnabled = true;
  String _selectedLanguage = 'English';

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
        });
        if (_darkModeEnabled) {
          themeModeNotifier.value = ThemeMode.dark;
        } else {
          themeModeNotifier.value = ThemeMode.light;
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
    final data = {'darkMode': _darkModeEnabled};
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
                    'Settings',
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
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('coming soon'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Opacity(
                        opacity: 0.4,
                        child: _buildSettingItem(
                          'Notifications',
                          'Get reminded about daily challenges',
                          Icons.notifications,
                          Icon(Icons.toggle_off, color: Colors.grey, size: 32),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      ),
                    ),
                    Divider(color: AppStatic.grapeDivider),
                    _buildSettingItem(
                      'Dark Mode',
                      'Switch to dark theme',
                      Icons.dark_mode,
                      Switch(
                        value: _darkModeEnabled,
                        onChanged: (value) {
                          setState(() {
                            _darkModeEnabled = value;
                            if (value) {
                              themeModeNotifier.value = ThemeMode.dark;
                            } else {
                              themeModeNotifier.value = ThemeMode.light;
                            }
                            _saveSettings();
                          });
                        },
                        activeColor: AppStatic.grape,
                      ),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    Divider(color: AppStatic.grapeDivider),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('coming soon'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Opacity(
                        opacity: 0.4,
                        child: _buildSettingItem(
                          'Sound Effects',
                          'Play sounds for interactions',
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
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('coming soon'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Opacity(
                        opacity: 0.4,
                        child: _buildSettingItem(
                          'Language',
                          'Choose your preferred language',
                          Icons.language,
                          DropdownButton<String>(
                            value: _selectedLanguage,
                            underline: Container(),
                            items: ['English', 'Spanish', 'French', 'German']
                                .map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                })
                                .toList(),
                            onChanged: null,
                          ),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      ),
                    ),
                    Divider(color: AppStatic.marianBlue.withOpacity(0.3)),
                    _buildSettingItem(
                      'About',
                      'App version and information',
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
                tooltip: 'Debug Delete',
                onPressed: () {
                  // TODO: Implement delete logic here
                  debugPrint('Debug delete button pressed');
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
}
