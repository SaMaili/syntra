import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syntra/logic/NotificationManager.dart';
import '../services/syntra_notification_service.dart';

import '../generated/l10n.dart';
import '../main.dart';
import '../static.dart';
import 'AboutPage.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguageCode = 'en';

  // New notification control settings
  bool _notification1Enabled = false;
  bool _notification2Enabled = false;
  bool _notification3Enabled = false;
  TimeOfDay _notification1Time = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _notification2Time = const TimeOfDay(hour: 14, minute: 0);
  TimeOfDay _notification3Time = const TimeOfDay(hour: 19, minute: 0);

  // Animation controllers for beautiful UI
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _staggerController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late List<Animation<double>> _staggerAnimations;

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
          _notification1Enabled = data['notification1Enabled'] ?? _notification1Enabled;
          _notification2Enabled = data['notification2Enabled'] ?? _notification2Enabled;
          _notification3Enabled = data['notification3Enabled'] ?? _notification3Enabled;
          _notification1Time = TimeOfDay(
            hour: data['notification1TimeHour'] ?? _notification1Time.hour,
            minute: data['notification1TimeMinute'] ?? _notification1Time.minute,
          );
          _notification2Time = TimeOfDay(
            hour: data['notification2TimeHour'] ?? _notification2Time.hour,
            minute: data['notification2TimeMinute'] ?? _notification2Time.minute,
          );
          _notification3Time = TimeOfDay(
            hour: data['notification3TimeHour'] ?? _notification3Time.hour,
            minute: data['notification3TimeMinute'] ?? _notification3Time.minute,
          );
        });

        // Also sync the notification settings to SharedPreferences for consistency
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('notifications_enabled', _notificationsEnabled);
        await prefs.setBool('notification1Enabled', _notification1Enabled);
        await prefs.setBool('notification2Enabled', _notification2Enabled);
        await prefs.setBool('notification3Enabled', _notification3Enabled);
        await prefs.setString('notification1Time', _formatTimeOfDay(_notification1Time));
        await prefs.setString('notification2Time', _formatTimeOfDay(_notification2Time));
        await prefs.setString('notification3Time', _formatTimeOfDay(_notification3Time));

        // If all slots are disabled, remove the flags so default schedule applies
        if (!_notification1Enabled && !_notification2Enabled && !_notification3Enabled) {
          await prefs.remove('notification1Enabled');
          await prefs.remove('notification2Enabled');
          await prefs.remove('notification3Enabled');
        }

        if (_darkModeEnabled) {
          themeModeNotifier.value = ThemeMode.dark;
        } else {
          themeModeNotifier.value = ThemeMode.light;
        }
        // Initialize or cancel notifications based on setting
        if (_notificationsEnabled) {
          // Sync native flag
          try { await SyntraNotificationService.instance.setNativeNotificationsEnabled(true); } catch (_) {}
          await NotificationManager.scheduleDailyReminders();
        } else {
          try { await SyntraNotificationService.instance.setNativeNotificationsEnabled(false); } catch (_) {}
          await NotificationManager.cancelAllNotifications();
        }
      }
    } catch (_) {}
  }

  Future<void> _saveSettings() async {
    // Save to file (for backward compatibility)
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
      'notification1Enabled': _notification1Enabled,
      'notification2Enabled': _notification2Enabled,
      'notification3Enabled': _notification3Enabled,
      'notification1TimeHour': _notification1Time.hour,
      'notification1TimeMinute': _notification1Time.minute,
      'notification2TimeHour': _notification2Time.hour,
      'notification2TimeMinute': _notification2Time.minute,
      'notification3TimeHour': _notification3Time.hour,
      'notification3TimeMinute': _notification3Time.minute,
    };
    await file.writeAsString(jsonEncode(data));

    // Also save notification settings to SharedPreferences for NotificationManager access
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('notification1Enabled', _notification1Enabled);
    await prefs.setBool('notification2Enabled', _notification2Enabled);
    await prefs.setBool('notification3Enabled', _notification3Enabled);
    await prefs.setString('notification1Time', _formatTimeOfDay(_notification1Time));
    await prefs.setString('notification2Time', _formatTimeOfDay(_notification2Time));
    await prefs.setString('notification3Time', _formatTimeOfDay(_notification3Time));

    // If all slots are disabled, remove the flags so default schedule applies
    if (!_notification1Enabled && !_notification2Enabled && !_notification3Enabled) {
      await prefs.remove('notification1Enabled');
      await prefs.remove('notification2Enabled');
      await prefs.remove('notification3Enabled');
    }

    print('💾 Settings saved to both file and SharedPreferences');
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();

    // Initialize animation controllers
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Define animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _staggerAnimations = [
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(0.0, 0.5, curve: Curves.easeInOut),
        ),
      ),
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(0.5, 1.0, curve: Curves.easeInOut),
        ),
      ),
    ];

    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    _staggerController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Beautiful gradient backgrounds similar to other screens
    final bgGradient = isDark
        ? const LinearGradient(
      colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : const LinearGradient(
      colors: [Color(0xFFe0c3fc), Color(0xFF8ec5fc), Color(0xFF74b9ff)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final cardColor = isDark
        ? Colors.grey[900]!.withValues(alpha: 0.95)
        : Colors.white.withValues(alpha: 0.95);
    final card2Color = isDark
        ? Colors.grey[850]!.withValues(alpha: 0.95)
        : Colors.white.withValues(alpha: 0.9);
    final titleColor = isDark ? Colors.pinkAccent : AppStatic.grape;
    final accentColor = isDark ? Colors.cyanAccent : AppStatic.marianBlue;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: isDark ? 0.1 : 0.2),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.settings, color: titleColor, size: 24),
              SizedBox(width: 8),
              Text(
                S.of(context).settingsTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: isDark ? Colors.black : AppStatic.grapeLight,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 20),

                            // Main Settings Card
                            AnimatedBuilder(
                              animation: _staggerAnimations[0],
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, 50 * (1 - _staggerAnimations[0].value)),
                                  child: Opacity(
                                    opacity: _staggerAnimations[0].value,
                                    child: _buildSettingsCard(
                                      titleColor: titleColor,
                                      cardColor: cardColor,
                                      isDark: isDark,
                                      title: 'App Settings',
                                      icon: Icons.tune,
                                      children: [
                                        _buildEnhancedSettingItem(
                                          S.of(context).notifications,
                                          S.of(context).notificationsSubtitle,
                                          Icons.notifications_active,
                                          Switch(
                                            value: _notificationsEnabled,
                                            onChanged: (value) async {
                                              setState(() {
                                                _notificationsEnabled = value;
                                              });
                                              // Persist to file and SharedPreferences
                                              await _saveSettings();
                                              final prefs = await SharedPreferences.getInstance();
                                              await prefs.setBool('notifications_enabled', value);
                                              // Sync native flag
                                              try { await SyntraNotificationService.instance.setNativeNotificationsEnabled(value); } catch (_) {}
                                              if (value) {
                                                await NotificationManager.scheduleDailyReminders();
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(S.of(context).notificationsEnabled),
                                                    backgroundColor: titleColor,
                                                    duration: Duration(seconds: 2),
                                                  ),
                                                );
                                              } else {
                                                await NotificationManager.cancelAllNotifications();
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(S.of(context).notificationsDisabled),
                                                    backgroundColor: Colors.grey,
                                                    duration: Duration(seconds: 2),
                                                  ),
                                                );
                                              }
                                            },
                                            activeColor: titleColor,
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          isDark: isDark,
                                        ),
                                        _buildDivider(titleColor),
                                        _buildEnhancedSettingItem(
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
                                            activeColor: titleColor,
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          isDark: isDark,
                                        ),
                                        _buildDivider(titleColor),
                                        GestureDetector(
                                          onTap: () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(S.of(context).comingSoon),
                                                duration: Duration(seconds: 2),
                                                backgroundColor: titleColor,
                                              ),
                                            );
                                          },
                                          child: Opacity(
                                            opacity: 0.5,
                                            child: _buildEnhancedSettingItem(
                                              S.of(context).soundEffects,
                                              S.of(context).soundEffectsSubtitle,
                                              Icons.volume_up,
                                              Icon(Icons.toggle_off, color: Colors.grey, size: 32),
                                              isDark: isDark,
                                              isDisabled: true,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                );
                              },
                            ),

                            SizedBox(height: 24),

                            // Notification Schedule Settings Card (only show if notifications are enabled)
                            if (_notificationsEnabled)
                              AnimatedBuilder(
                                animation: _staggerAnimations[1],
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(0, 50 * (1 - _staggerAnimations[1].value)),
                                    child: Opacity(
                                      opacity: _staggerAnimations[1].value,
                                      child: _buildNotificationScheduleCard(
                                        titleColor: Colors.amber,
                                        cardColor: card2Color,
                                        isDark: isDark,
                                      ),
                                    ),
                                  );
                                },
                              ),

                            SizedBox(height: 24),

                            // General Settings Card
                            AnimatedBuilder(
                              animation: _staggerAnimations[1],
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, 50 * (1 - _staggerAnimations[1].value)),
                                  child: Opacity(
                                    opacity: _staggerAnimations[1].value,
                                    child: _buildSettingsCard(
                                      titleColor: accentColor,
                                      cardColor: card2Color,
                                      isDark: isDark,
                                      title: 'General',
                                      icon: Icons.language,
                                      children: [
                                        _buildEnhancedSettingItem(
                                          S.of(context).language,
                                          S.of(context).languageSubtitle,
                                          Icons.translate,
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: accentColor.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                            child: DropdownButton<String>(
                                              value: _selectedLanguageCode,
                                              underline: Container(),
                                              isDense: true,
                                              style: TextStyle(
                                                color: accentColor,
                                                fontWeight: FontWeight.bold,
                                              ),
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
                                                  localeNotifier.value = Locale(value);
                                                  _saveSettings();
                                                  await reloadChallengesForLanguage(value);
                                                  // Reschedule notifications in the new language
                                                  if (_notificationsEnabled) {
                                                    await NotificationManager.cancelAllNotifications();
                                                    await NotificationManager.scheduleDailyReminders();
                                                  }
                                                }
                                              },
                                            ),
                                          ),
                                          isDark: isDark,
                                          useAccentColor: true,
                                        ),
                                        _buildDivider(accentColor),
                                        _buildEnhancedSettingItem(
                                          S.of(context).about,
                                          S.of(context).aboutSubtitle,
                                          Icons.info_outline,
                                          Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: accentColor.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              Icons.arrow_forward_ios,
                                              color: accentColor,
                                              size: 18,
                                            ),
                                          ),
                                          isDark: isDark,
                                          useAccentColor: true,
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) => const AboutNotePage(),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  )
                                );
                              },
                            ),


                            SizedBox(height: 32),

                            // Debug Section - Test Notifications Only
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.orange.withValues(alpha: 0.8),
                                    Colors.deepOrange.withValues(alpha: 0.8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    spreadRadius: 1,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                icon: Icon(Icons.bug_report, size: 24, color: Colors.white),
                                label: Text(
                                  '🧪 TEST NOTIFICATIONS',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: () async {
                                  print('🧪 MANUAL TEST: Testing notification system...');
                                  await NotificationManager.testNotificationSystem();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('🧪 Notification test started! Check console and wait for notifications.'),
                                      duration: Duration(seconds: 3),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                },
                              ),
                            ),

                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required Color titleColor,
    required Color cardColor,
    required bool isDark,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: titleColor.withValues(alpha: 0.2),
            blurRadius: 25,
            spreadRadius: 2,
            offset: Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: titleColor, size: 28),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildNotificationScheduleCard({
    required Color titleColor,
    required Color cardColor,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: titleColor.withValues(alpha: 0.2),
            blurRadius: 25,
            spreadRadius: 2,
            offset: Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: titleColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.notifications_active, color: titleColor, size: 28),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).dailyReminders,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      S.of(context).dailyRemindersSubtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          // Notification Time Slots
          Column(
            children: [
              _buildModernTimeSlot(
                Icons.looks_one,
                _notification1Time,
                _notification1Enabled,
                Colors.orange,
                (value) async {
                  setState(() {
                    _notification1Enabled = value;
                  });
                  await _saveSettings();
                  // Cancel all existing notifications and reschedule based on current settings
                  await NotificationManager.cancelAllNotifications();
                  if (_notificationsEnabled) {
                    await NotificationManager.scheduleDailyReminders();
                  }
                },
                () => _selectTime(context, 'Notification 1', _notification1Time),
                isDark: isDark,
              ),

              SizedBox(height: 16),

              _buildModernTimeSlot(
                Icons.looks_two,
                _notification2Time,
                _notification2Enabled,
                Colors.blue,
                (value) async {
                  setState(() {
                    _notification2Enabled = value;
                  });
                  await _saveSettings();
                  // Cancel all existing notifications and reschedule based on current settings
                  await NotificationManager.cancelAllNotifications();
                  if (_notificationsEnabled) {
                    await NotificationManager.scheduleDailyReminders();
                  }
                },
                () => _selectTime(context, 'Notification 2', _notification2Time),
                isDark: isDark,
              ),

              SizedBox(height: 16),

              _buildModernTimeSlot(
                Icons.looks_3,
                _notification3Time,
                _notification3Enabled,
                Colors.purple,
                (value) async {
                  setState(() {
                    _notification3Enabled = value;
                  });
                  await _saveSettings();
                  // Cancel all existing notifications and reschedule based on current settings
                  await NotificationManager.cancelAllNotifications();
                  if (_notificationsEnabled) {
                    await NotificationManager.scheduleDailyReminders();
                  }
                },
                () => _selectTime(context, 'Notification 3', _notification3Time),
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernTimeSlot(
    IconData icon,
    TimeOfDay time,
    bool enabled,
    Color accentColor,
    ValueChanged<bool> onToggle,
    VoidCallback onTimeTap, {
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: enabled
          ? accentColor.withValues(alpha: 0.1)
          : (isDark ? Colors.grey[850] : Colors.grey[100]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: enabled ? accentColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Icon Section
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: enabled
                ? accentColor.withValues(alpha: 0.15)
                : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: enabled ? accentColor : Colors.grey,
              size: 24,
            ),
          ),

          SizedBox(width: 16),

          // Text Section
          Expanded(
            child: Text(
              '',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: enabled
                  ? (isDark ? Colors.white : Colors.black87)
                  : Colors.grey,
              ),
            ),
          ),

          // Time Display
          GestureDetector(
            onTap: enabled ? onTimeTap : null,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: enabled
                  ? accentColor.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _formatTimeOfDay(time),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: enabled ? accentColor : Colors.grey,
                ),
              ),
            ),
          ),

          SizedBox(width: 12),

          // Toggle Switch
          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: enabled,
              onChanged: onToggle,
              activeColor: accentColor,
              activeTrackColor: accentColor.withValues(alpha: 0.3),
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSettingItem(
      String title,
      String subtitle,
      IconData icon,
      Widget trailing, {
        required bool isDark,
        bool useAccentColor = false,
        bool isDisabled = false,
        VoidCallback? onTap,
      }) {
    final iconColor = useAccentColor
        ? (isDark ? Colors.cyanAccent : AppStatic.marianBlue)
        : (isDark ? Colors.pinkAccent : AppStatic.grape);
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.grey[400] : Colors.grey[600];

    Widget content = Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: isDisabled ? Colors.grey : iconColor,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isDisabled ? Colors.grey : textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDisabled ? Colors.grey : textSecondary,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );

    if (onTap != null && !isDisabled) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: content,
      );
    }

    return content;
  }

  Widget _buildDivider(Color color) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            color.withValues(alpha: 0.3),
            Colors.transparent,
          ],
        ),
      ),
    );
  }


  String _formatTimeOfDay(TimeOfDay tod) {
    final hour = tod.hour.toString().padLeft(2, '0');
    final minute = tod.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _selectTime(BuildContext context, String label, TimeOfDay currentTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: label == 'Notification 1'
                  ? Colors.orange
                  : label == 'Notification 2'
                      ? Colors.blue
                      : Colors.purple,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != currentTime) {
      setState(() {
        if (label == 'Notification 1') {
          _notification1Time = picked;
        } else if (label == 'Notification 2') {
          _notification2Time = picked;
        } else if (label == 'Notification 3') {
          _notification3Time = picked;
        }
      });

      await _saveSettings();

      // Reschedule notifications with new times
      if (_notificationsEnabled) {
        // Cancel existing before rescheduling to avoid duplicates
        await NotificationManager.cancelAllNotifications();
        await NotificationManager.scheduleDailyReminders();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification time updated to ${_formatTimeOfDay(picked)}'),
            backgroundColor: label == 'Notification 1'
                ? Colors.orange
                : label == 'Notification 2'
                    ? Colors.blue
                    : Colors.purple,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
