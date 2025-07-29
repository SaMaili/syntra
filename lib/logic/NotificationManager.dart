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
          description: 'Persistent background service notification',
          importance: Importance.low,
          playSound: false,
          enableVibration: false,
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
        isForegroundMode: true, // enable foreground service
        autoStartOnBoot: true,
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
    print('Timezone initialized');

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

    // Schedule daily motivation notifications immediately when service starts
    await _scheduleDailyMotivationNotifications();

    // Check every hour to reschedule notifications if needed
    Timer.periodic(const Duration(hours: 1), (timer) async {
      final now = DateTime.now();
      print('🕐 Hourly check at ${now.hour}:${now.minute.toString().padLeft(2, '0')} on ${now.day}/${now.month}/${now.year}');

      // Reschedule notifications if it's a new day
      if (now.hour == 0) {
        print('🗓️ New day detected, rescheduling daily notifications');
        await _scheduleDailyMotivationNotifications();
      }
    });
  }

  /// Calculates the daily motivation notification times for a given date
  /// This should be the single source of truth for notification times
  static List<DateTime> calculateDailyNotificationTimes([DateTime? targetDate]) {
    final date = targetDate ?? DateTime.now();

    print('🔍 DEBUG: calculateDailyNotificationTimes called for date: ${date.day}/${date.month}/${date.year}');

    // Use deterministic random based on the target date - SINGLE SEED PER DAY
    final random = Random(date.day + date.month + date.year);
    print('🔍 DEBUG: Using seed: ${date.day + date.month + date.year}');

    // First notification window (9 AM - 3 PM)
    final firstHour = AppStatic.motivationFirstHourStart +
        random.nextInt(AppStatic.motivationFirstHourRange);
    final firstMinute = random.nextInt(60);
    final firstScheduledTime = DateTime(date.year, date.month, date.day, firstHour, firstMinute);

    print('🔍 DEBUG: First notification calculated: ${firstHour}:${firstMinute.toString().padLeft(2, '0')}');

    // Second notification window (6 PM - 11 PM)
    final secondHour = AppStatic.motivationSecondHourStart +
        random.nextInt(AppStatic.motivationSecondHourRange);
    final secondMinute = random.nextInt(60);
    final secondScheduledTime = DateTime(date.year, date.month, date.day, secondHour, secondMinute);

    print('🔍 DEBUG: Second notification calculated: ${secondHour}:${secondMinute.toString().padLeft(2, '0')}');
    print('🔍 DEBUG: Returning times: [${firstScheduledTime}, ${secondScheduledTime}]');

    return [firstScheduledTime, secondScheduledTime];
  }

  /// Schedules motivation notifications for today and tomorrow
  static Future<void> _scheduleDailyMotivationNotifications() async {
    final now = DateTime.now();
    print('📋 Scheduling daily motivation notifications...');

    // Schedule for today
    await _scheduleMotivationNotificationsForDate(now);

    // Schedule for tomorrow
    final tomorrow = now.add(const Duration(days: 1));
    await _scheduleMotivationNotificationsForDate(tomorrow);

    print('✅ Daily motivation notifications scheduled for today and tomorrow');
  }

  /// Schedules motivation notifications for a specific date
  static Future<void> _scheduleMotivationNotificationsForDate(DateTime date) async {
    final now = DateTime.now();

    // Use the centralized calculation method - SINGLE SOURCE OF TRUTH
    final scheduledTimes = calculateDailyNotificationTimes(date);
    final firstScheduledTime = scheduledTimes[0];
    final secondScheduledTime = scheduledTimes[1];

    // Only schedule if the time is in the future
    if (firstScheduledTime.isAfter(now)) {
      print('📅 SCHEDULING MOTIVATION NOTIFICATION 1:');
      print('  - Date: ${date.day}/${date.month}/${date.year}');
      print('  - Scheduled for: ${firstScheduledTime.hour}:${firstScheduledTime.minute.toString().padLeft(2, '0')}');
      print('  - Window: ${AppStatic.motivationFirstHourStart}:00 - ${AppStatic.motivationFirstHourStart + AppStatic.motivationFirstHourRange - 1}:59');
      print('  - Time until notification: ${firstScheduledTime.difference(now).inMinutes} minutes');

      await sendNotification(
        channelId: 'motivation_channel',
        channelName: 'Motivation Notifications',
        channelDescription: 'Motivational reminders from Syntra',
        title: 'Syntra Motivation',
        body: AppStatic.motivationMessages[Random().nextInt(
          AppStatic.motivationMessages.length,
        )],
        vibration: true,
        scheduledTime: firstScheduledTime,
      );
    } else {
      print('⏭️ Skipping first notification for ${date.day}/${date.month} (time has passed)');
    }

    if (secondScheduledTime.isAfter(now)) {
      print('📅 SCHEDULING MOTIVATION NOTIFICATION 2:');
      print('  - Date: ${date.day}/${date.month}/${date.year}');
      print('  - Scheduled for: ${secondScheduledTime.hour}:${secondScheduledTime.minute.toString().padLeft(2, '0')}');
      print('  - Window: ${AppStatic.motivationSecondHourStart}:00 - ${AppStatic.motivationSecondHourStart + AppStatic.motivationSecondHourRange - 1}:59');
      print('  - Time until notification: ${secondScheduledTime.difference(now).inMinutes} minutes');

      await sendNotification(
        channelId: 'motivation_channel',
        channelName: 'Motivation Notifications',
        channelDescription: 'Motivational reminders from Syntra',
        title: 'Syntra Motivation',
        body: AppStatic.motivationMessages[Random().nextInt(
          AppStatic.motivationMessages.length,
        )],
        vibration: true,
        scheduledTime: secondScheduledTime,
      );
    } else {
      print('⏭️ Skipping second notification for ${date.day}/${date.month} (time has passed)');
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

    try {
      print("🎯 Attempting exact alarm scheduling...");
      // First try with exact alarm
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
    print('🧪 Current time: ${now.hour}:${now.minute.toString().padLeft(2, '0')} on ${now.day}/${now.month}/${now.year}');

    // Test the calculation function
    final times = calculateDailyNotificationTimes();
    print('🧪 Calculated times: ${times[0]} and ${times[1]}');

    // Schedule a test notification 2 minutes from now
    final testTime = now.add(const Duration(minutes: 2));
    print('🧪 Scheduling test notification for: ${testTime.hour}:${testTime.minute.toString().padLeft(2, '0')}');

    await sendNotification(
      channelId: 'test_channel',
      channelName: 'Test Notifications',
      channelDescription: 'Test notifications from Syntra',
      title: '🧪 Test Notification',
      body: 'This notification was scheduled for 2 minutes after you called the test function!',
      vibration: true,
      scheduledTime: testTime,
    );

    print('🧪 Test notification scheduled! Should arrive in 2 minutes.');
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
