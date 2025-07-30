import 'dart:convert';
import 'dart:io';

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

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguageCode = 'en';

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
        });
        if (_darkModeEnabled) {
          themeModeNotifier.value = ThemeMode.dark;
        } else {
          themeModeNotifier.value = ThemeMode.light;
        }
        // Initialize or cancel notifications based on setting
        if (_notificationsEnabled) {
          await NotificationManager.scheduleDailyReminders();
        } else {
          await NotificationManager.cancelAllNotifications();
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
                                              await _saveSettings();
                                              if (value) {
                                                await NotificationManager.scheduleDailyReminders();
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('✅ Notifications enabled'),
                                                    backgroundColor: titleColor,
                                                    duration: Duration(seconds: 2),
                                                  ),
                                                );
                                              } else {
                                                await NotificationManager.cancelAllNotifications();
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('🔕 Notifications disabled'),
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
                                  ),
                                );
                              },
                            ),

                            SizedBox(height: 32),

                            // Debug Section
                            _buildDebugSection(isDark),

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

  Widget _buildDebugSection(bool isDark) {
    return Column(
      children: [
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
        FutureBuilder<Map<String, List<DateTime>>>(
          future: getAllNotificationTimes(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox();
            final data = snapshot.data!;
            final todayTimes = data['today']!;
            final tomorrowTimes = data['tomorrow']!;
            final now = DateTime.now();

            return Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.purple.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.purple, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Debug: Notification Times',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _buildDebugTimeSection(
                    'TODAY (${todayTimes[0].day}/${todayTimes[0].month})',
                    todayTimes,
                    now,
                    isDark,
                  ),
                  SizedBox(height: 12),
                  _buildDebugTimeSection(
                    'TOMORROW (${tomorrowTimes[0].day}/${tomorrowTimes[0].month})',
                    tomorrowTimes,
                    now,
                    isDark,
                    isTomorrow: true,
                  ),
                ],
              ),
            );
          },
        ),
      ],
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

  Widget _buildDebugTimeSection(
      String title,
      List<DateTime> times,
      DateTime now,
      bool isDark, {
        bool isTomorrow = false,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        ...times.asMap().entries.map((entry) {
          final index = entry.key;
          final time = entry.value;
          final label = index == 0 ? 'Morning' : 'Evening';
          final isPassed = !isTomorrow && time.isBefore(now);
          final statusColor = isPassed ? Colors.grey : Colors.green;
          final statusText = isTomorrow ? 'UPCOMING' : (isPassed ? 'PASSED' : 'UPCOMING');

          return Padding(
            padding: EdgeInsets.only(left: 16, bottom: 4),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '$label: ${_formatTime(time)} ($statusText)',
                  style: TextStyle(
                    fontSize: 13,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<Map<String, List<DateTime>>> getAllNotificationTimes() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final todayTimes = NotificationManager.calculateDailyNotificationTimes(today);
    final tomorrowTimes = NotificationManager.calculateDailyNotificationTimes(tomorrow);

    return {
      'today': todayTimes,
      'tomorrow': tomorrowTimes,
    };
  }
}
