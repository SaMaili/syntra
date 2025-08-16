import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/syntra_notification_service.dart';
import '../static.dart';
import '../logic/NotificationManager.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _soundEnabled = true;
  String _selectedLanguage = 'English';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? false;
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _selectedLanguage = prefs.getString('selected_language') ?? 'English';
    });
  }

  Future<void> _onNotificationToggle(bool value) async {
    print('🔄 Notification toggle triggered: $value');

    setState(() {
      _notificationsEnabled = value;
    });

    // Immediately save and apply notification changes
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    print('💾 Saved notifications_enabled = $value to SharedPreferences');

    // Sync native flag for Android boot receiver
    try {
      await SyntraNotificationService.instance.setNativeNotificationsEnabled(value);
    } catch (e) {
      print('⚠️ Failed to sync native notifications_enabled: $e');
    }

    if (value) {
      // When enabling notifications, ensure we have default times set up
      print('✅ Notifications enabled - setting up default schedule');

      // Remove individual notification slot settings to force default schedule
      await prefs.remove('notification1Enabled');
      await prefs.remove('notification2Enabled');
      await prefs.remove('notification3Enabled');

      // Remove any specific time settings to force default schedule
      await prefs.remove('notification1Time');
      await prefs.remove('notification2Time');
      await prefs.remove('notification3Time');

      print('🧹 Cleared individual notification settings to force default schedule');

      // Now schedule with default times
      await NotificationManager.scheduleDailyReminders();
      print('✅ Default notification schedule activated (9 AM, 2 PM, 7 PM)');
    } else {
      // Ensure comprehensive cancellation
      print('❌ Disabling notifications - starting comprehensive cancellation');
      await NotificationManager.cancelAllNotifications();
      print('❌ Notifications disabled - cancelling all notifications');

      // Double-check: Cancel any pending notifications in the system
      try {
        final notificationService = SyntraNotificationService.instance;
        await notificationService.cancelAllNotifications();
        print('✅ Additional cleanup: Professional service notifications cancelled');
      } catch (e) {
        print('⚠️ Warning during additional cleanup: $e');
      }
    }

    // Verify the setting was saved correctly
    final savedValue = prefs.getBool('notifications_enabled');
    print('🔍 Verification: notifications_enabled is now saved as: $savedValue');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value ? 'Notifications enabled with default schedule' : 'Notifications disabled'),
        backgroundColor: AppStatic.grape,
        duration: Duration(seconds: 2),
      ),
    );
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

          // Debug section to help troubleshoot
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.yellow.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange),
            ),
            child: Column(
              children: [
                Text('🔧 DEBUG: Current notification setting: $_notificationsEnabled'),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    print('🔧 DEBUG: Force enabling notifications...');
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('notifications_enabled', true);

                    // Sync native flag for Android boot receiver
                    try {
                      await SyntraNotificationService.instance.setNativeNotificationsEnabled(true);
                    } catch (e) {
                      print('⚠️ Failed to sync native notifications_enabled in debug: $e');
                    }

                    setState(() {
                      _notificationsEnabled = true;
                    });

                    await NotificationManager.scheduleDailyReminders();
                    print('🔧 DEBUG: Force enable completed');
                  },
                  child: Text('Force Enable Notifications'),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

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
                    onChanged: _onNotificationToggle,
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
                    onChanged: (value) {
                      setState(() {
                        _darkModeEnabled = value;
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
                _buildSettingItem(
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
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedLanguage = newValue!;
                      });
                    },
                  ),
                ),
                Divider(color: AppStatic.marianBlue.withValues(alpha: 0.3)),
                _buildSettingItem(
                  'About',
                  'App version and information',
                  Icons.info,
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppStatic.marianBlue,
                    size: 16,
                  ),
                ),
                Divider(color: AppStatic.marianBlue.withValues(alpha: 0.3)),
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
            onPressed: () async {
              // Save remaining settings
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('dark_mode_enabled', _darkModeEnabled);
              await prefs.setBool('sound_enabled', _soundEnabled);
              await prefs.setString('selected_language', _selectedLanguage);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Settings saved successfully!'),
                  backgroundColor: AppStatic.grape,
                  duration: Duration(seconds: 2),
                ),
              );
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

  Widget _buildSettingItem(String title, String subtitle, IconData icon, Widget trailing) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppStatic.grape,
            size: 24,
          ),
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
