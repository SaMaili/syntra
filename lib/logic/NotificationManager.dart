import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _notificationsPlugin.initialize(initializationSettings);

    // Create notification channels for Android
    await _createNotificationChannels();
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

  static Future<void> startBackgroundService() async {
    await FlutterBackgroundService().configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true, // Enable auto-start for better reliability
        isForegroundMode: true, // Must be true for Android 12+ compliance
        autoStartOnBoot: true, // Allow restart after reboot
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

    // Send another test notification after 10 seconds
    Timer(Duration(seconds: 10), () async {
      try {
        print('Sending delayed test notification');
        await _notificationsPlugin.show(
          124,
          'Syntra Delayed Test',
          'This notification came 10 seconds after app start',
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
        print('Delayed test notification sent successfully');
      } catch (e) {
        print('Failed to send delayed notification: $e');
      }
    });

    print('Background service setup completed');

    // Check for notifications every minute
    Timer.periodic(const Duration(minutes: 1), (timer) async {
      final now = DateTime.now();
      print('Background service checking time: ${now.hour}:${now.minute}');

      // Original motivation notifications at 9:00 and 15:00
      if (now.hour == 9 && now.minute == 0) {
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
          scheduledTime: now.add(const Duration(seconds: 5)),
        );
      }
      if (now.hour == 15 && now.minute == 0) {
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
          scheduledTime: now.add(const Duration(seconds: 5)),
        );
      }
    });
  }

  static Future<void> sendNotification({
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
    final notificationId = (DateTime.now().millisecondsSinceEpoch % 2147483647)
        .toInt();
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
        matchDateTimeComponents: DateTimeComponents.time,
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
          matchDateTimeComponents: DateTimeComponents.time,
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
