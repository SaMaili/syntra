import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../data/settings_repository.dart';
import '../services/syntra_notification_service.dart';
import '../static.dart';

@pragma('vm:entry-point')
class NotificationManager {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Check if notifications are enabled in settings
  static Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
  }

  /// Cancel all scheduled notifications
  static Future<void> cancelAllNotifications() async {
    try {
      debugPrint('🚫 Cancelling all notifications comprehensively...');

      // Cancel Flutter local notifications first
      await _notificationsPlugin.cancelAll();
      debugPrint('✅ Flutter local notifications cancelled');

      // Cancel notifications via professional service
      final notificationService = SyntraNotificationService.instance;
      await notificationService.cancelAllNotifications();
      debugPrint('✅ Professional service notifications cancelled');

      // IMPORTANT: Do NOT modify user preference flags or times here
      // We only cancel scheduled notifications. The UI owns preference states.

      // Cancel any system-level scheduled notifications (but handle the missing implementation gracefully)
      if (Platform.isAndroid) {
        try {
          const platform = MethodChannel('app.inneract.syntra/notifications');
          await platform.invokeMethod('cancelAllNotifications');
          debugPrint('✅ Android system notifications cancelled');
        } catch (e) {
          if (e.toString().contains('MissingPluginException')) {
            debugPrint('ℹ️ Native cancelAllNotifications method not implemented (using Flutter fallback)');
          } else {
            debugPrint('⚠️ Could not cancel Android system notifications: $e');
          }
        }
      }

      // Additional cleanup: Clear any stored notification data
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('syntra_scheduled_notifications');
        debugPrint('✅ Stored notification data cleared');
      } catch (e) {
        debugPrint('⚠️ Could not clear stored notification data: $e');
      }

      debugPrint('✅ All notifications cancelled comprehensively');
    } catch (e) {
      debugPrint('❌ Error cancelling notifications: $e');
    }
  }

  static Future<void> initialize() async {
    // Initialize timezone data in the main app isolate too
    tz.initializeTimeZones();

    // Set the local timezone properly - same as in background service
    try {
      // Try to get local timezone from system
      final now = DateTime.now();
      final offset = now.timeZoneOffset;
      debugPrint(
        'Main app detected timezone offset: ${offset.inHours}h ${offset.inMinutes % 60}m',
      );

      // For Germany/Europe, this should typically be Europe/Berlin
      String timezoneName = 'Europe/Berlin'; // Default for Germany

      // Try to set the timezone location
      final location = tz.getLocation(timezoneName);
      tz.setLocalLocation(location);
      debugPrint('Main app timezone set to: $timezoneName');
    } catch (e) {
      debugPrint('Could not set specific timezone in main app, trying UTC+1: $e');
      try {
        // Fallback to a fixed timezone
        tz.setLocalLocation(tz.getLocation('Europe/Berlin'));
        debugPrint('Main app timezone set to Europe/Berlin as fallback');
      } catch (e2) {
        debugPrint('Could not set any timezone in main app, using UTC: $e2');
        tz.setLocalLocation(tz.UTC);
      }
    }
    debugPrint('Main app final timezone location: ${tz.local}');

    // Initialization settings for Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/syntrabird_notification');
    // iOS settings to request permissions during initialization
    const DarwinInitializationSettings initializationSettingsIos =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIos,
          macOS: initializationSettingsIos,
        );
    await _notificationsPlugin.initialize(settings: initializationSettings);

    // Create notification channels for Android
    await _createNotificationChannels();

    // Request iOS notification permissions
    final iosPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(alert: true, badge: true, sound: true);
    }
    // Request Android notification permission using permission_handler (Android 13+)
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (status.isDenied) {
        await Permission.notification.request();
      }

      // Check and request exact alarm permission (Android 12+)
      await _checkAndRequestExactAlarmPermission();
    }
  }

  /// Check and request exact alarm permission for Android 12+
  static Future<void> _checkAndRequestExactAlarmPermission() async {
    if (Platform.isAndroid) {
      try {
        // Check if exact alarms are allowed
        final androidPlugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

        if (androidPlugin != null) {
          final canScheduleExactAlarms = await androidPlugin
              .canScheduleExactNotifications();
          debugPrint('🔐 Can schedule exact alarms: $canScheduleExactAlarms');

          if (canScheduleExactAlarms == false) {
            debugPrint(
              '❌ Exact alarms not permitted! This will cause scheduling issues.',
            );
            debugPrint(
              '💡 User should enable "Alarms & reminders" permission in Android settings',
            );
            // Note: We can't automatically request this permission, user must enable it manually
          }
        }
      } catch (e) {
        debugPrint('⚠️ Could not check exact alarm permission: $e');
      }
    }
  }

  static Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel testChannel = AndroidNotificationChannel(
      'test_channel',
      'Test Notifications',
      description: 'Test notifications from Syntra',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    const AndroidNotificationChannel challengeTimerChannel =
        AndroidNotificationChannel(
          'challenge_timer', // Match the ActiveChallengeLogic channel ID
          'Challenge Timer',
          description: 'Notification for challenge timer',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        );

    const AndroidNotificationChannel motivationChannel =
        AndroidNotificationChannel(
          'motivation_channel',
          'Motivation Notifications',
          description: 'Motivational reminders from Syntra',
          importance: Importance.defaultImportance,
          playSound: true,
          enableVibration: true,
        );

    // Create the channels
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(testChannel);
      await androidPlugin.createNotificationChannel(challengeTimerChannel);
      await androidPlugin.createNotificationChannel(motivationChannel);
      debugPrint('✅ Notification channels created successfully!');
    }
  }

  /// **NEW**: Calculates user-controlled notification times for a given date
  static Future<List<DateTime>> calculateUserControlledNotificationTimes([
    DateTime? targetDate,
  ]) async {
    final date = targetDate ?? DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    final List<DateTime> scheduledTimes = [];

    // Check if notifications are enabled globally
    final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    if (!notificationsEnabled) {
      debugPrint('🚫 Global notifications disabled - returning empty schedule');
      return scheduledTimes;
    }

    // Detect if user has configured any slot settings previously
    final hasSlotSettings =
        prefs.containsKey('notification1Enabled') ||
        prefs.containsKey('notification2Enabled') ||
        prefs.containsKey('notification3Enabled');

    // Get user notification settings - check for specific time slot settings
    final notification1Enabled = prefs.getBool('notification1Enabled') ?? false;
    final notification2Enabled = prefs.getBool('notification2Enabled') ?? false;
    final notification3Enabled = prefs.getBool('notification3Enabled') ?? false;

    debugPrint('🔎 Slot state @${date.toIso8601String()} | hasSlots=$hasSlotSettings, n1=$notification1Enabled, n2=$notification2Enabled, n3=$notification3Enabled');

    // If no specific time slots are configured at all, use default schedule
    if (!hasSlotSettings) {
      debugPrint('📅 No slot settings found - using default schedule');

      // Default notification times: morning, afternoon, evening
      final defaultTimes = [
        '09:00', // Morning
        '14:00', // Afternoon
        '19:00', // Evening
      ];

      for (final timeString in defaultTimes) {
        final timeParts = timeString.split(':');
        final scheduledTime = DateTime(
          date.year,
          date.month,
          date.day,
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );
        scheduledTimes.add(scheduledTime);
        debugPrint('📅 Added default notification time: $timeString');
      }

      return scheduledTimes;
    }

    // If user has slot settings but all are disabled, schedule none
    if (!notification1Enabled && !notification2Enabled && !notification3Enabled) {
      debugPrint('🚫 All individual notification slots are disabled - no reminders scheduled');
      return scheduledTimes; // empty
    }

    // Use user-configured specific time slots (stored as separate hour/minute ints)
    final hour1 = prefs.getInt('notification1TimeHour') ?? 9;
    final min1  = prefs.getInt('notification1TimeMinute') ?? 0;
    final hour2 = prefs.getInt('notification2TimeHour') ?? 14;
    final min2  = prefs.getInt('notification2TimeMinute') ?? 0;
    final hour3 = prefs.getInt('notification3TimeHour') ?? 19;
    final min3  = prefs.getInt('notification3TimeMinute') ?? 0;

    if (notification1Enabled) {
      scheduledTimes.add(DateTime(date.year, date.month, date.day, hour1, min1));
    }

    if (notification2Enabled) {
      scheduledTimes.add(DateTime(date.year, date.month, date.day, hour2, min2));
    }

    if (notification3Enabled) {
      scheduledTimes.add(DateTime(date.year, date.month, date.day, hour3, min3));
    }

    return scheduledTimes;
  }

  /// **NEW PROFESSIONAL SYSTEM**: Schedules daily reminders using SyntraNotificationService
  static Future<void> scheduleDailyReminders() async {
    // Check if notifications are enabled in settings
    if (!await areNotificationsEnabled()) {
      debugPrint('🚫 Notifications disabled in settings - skipping scheduling');
      return;
    }

    final now = DateTime.now();
    debugPrint('📋 Scheduling user-controlled daily reminders with professional notification system...');

    // Determine locale for localized title/body
    final localeCode = await SettingsRepository.instance.loadLanguage() ?? 'en';

    // Initialize the professional notification service
    final notificationService = SyntraNotificationService.instance;
    if (!await notificationService.initialize()) {
      debugPrint('❌ Failed to initialize professional notification service');
      return;
    }

    // Request permissions using professional system
    final permissions = await notificationService.requestPermissions();
    if (!permissions.hasBasicPermission) {
      debugPrint('❌ No notification permissions granted');
      return;
    }

    if (!permissions.canScheduleExactAlarms) {
      debugPrint('⚠️ Warning: Exact alarm scheduling not available, notifications may be delayed');
    }

    // Prepare notifications for today and the next 7 days for maximum resilience
    final notifications = <NotificationRequest>[];

    // Get today's user-controlled notification times
    final todayTimes = await calculateUserControlledNotificationTimes(now);
    for (int i = 0; i < todayTimes.length; i++) {
      final scheduledTime = todayTimes[i];
      if (scheduledTime.isAfter(now)) {
        final notificationId = (scheduledTime.millisecondsSinceEpoch % 2147483647).toInt();
        final timeSlot = _getTimeSlot(scheduledTime.hour);
        notifications.add(NotificationRequest(
          id: notificationId,
          title: AppStatic.localizedMotivationTitle(localeCode),
          body: AppStatic.randomMotivationMessage(localeCode),
          scheduledTime: scheduledTime,
          channel: NotificationChannel.reminders,
          data: {
            'type': 'daily_reminder',
            'day': now.day.toString(),
            'month': now.month.toString(),
            'year': now.year.toString(),
            'time_slot': timeSlot,
          },
        ));
        debugPrint('📅 Added today\'s $timeSlot notification for ${scheduledTime.hour}:${scheduledTime.minute.toString().padLeft(2, '0')}');
      }
    }

    // Schedule notifications for the next 7 days (massive resilience improvement)
    for (int dayOffset = 1; dayOffset <= 7; dayOffset++) {
      final targetDate = now.add(Duration(days: dayOffset));
      final dayTimes = await calculateUserControlledNotificationTimes(targetDate);

      for (int i = 0; i < dayTimes.length; i++) {
        final scheduledTime = dayTimes[i];
        final notificationId = (scheduledTime.millisecondsSinceEpoch % 2147483647).toInt();
        final timeSlot = _getTimeSlot(scheduledTime.hour);
        notifications.add(NotificationRequest(
          id: notificationId,
          title: AppStatic.localizedMotivationTitle(localeCode),
          body: AppStatic.randomMotivationMessage(localeCode),
          scheduledTime: scheduledTime,
          channel: NotificationChannel.reminders,
          data: {
            'type': 'daily_reminder',
            'day': targetDate.day.toString(),
            'month': targetDate.month.toString(),
            'year': targetDate.year.toString(),
            'time_slot': timeSlot,
          },
        ));
      }

      if (dayTimes.isNotEmpty) {
        final timeStrings = dayTimes.map((t) => '${t.hour}:${t.minute.toString().padLeft(2, '0')}').join(', ');
        debugPrint('📅 Added day +$dayOffset notifications: $timeStrings');
      }
    }

    // Use professional batch scheduling for efficiency
    if (notifications.isNotEmpty) {
      debugPrint('🚀 Batch scheduling ${notifications.length} user-controlled notifications with professional system...');
      final result = await notificationService.batchScheduleNotifications(notifications);
      debugPrint('✅ Professional batch scheduling completed: ${result.successCount}/${notifications.length} successful');

      if (result.failureCount > 0) {
        debugPrint('⚠️ ${result.failureCount} notifications failed to schedule');
        // Log individual failures
        for (final notifResult in result.results) {
          if (!notifResult.success) {
            debugPrint('❌ Failed to schedule notification ID: ${notifResult.id}');
          }
        }
      }
    } else {
      debugPrint('ℹ️ No notifications to schedule (no times enabled or all times have passed)');
    }

    debugPrint('✅ User-controlled daily motivation notifications scheduled with professional system');
  }

  /// Helper method to determine time slot based on hour
  static String _getTimeSlot(int hour) {
    if (hour < 12) {
      return 'morning';
    } else if (hour < 17) {
      return 'afternoon';
    } else {
      return 'evening';
    }
  }

  /// Schedule a single notification using the professional system
  static Future<bool> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    Map<String, String> data = const {},
    NotificationChannel channel = NotificationChannel.reminders,
  }) async {
    // Respect global notifications toggle
    if (!await areNotificationsEnabled()) {
      debugPrint('🚫 Notifications disabled - skipping scheduleNotification for $scheduledTime');
      return false;
    }

    final notificationService = SyntraNotificationService.instance;

    // Generate unique ID
    final notificationId = (scheduledTime.millisecondsSinceEpoch % 2147483647).toInt();

    return await notificationService.scheduleExactNotification(
      id: notificationId,
      title: title,
      body: body,
      scheduledTime: scheduledTime,
      data: data,
      channel: channel,
    );
  }

  /// Send an immediate notification using the professional system
  static Future<void> sendImmediateNotification({
    required String title,
    required String body,
    Map<String, String> data = const {},
    NotificationChannel channel = NotificationChannel.reminders,
    // Legacy parameters for backward compatibility
    String? channelId,
    String? channelName,
    String? channelDescription,
    bool? vibration,
  }) async {
    // Respect global notifications toggle
    if (!await areNotificationsEnabled()) {
      debugPrint('🚫 Notifications disabled - skipping sendImmediateNotification');
      return;
    }

    final notificationService = SyntraNotificationService.instance;

    // Generate unique ID
    final notificationId = (DateTime.now().millisecondsSinceEpoch % 2147483647).toInt();

    await notificationService.showNotificationNow(
      id: notificationId,
      title: title,
      body: body,
      data: data,
      channel: channel,
    );
  }

  /// Legacy sendNotification method for backward compatibility with challenge notifications
  static Future<int> sendNotification({
    required String channelId,
    required String channelName,
    required String channelDescription,
    required String title,
    required String body,
    required bool vibration,
    required DateTime scheduledTime,
  }) async {
    // Respect global notifications toggle
    if (!await areNotificationsEnabled()) {
      debugPrint('🚫 Notifications disabled - skipping legacy sendNotification for $scheduledTime');
      return -1;
    }

    debugPrint("📅 Legacy NotificationManager.sendNotification called, using professional system:");
    debugPrint("  - Title: $title");
    debugPrint("  - Body: $body");
    debugPrint("  - Scheduled for: $scheduledTime");

    // Use the professional notification system
    final notificationService = SyntraNotificationService.instance;
    final notificationId = (scheduledTime.millisecondsSinceEpoch % 2147483647).toInt();

    final success = await notificationService.scheduleExactNotification(
      id: notificationId,
      title: title,
      body: body,
      scheduledTime: scheduledTime,
      data: {'legacy_channel': channelId},
      channel: NotificationChannel.reminders,
    );

    if (success) {
      debugPrint("✅ Professional notification scheduled successfully!");
    } else {
      debugPrint("❌ Professional notification scheduling failed");
    }

    return notificationId;
  }

  /// Test the professional notification system
  static Future<void> testProfessionalNotificationSystem() async {
    debugPrint('🧪 TESTING PROFESSIONAL NOTIFICATION SYSTEM...');
    final now = DateTime.now();
    debugPrint(
      '🧪 Current time: ${now.hour}:${now.minute.toString().padLeft(2, '0')} on ${now.day}/${now.month}/${now.year}',
    );

    // Test immediate notification
    debugPrint('🧪 Testing immediate notification...');
    await sendImmediateNotification(
      title: '🧪 Professional Test',
      body: 'This is an immediate test using the professional system!',
      data: {'test_type': 'immediate'},
    );

    // Test scheduled notification (30 seconds from now)
    debugPrint('🧪 Testing scheduled notification...');
    final testTime = now.add(const Duration(seconds: 30));
    final success = await scheduleNotification(
      title: '🧪 Scheduled Professional Test',
      body: 'This notification was scheduled using the professional system!',
      scheduledTime: testTime,
      data: {'test_type': 'scheduled'},
    );

    if (success) {
      debugPrint('✅ Professional scheduled test notification set for 30 seconds');
    } else {
      debugPrint('❌ Failed to schedule professional test notification');
    }

    // Test the daily reminder calculation

    debugPrint('🧪 Professional notification system test completed!');
  }

  /// Legacy method for backward compatibility
  static Future<void> testNotificationSystem() async {
    await testProfessionalNotificationSystem();
  }

  /// Schedule a single daily reminder at specific time
  static Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required int id,
  }) async {
    debugPrint('📋 Scheduling single daily reminder at $hour:$minute with ID $id');

    // Initialize the professional notification service
    final notificationService = SyntraNotificationService.instance;
    if (!await notificationService.initialize()) {
      debugPrint('❌ Failed to initialize professional notification service');
      return;
    }

    // Request permissions
    final permissions = await notificationService.requestPermissions();
    if (!permissions.hasBasicPermission) {
      debugPrint('❌ No notification permissions granted');
      return;
    }

    // Determine locale for localized title/body
    final localeCode = await SettingsRepository.instance.loadLanguage() ?? 'en';

    // Calculate the next occurrence of this time
    final now = DateTime.now();
    DateTime scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);

    // If the time has already passed today, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    // Schedule the notification
    final success = await notificationService.scheduleExactNotification(
      id: id,
      title: AppStatic.localizedMotivationTitle(localeCode),
      body: AppStatic.randomMotivationMessage(localeCode),
      scheduledTime: scheduledTime,
      data: {
        'type': 'custom_reminder',
        'custom_id': id.toString(),
      },
      channel: NotificationChannel.reminders,
    );
    if (success) {
      debugPrint('✅ Successfully scheduled custom reminder for ${scheduledTime.toString()}');
    } else {
      debugPrint('❌ Failed to schedule custom reminder');
    }
  }

  /// Cancel a specific notification by ID
  static Future<void> cancelNotification(int id) async {
    debugPrint('🗑️ Cancelling notification with ID $id');

    final notificationService = SyntraNotificationService.instance;
    await notificationService.cancelNotification(id);

    debugPrint('✅ Notification $id cancelled');
  }
}
