import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../main.dart';
import '../static.dart';
import 'AboutNotePage.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
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
    // Prüfe, ob der Verzeichnispfad nicht leer ist und nicht root
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppStatic.grape,
            ),
          ),
          SizedBox(height: 30),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppStatic.grapeLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _buildSettingItem(
                  'Notifications',
                  'Get reminded about daily challenges',
                  Icons.notifications,
                  Switch(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                    activeColor: AppStatic.grape,
                  ),
                ),
                Divider(color: AppStatic.grapeDivider),
                _buildSettingItem(
                  'Dark Mode',
                  'Switch to dark theme',
                  Icons.dark_mode,
                  Switch(
                    value: _darkModeEnabled,

                    // TODO: Implement dark mode correctly and fix switch behavior
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
                ),
                Divider(color: AppStatic.grapeDivider),
                _buildSettingItem(
                  'Sound Effects',
                  'Play sounds for interactions',
                  Icons.volume_up,
                  Switch(
                    value: _soundEnabled,
                    onChanged: (value) {
                      setState(() {
                        _soundEnabled = value;
                      });
                    },
                    activeColor: AppStatic.grape,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppStatic.marianBlueLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                // TODO : Implement language selection
                _buildSettingItem(
                  'Language',
                  'Choose your preferred language',
                  Icons.language,
                  DropdownButton<String>(
                    value: _selectedLanguage,
                    underline: Container(),
                    items: ['English', 'Spanish', 'French', 'German'].map((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedLanguage = newValue!;
                      });
                    },
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
                ),
                Divider(color: AppStatic.marianBlue.withOpacity(0.3)),
                _buildSettingItem(
                  'Privacy Policy',
                  'Read our privacy policy',
                  Icons.privacy_tip,
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppStatic.marianBlue,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppStatic.grapeDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            ),
            onPressed: () {
              // TODO: Implement save settings
            },
            child: Text(
              'Save Settings',
              style: TextStyle(fontSize: 18, color: AppStatic.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    String subtitle,
    IconData icon,
    Widget trailing,
  ) {
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
                    color: AppStatic.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppStatic.textSecondaryLight,
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
