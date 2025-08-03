import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import '../services/syntra_notification_service.dart';
import '../static.dart';

@pragma('vm:entry-point')
class NotificationManager {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Initialize timezone data in the main app isolate too
    tz.initializeTimeZones();

    // Set the local timezone properly - same as in background service
    try {
      // Try to get local timezone from system
      final now = DateTime.now();
      final offset = now.timeZoneOffset;
      print(
        'Main app detected timezone offset: ${offset.inHours}h ${offset.inMinutes % 60}m',
      );

      // For Germany/Europe, this should typically be Europe/Berlin
      String timezoneName = 'Europe/Berlin'; // Default for Germany

      // Try to set the timezone location
      final location = tz.getLocation(timezoneName);
      tz.setLocalLocation(location);
      print('Main app timezone set to: $timezoneName');
    } catch (e) {
      print('Could not set specific timezone in main app, trying UTC+1: $e');
      try {
        // Fallback to a fixed timezone
        tz.setLocalLocation(tz.getLocation('Europe/Berlin'));
        print('Main app timezone set to Europe/Berlin as fallback');
      } catch (e2) {
        print('Could not set any timezone in main app, using UTC: $e2');
        tz.setLocalLocation(tz.UTC);
      }
    }
    print('Main app final timezone location: ${tz.local}');

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
    await _notificationsPlugin.initialize(initializationSettings);

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
          print('🔐 Can schedule exact alarms: $canScheduleExactAlarms');

