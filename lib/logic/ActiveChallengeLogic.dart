import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

/// Handles logic for active challenges, including notifications and permissions
class ActiveChallengeLogic {
  /// Plugin for local notifications
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

  /// Main timer value for the challenge
  int mainTimer;

  /// BuildContext for accessing theme and navigation
  final BuildContext context;

  /// Constructor requires context and mainTimer
  ActiveChallengeLogic({required this.context, required this.mainTimer});

  /// Initializes local notifications and requests notification permission on Android
  Future<void> initNotifications() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    final settings = InitializationSettings(android: androidSettings);
    await flutterLocalNotificationsPlugin!.initialize(settings);
    // Request notification permission if running on Android
    if (Theme.of(context).platform == TargetPlatform.android) {
      await Permission.notification.request();
    }
  }

  /// Checks if the app can schedule exact alarms (Android-specific)
  Future<bool> canScheduleExactAlarms() async {
    try {
      const platform = MethodChannel('channel_timer');
      return await platform.invokeMethod('canScheduleExactAlarms');
    } catch (_) {
      return false;
    }
  }

  /// Asks the user for permission to use exact alarms, and redirects to settings if not granted
  Future<void> askForExactAlarmPermission() async {
    if (Theme.of(context).platform != TargetPlatform.android) return;
    if (await canScheduleExactAlarms()) return;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Allow exact alarms'),
        content: const Text(
          'To make scheduled notifications work exactly, Syntra needs permission for exact alarms. Please grant this in the settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final intent = AndroidIntent(
                action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
              );
              await intent.launch();
              Navigator.of(ctx).pop();
            },
            child: const Text('Go to settings'),
          ),
        ],
      ),
    );
  }

  /// Schedules a timer notification with the main timer value
  Future<void> scheduleTimerNotification() async {
    if (flutterLocalNotificationsPlugin == null) return;
    const androidDetails = AndroidNotificationDetails(
      'challenge_timer',
      'Challenge Timer',
      channelDescription: 'Notification for challenge timer',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );
    const details = NotificationDetails(android: androidDetails);
    final canSchedule = await canScheduleExactAlarms();
    await flutterLocalNotificationsPlugin!.zonedSchedule(
      0,
      'Zeit abgelaufen!',
      'Deine Challenge-Zeit ist vorbei! Zeit für Action! 💪',
      tz.TZDateTime.now(tz.local).add(Duration(seconds: mainTimer)),
      details,
      androidScheduleMode: canSchedule
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexact,
      matchDateTimeComponents: null,
    );
  }

  /// Cancels the scheduled timer notification
  Future<void> cancelTimerNotification() async {
    await flutterLocalNotificationsPlugin?.cancel(0);
  }
}
