import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../static.dart';

@pragma('vm:entry-point')
class NotificationManager {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Initialize timezone data in the main app isolate too
    tz_data.initializeTimeZones();

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
        AndroidInitializationSettings('@mipmap/ic_launcher');
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
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        );

    const AndroidNotificationChannel backgroundServiceChannel =
        AndroidNotificationChannel(
          'syntra_bg_service',
          'Background Service',
          description:
              'Keeps Syntra running to deliver motivation reminders on time',
          importance: Importance.min,
          // Changed from low to min for maximum discretion
          playSound: false,
          enableVibration: false,
          enableLights: false,
          // Disable LED lights
          showBadge: false, // Don't show badge count
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
      await androidPlugin.createNotificationChannel(backgroundServiceChannel);
      print('✅ Notification channels created successfully!');
    }
  }

  static Future<void> startBackgroundService() async {
    await FlutterBackgroundService().configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        // enable foreground service
        autoStartOnBoot: true,
        notificationChannelId: 'syntra_bg_service',
        // Use our custom channel
        initialNotificationTitle: 'Syntra',
        initialNotificationContent: 'Keeping reminders ready for you',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        // TODO: Implement for iOS
        autoStart: false,
      ),
    );
    // Only start the service manually after configuration
    try {
      final isRunning = await FlutterBackgroundService().isRunning();
      if (!isRunning) {
        await FlutterBackgroundService().startService();
        print('Background service started successfully');
      } else {
        print('Background service already running');
      }
    } catch (e) {
      print('Error starting background service: $e');
    }
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    print('Background service onStart called');

    // Ensure plugins are initialized immediately
    DartPluginRegistrant.ensureInitialized();
    print('DartPluginRegistrant initialized');

    // Initialize timezone data in the background service isolate
    tz_data.initializeTimeZones();

    // Set the local timezone properly - try to detect it automatically
    try {
      // Try to get local timezone from system
      final now = DateTime.now();
      final offset = now.timeZoneOffset;
      print(
        'Detected timezone offset: ${offset.inHours}h ${offset.inMinutes % 60}m',
      );

      // For Germany/Europe, this should typically be Europe/Berlin
      // But let's use a more robust approach
      String timezoneName = 'Europe/Berlin'; // Default for Germany

      // Try to set the timezone location
      final location = tz.getLocation(timezoneName);
      tz.setLocalLocation(location);
      print('Timezone set to: $timezoneName');
    } catch (e) {
      print('Could not set specific timezone, trying UTC+1: $e');
      try {
        // Fallback to a fixed timezone
        tz.setLocalLocation(tz.getLocation('Europe/Berlin'));
        print('Timezone set to Europe/Berlin as fallback');
      } catch (e2) {
        print('Could not set any timezone, using UTC: $e2');
        tz.setLocalLocation(tz.UTC);
      }
    }
    print('Final timezone location: ${tz.local}');

    // Initialize notifications in the background service
    try {
      await initialize();
      print('Notifications initialized successfully');
    } catch (e) {
      print('Error initializing notifications in background service: $e');
      return; // Exit if notifications can't be initialized
    }

    // Send an IMMEDIATE test notification to verify the service is working
    try {
      print('Attempting to send immediate test notification');
      await _notificationsPlugin.show(
        123, // Simple ID
        'Syntra Test',
        'Background service is working! This is an immediate notification.',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'test_channel',
            'Test Notifications',
            channelDescription: 'Test notifications from Syntra',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          ),
        ),
      );
      print('Immediate test notification sent successfully');
    } catch (e) {
      print('Failed to send immediate notification: $e');
    }

    print('Background service setup completed');

    // Use the new timer-based approach for motivation notifications
    await _scheduleTimerBasedMotivationNotifications();

    // Check every hour to reschedule notifications if needed
    Timer.periodic(const Duration(hours: 1), (timer) async {
      final now = DateTime.now();
      print(
        '🕐 Hourly check at ${now.hour}:${now.minute.toString().padLeft(2, '0')} on ${now.day}/${now.month}/${now.year}',
      );

      // Reschedule notifications if it's a new day
      if (now.hour == 0) {
        print('🗓️ New day detected, rescheduling daily notifications');
        await _scheduleTimerBasedMotivationNotifications();
      }
    });
  }

  /// NEW: Timer-based motivation notification scheduling (reliable approach)
  static Future<void> _scheduleTimerBasedMotivationNotifications() async {
    final now = DateTime.now();
    print('📋 Scheduling timer-based motivation notifications...');

    // Get today's notification times
    final todayTimes = calculateDailyNotificationTimes(now);
    final firstTime = todayTimes[0];
    final secondTime = todayTimes[1];

    // Schedule today's notifications if they're in the future
    if (firstTime.isAfter(now)) {
      final duration = firstTime.difference(now);
      print(
        '⏰ Setting timer for first notification: ${duration.inMinutes} minutes from now',
      );
      Timer(duration, () async {
        print('🔔 Timer fired: Sending morning motivation notification');
        await sendImmediateNotification(
          channelId: 'motivation_channel',
          channelName: 'Motivation Notifications',
          channelDescription: 'Motivational reminders from Syntra',
          title: 'Syntra Motivation',
          body:
              AppStatic.motivationMessages[Random().nextInt(
                AppStatic.motivationMessages.length,
              )],
          vibration: true,
        );
      });
    } else {
      print('⏭️ Skipping first notification for today (time has passed)');
    }

    if (secondTime.isAfter(now)) {
      final duration = secondTime.difference(now);
      print(
        '⏰ Setting timer for second notification: ${duration.inMinutes} minutes from now',
      );
      Timer(duration, () async {
        print('🔔 Timer fired: Sending evening motivation notification');
        await sendImmediateNotification(
          channelId: 'motivation_channel',
          channelName: 'Motivation Notifications',
          channelDescription: 'Motivational reminders from Syntra',
          title: 'Syntra Motivation',
          body:
              AppStatic.motivationMessages[Random().nextInt(
                AppStatic.motivationMessages.length,
              )],
          vibration: true,
        );
      });
    } else {
      print('⏭️ Skipping second notification for today (time has passed)');
    }

    // Schedule tomorrow's notifications
    final tomorrow = now.add(const Duration(days: 1));
    final tomorrowTimes = calculateDailyNotificationTimes(tomorrow);

    for (int i = 0; i < tomorrowTimes.length; i++) {
      final notificationTime = tomorrowTimes[i];
      final duration = notificationTime.difference(now);
      final timeLabel = i == 0 ? 'morning' : 'evening';

      print(
        '⏰ Setting timer for tomorrow\'s $timeLabel notification: ${duration.inHours} hours from now',
      );
      Timer(duration, () async {
        print(
          '🔔 Timer fired: Sending tomorrow\'s $timeLabel motivation notification',
        );
        await sendImmediateNotification(
          channelId: 'motivation_channel',
          channelName: 'Motivation Notifications',
          channelDescription: 'Motivational reminders from Syntra',
          title: 'Syntra Motivation',
          body:
              AppStatic.motivationMessages[Random().nextInt(
                AppStatic.motivationMessages.length,
              )],
          vibration: true,
        );
      });
    }

    print('✅ Timer-based motivation notifications scheduled successfully!');
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

  /// Schedules motivation notifications for today and tomorrow
  static Future<void> _scheduleDailyMotivationNotifications() async {
    final now = DateTime.now();
    print('📋 Scheduling daily motivation notifications...');

    // Schedule for today
    await _scheduleMotivationNotificationsForDate(now);

    // Schedule the 12:05 notification for today
    final twelveOhFiveToday = DateTime(now.year, now.month, now.day, 12, 10);
    if (twelveOhFiveToday.isAfter(now)) {
      print('📅 SCHEDULING 12:05 NOTIFICATION for today');
      await sendNotification(
        channelId: 'motivation_channel',
        channelName: 'Motivation Notifications',
        channelDescription: 'Daily 12:05 Reminder',
        title: 'Syntra Daily Check-in',
        body: "How's your day going? Remember your goals!",
        vibration: true,
        scheduledTime: twelveOhFiveToday,
      );
    } else {
      print('⏭️ Skipping 12:05 notification for today (time has passed)');
    }
    // Schedule for tomorrow
    final tomorrow = now.add(const Duration(days: 1));
    await _scheduleMotivationNotificationsForDate(tomorrow);

    print('✅ Daily motivation notifications scheduled for today and tomorrow');
  }

  /// Schedules motivation notifications for a specific date
  static Future<void> _scheduleMotivationNotificationsForDate(
    DateTime date,
  ) async {
    final now = DateTime.now();

    // Use the centralized calculation method - SINGLE SOURCE OF TRUTH
    final scheduledTimes = calculateDailyNotificationTimes(date);
    final firstScheduledTime = scheduledTimes[0];
    final secondScheduledTime = scheduledTimes[1];

    // Only schedule if the time is in the future
    if (firstScheduledTime.isAfter(now)) {
      print('📅 SCHEDULING MOTIVATION NOTIFICATION 1:');
      print('  - Date: ${date.day}/${date.month}/${date.year}');
      print(
        '  - Scheduled for: ${firstScheduledTime.hour}:${firstScheduledTime.minute.toString().padLeft(2, '0')}',
      );
      print(
        '  - Window: ${AppStatic.motivationFirstHourStart}:00 - ${AppStatic.motivationFirstHourStart + AppStatic.motivationFirstHourRange - 1}:59',
      );
      print(
        '  - Time until notification: ${firstScheduledTime.difference(now).inMinutes} minutes',
      );

      await sendNotification(
        channelId: 'motivation_channel',
        channelName: 'Motivation Notifications',
        channelDescription: 'Motivational reminders from Syntra',
        title: 'Syntra Motivation',
        body:
            AppStatic.motivationMessages[Random().nextInt(
              AppStatic.motivationMessages.length,
            )],
        vibration: true,
        scheduledTime: firstScheduledTime,
      );
    } else {
      print(
        '⏭️ Skipping first notification for ${date.day}/${date.month} (time has passed)',
      );
    }

    if (secondScheduledTime.isAfter(now)) {
      print('📅 SCHEDULING MOTIVATION NOTIFICATION 2:');
      print('  - Date: ${date.day}/${date.month}/${date.year}');
      print(
        '  - Scheduled for: ${secondScheduledTime.hour}:${secondScheduledTime.minute.toString().padLeft(2, '0')}',
      );
      print(
        '  - Window: ${AppStatic.motivationSecondHourStart}:00 - ${AppStatic.motivationSecondHourStart + AppStatic.motivationSecondHourRange - 1}:59',
      );
      print(
        '  - Time until notification: ${secondScheduledTime.difference(now).inMinutes} minutes',
      );

      await sendNotification(
        channelId: 'motivation_channel',
        channelName: 'Motivation Notifications',
        channelDescription: 'Motivational reminders from Syntra',
        title: 'Syntra Motivation',
        body:
            AppStatic.motivationMessages[Random().nextInt(
              AppStatic.motivationMessages.length,
            )],
        vibration: true,
        scheduledTime: secondScheduledTime,
      );
    } else {
      print(
        '⏭️ Skipping second notification for ${date.day}/${date.month} (time has passed)',
      );
    }
  }

  static Future<int> sendNotification({
    required String channelId,
    required String channelName,
    required String channelDescription,
    required String title,
    required String body,
    required bool vibration,
    required DateTime scheduledTime,
  }) async {
    print("📅 NotificationManager.sendNotification called:");
    print("  - Title: $title");
    print("  - Body: $body");
    print("  - Scheduled for: $scheduledTime");
    print(
      "  - Time until notification: ${scheduledTime.difference(DateTime.now()).inSeconds} seconds",
    );

    // Generate a proper 32-bit notification ID
    final int notificationId =
        (DateTime.now().millisecondsSinceEpoch % 2147483647).toInt();
    print("  - Notification ID: $notificationId");

    // Check if time is in the past
    if (scheduledTime.isBefore(DateTime.now())) {
      print("❌ CRITICAL ERROR: Trying to schedule notification in the past!");
      print("  - Current time: ${DateTime.now()}");
      print("  - Scheduled time: $scheduledTime");
      return notificationId;
    }

    try {
      print("🎯 Attempting exact alarm scheduling...");

      // Convert to timezone-aware datetime
      final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);
      print("  - Timezone converted time: $tzScheduledTime");
      print("  - Local timezone: ${tz.local}");

      // First try with exact alarm
      await _notificationsPlugin.zonedSchedule(
        notificationId,
        title,
        body,
        tzScheduledTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDescription,
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: vibration,
            visibility: NotificationVisibility.public,
            fullScreenIntent: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      print("✅ Exact alarm notification scheduled successfully!");
    } catch (e) {
      print('❌ Exact alarm failed: $e');
      print('🔄 Trying with inexact alarm...');
      // Fallback to inexact alarm if exact alarms are not permitted
      try {
        await _notificationsPlugin.zonedSchedule(
          notificationId,
          title,
          body,
          tz.TZDateTime.from(scheduledTime, tz.local),
          NotificationDetails(
            android: AndroidNotificationDetails(
              channelId,
              channelName,
              channelDescription: channelDescription,
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
              enableVibration: vibration,
              visibility: NotificationVisibility.public,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexact,
        );
        print("✅ Inexact alarm notification scheduled successfully!");
      } catch (e2) {
        print('❌ Inexact alarm also failed: $e2');
        print('🔄 Trying immediate notification as fallback...');
        // If both fail, try immediate notification
        await _notificationsPlugin.show(
          notificationId,
          title,
          body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channelId,
              channelName,
              channelDescription: channelDescription,
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
              enableVibration: vibration,
            ),
          ),
        );
        print("✅ Immediate notification sent as fallback!");
      }
    }
    // Return the ID for possible cancellation
    return notificationId;
  }

  /// Cancel a scheduled notification by its ID
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
    print('Cancelled notification with ID: $id');
  }

  static Future<void> sendImmediateNotification({
    required String channelId,
    required String channelName,
    required String channelDescription,
    required String title,
    required String body,
    required bool vibration,
  }) async {
    print("🚨 Sending immediate notification:");
    print("  - Title: $title");
    print("  - Body: $body");

    // Generate a proper 32-bit notification ID
    final notificationId = (DateTime.now().millisecondsSinceEpoch % 2147483647)
        .toInt();
    print("  - Notification ID: $notificationId");

    try {
      await _notificationsPlugin.show(
        notificationId,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDescription,
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: vibration,
            ongoing: false,
            autoCancel: true,
          ),
        ),
      );
      print("✅ Immediate notification sent successfully!");
    } catch (e) {
      print("❌ Failed to send immediate notification: $e");
    }
  }

  /// TEST FUNCTION - Call this to immediately test notification scheduling
  static Future<void> testNotificationSystem() async {
    print('🧪 TESTING NOTIFICATION SYSTEM...');
    final now = DateTime.now();
    print(
      '🧪 Current time: ${now.hour}:${now.minute.toString().padLeft(2, '0')} on ${now.day}/${now.month}/${now.year}',
    );

    // First, test an immediate notification
    print('🧪 Testing immediate notification...');
    await sendImmediateNotification(
      channelId: 'test_channel',
      channelName: 'Test Notifications',
      channelDescription: 'Test notifications from Syntra',
      title: '🧪 Immediate Test',
      body: 'This is an immediate test notification!',
      vibration: true,
    );

    // Test the calculation function
    final times = calculateDailyNotificationTimes();
    print('🧪 Calculated times: ${times[0]} and ${times[1]}');

    // ALTERNATIVE APPROACH: Use Timer instead of scheduled notifications for testing
    print('🧪 Testing Timer-based notifications (fallback approach)...');

    // 10-second timer notification
    Timer(const Duration(seconds: 10), () async {
      print('🔔 Timer fired: Sending 10-second notification');
      await sendImmediateNotification(
        channelId: 'test_channel',
        channelName: 'Test Notifications',
        channelDescription: 'Test notifications from Syntra',
        title: '🧪 10-Second Timer Test',
        body: 'This notification was sent via Timer after 10 seconds!',
        vibration: true,
      );
    });

    // 30-second timer notification
    Timer(const Duration(seconds: 30), () async {
      print('🔔 Timer fired: Sending 30-second notification');
      await sendImmediateNotification(
        channelId: 'test_channel',
        channelName: 'Test Notifications',
        channelDescription: 'Test notifications from Syntra',
        title: '🧪 30-Second Timer Test',
        body: 'This notification was sent via Timer after 30 seconds!',
        vibration: true,
      );
    });

    // 1-minute timer notification
    Timer(const Duration(minutes: 1), () async {
      print('🔔 Timer fired: Sending 1-minute notification');
      await sendImmediateNotification(
        channelId: 'test_channel',
        channelName: 'Test Notifications',
        channelDescription: 'Test notifications from Syntra',
        title: '🧪 1-Minute Timer Test',
        body: 'This notification was sent via Timer after 1 minute!',
        vibration: true,
      );
    });

    // Also try the original scheduled approach (in case it works)
    print('🧪 Also testing original scheduled notifications...');

    final shortTestTime = now.add(const Duration(seconds: 15));
    print(
      '🧪 Testing 15-second scheduled notification for: ${shortTestTime.hour}:${shortTestTime.minute.toString().padLeft(2, '0')}:${shortTestTime.second.toString().padLeft(2, '0')}',
    );

    await sendNotification(
      channelId: 'test_channel',
      channelName: 'Test Notifications',
      channelDescription: 'Test notifications from Syntra',
      title: '🧪 15-Second Scheduled Test',
      body: 'This notification was scheduled for 15 seconds later!',
      vibration: true,
      scheduledTime: shortTestTime,
    );

    print('🧪 All test notifications set up!');
    print('🧪 You should see:');
    print('🧪   1. An immediate notification right now');
    print('🧪   2. Timer-based notifications at 10s, 30s, 1min');
    print('🧪   3. Scheduled notification at 15s (if Android allows it)');
    print('');
    print('🚨 If Timer-based notifications work but scheduled ones don\'t:');
    print('💡 This confirms Android is blocking scheduled alarms');
    print(
      '💡 We can implement a hybrid approach using background service + timers',
    );
  }

  /// Cancels all scheduled and active notifications.
  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Stops the Flutter background service and cancels notifications.
  static Future<void> stopBackgroundService() async {
    try {
      final service = FlutterBackgroundService();
      // Invoke platform method to stop the service
      service.invoke('stopService');
      print('Background service stop requested');
      await cancelAllNotifications();
    } catch (e) {
      print('Error stopping background service: $e');
    }
  }
}

// TODO: Implement iOS background notification support.
// iOS does not support persistent background Dart isolates like Android.
// For iOS, consider using silent push notifications, background fetch, or native scheduling via Swift/Objective-C.
// See: https://pub.dev/packages/flutter_local_notifications#ios-integration