          if (canScheduleExactAlarms == false) {
            print(
              '❌ Exact alarms not permitted! This will cause scheduling issues.',
            );
            print(
              '💡 User should enable "Alarms & reminders" permission in Android settings',
            );
            // Note: We can't automatically request this permission, user must enable it manually
          }
        }
      } catch (e) {
        print('⚠️ Could not check exact alarm permission: $e');
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
      print('✅ Notification channels created successfully!');
    }
  }

  /// Calculates the daily motivation notification times for a given date
  /// This should be the single source of truth for notification times
  static List<DateTime> calculateDailyNotificationTimes([
    DateTime? targetDate,
  ]) {
    final date = targetDate ?? DateTime.now();

    // Use deterministic random based on the target date - SINGLE SEED PER DAY
    final random = Random(date.day + date.month + date.year);

    // First notification window (9 AM - 3 PM)
    final firstHour =
        AppStatic.motivationFirstHourStart +
        random.nextInt(AppStatic.motivationFirstHourRange);
    final firstMinute = random.nextInt(60);
    final firstScheduledTime = DateTime(
      date.year,
      date.month,
      date.day,
      firstHour,
      firstMinute,
    );

    // Second notification window (6 PM - 11 PM)
    final secondHour =
        AppStatic.motivationSecondHourStart +
        random.nextInt(AppStatic.motivationSecondHourRange);
    final secondMinute = random.nextInt(60);
    final secondScheduledTime = DateTime(
      date.year,
      date.month,
      date.day,
      secondHour,
      secondMinute,
    );

    return [firstScheduledTime, secondScheduledTime];
  }

  /// **NEW**: Calculates user-controlled notification times for a given date
  static Future<List<DateTime>> calculateUserControlledNotificationTimes([
    DateTime? targetDate,
  ]) async {
    final date = targetDate ?? DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    final List<DateTime> scheduledTimes = [];

    // Get user notification settings
    final morningEnabled = prefs.getBool('morningEnabled') ?? false;
    final afternoonEnabled = prefs.getBool('afternoonEnabled') ?? false;
    final eveningEnabled = prefs.getBool('eveningEnabled') ?? false;

    final morningTime = prefs.getString('morningTime') ?? AppStatic.defaultMorningTime;
    final afternoonTime = prefs.getString('afternoonTime') ?? AppStatic.defaultAfternoonTime;
    final eveningTime = prefs.getString('eveningTime') ?? AppStatic.defaultEveningTime;

    // Parse and create DateTime objects for enabled notifications
    if (morningEnabled) {
      final timeParts = morningTime.split(':');
      final scheduledTime = DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
      scheduledTimes.add(scheduledTime);
    }

    if (afternoonEnabled) {
      final timeParts = afternoonTime.split(':');
      final scheduledTime = DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
      scheduledTimes.add(scheduledTime);
    }

    if (eveningEnabled) {
      final timeParts = eveningTime.split(':');
      final scheduledTime = DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
      scheduledTimes.add(scheduledTime);
    }

    return scheduledTimes;
  }

  /// **NEW PROFESSIONAL SYSTEM**: Schedules daily reminders using SyntraNotificationService
  static Future<void> scheduleDailyReminders() async {
    final now = DateTime.now();
    print('📋 Scheduling user-controlled daily reminders with professional notification system...');

    // Initialize the professional notification service
    final notificationService = SyntraNotificationService.instance;
    if (!await notificationService.initialize()) {
      print('❌ Failed to initialize professional notification service');
      return;
    }

    // Request permissions using professional system
    final permissions = await notificationService.requestPermissions();
    if (!permissions.hasBasicPermission) {
      print('❌ No notification permissions granted');
      return;
    }

    if (!permissions.canScheduleExactAlarms) {
      print('⚠️ Warning: Exact alarm scheduling not available, notifications may be delayed');
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
          title: 'Syntra Motivation',
          body: AppStatic.motivationMessages[Random().nextInt(AppStatic.motivationMessages.length)],
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
        print('📅 Added today\'s $timeSlot notification for ${scheduledTime.hour}:${scheduledTime.minute.toString().padLeft(2, '0')}');
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
          title: 'Syntra Motivation',
          body: AppStatic.motivationMessages[Random().nextInt(AppStatic.motivationMessages.length)],
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
        print('📅 Added day +${dayOffset} notifications: $timeStrings');
      }
    }

    // Use professional batch scheduling for efficiency
    if (notifications.isNotEmpty) {
      print('🚀 Batch scheduling ${notifications.length} user-controlled notifications with professional system...');
      final result = await notificationService.batchScheduleNotifications(notifications);
      print('✅ Professional batch scheduling completed: ${result.successCount}/${notifications.length} successful');

      if (result.failureCount > 0) {
        print('⚠️ ${result.failureCount} notifications failed to schedule');
        // Log individual failures
        for (final notifResult in result.results) {
          if (!notifResult.success) {
            print('❌ Failed to schedule notification ID: ${notifResult.id}');
          }
        }
      }
    } else {
      print('ℹ️ No notifications to schedule (no times enabled or all times have passed)');
    }

    print('✅ User-controlled daily motivation notifications scheduled with professional system');
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
    print("📅 Legacy NotificationManager.sendNotification called, using professional system:");
    print("  - Title: $title");
    print("  - Body: $body");
    print("  - Scheduled for: $scheduledTime");

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
      print("✅ Professional notification scheduled successfully!");
    } else {
      print("❌ Professional notification scheduling failed");
    }

    return notificationId;
  }

  /// Test the professional notification system
  static Future<void> testProfessionalNotificationSystem() async {
    print('🧪 TESTING PROFESSIONAL NOTIFICATION SYSTEM...');
    final now = DateTime.now();
    print(
      '🧪 Current time: ${now.hour}:${now.minute.toString().padLeft(2, '0')} on ${now.day}/${now.month}/${now.year}',
    );

    // Test immediate notification
    print('🧪 Testing immediate notification...');
    await sendImmediateNotification(
      title: '🧪 Professional Test',
      body: 'This is an immediate test using the professional system!',
      data: {'test_type': 'immediate'},
    );

    // Test scheduled notification (30 seconds from now)
    print('🧪 Testing scheduled notification...');
    final testTime = now.add(const Duration(seconds: 30));
    final success = await scheduleNotification(
      title: '🧪 Scheduled Professional Test',
      body: 'This notification was scheduled using the professional system!',
      scheduledTime: testTime,
      data: {'test_type': 'scheduled'},
    );

    if (success) {
      print('✅ Professional scheduled test notification set for 30 seconds');
    } else {
      print('❌ Failed to schedule professional test notification');
    }

    // Test the daily reminder calculation
    final times = calculateDailyNotificationTimes();
    print('🧪 Calculated daily reminder times: ${times[0]} and ${times[1]}');

    print('🧪 Professional notification system test completed!');
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
    print('📋 Scheduling single daily reminder at $hour:$minute with ID $id');

    // Initialize the professional notification service
    final notificationService = SyntraNotificationService.instance;
    if (!await notificationService.initialize()) {
      print('❌ Failed to initialize professional notification service');
      return;
    }

    // Request permissions
    final permissions = await notificationService.requestPermissions();
    if (!permissions.hasBasicPermission) {
      print('❌ No notification permissions granted');
      return;
    }

    // Calculate the next occurrence of this time
    final now = DateTime.now();
    DateTime scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);

    // If the time has already passed today, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    // Create notification request
    final notification = NotificationRequest(
      id: id,
      title: 'Syntra Erinnerung',
      body: AppStatic.motivationMessages[Random().nextInt(AppStatic.motivationMessages.length)],
      scheduledTime: scheduledTime,
      channel: NotificationChannel.reminders,
      data: {
        'type': 'custom_reminder',
        'custom_id': id.toString(),
      },
    );

    // Schedule the notification
    final success = await notificationService.scheduleExactNotification(
      id: id,
      title: 'Syntra Erinnerung',
      body: AppStatic.motivationMessages[Random().nextInt(AppStatic.motivationMessages.length)],
      scheduledTime: scheduledTime,
      data: {
        'type': 'custom_reminder',
        'custom_id': id.toString(),
      },
      channel: NotificationChannel.reminders,
    );
    if (success) {
      print('✅ Successfully scheduled custom reminder for ${scheduledTime.toString()}');
    } else {
      print('❌ Failed to schedule custom reminder');
    }
  }

  /// Cancel a specific notification by ID
  static Future<void> cancelNotification(int id) async {
    print('🗑️ Cancelling notification with ID $id');

    final notificationService = SyntraNotificationService.instance;
    await notificationService.cancelNotification(id);

    print('✅ Notification $id cancelled');
  }

  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    // Note: Professional system doesn't have cancelAll, but individual cancellations
    // could be implemented if needed
  }
}
