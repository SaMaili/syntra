import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:syntra/logic/NotificationManager.dart';

import '../generated/l10n.dart';

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
    final settings = InitializationSettings(
      android: androidSettings,
    );
    await flutterLocalNotificationsPlugin!.initialize(settings: settings);
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
        title: Text(S.of(context).allowExactAlarms),
        content: Text(S.of(context).exactAlarmsDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(S.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final intent = AndroidIntent(
                action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
              );
              await intent.launch();
              Navigator.of(ctx).pop();
            },
            child: Text(S.of(context).goToSettings),
          ),
        ],
      ),
    );
  }

  /// Schedules a timer notification with the main timer value
  Future<void> scheduleTimerNotification() async {
    if (flutterLocalNotificationsPlugin == null) return;

    // Respect global notifications toggle
    try {
      final enabled = await NotificationManager.areNotificationsEnabled();
      if (!enabled) {
        // If disabled, ensure any previous timer notification is canceled
        await cancelTimerNotification();
        return;
      }
    } catch (_) {}

    const androidDetails = AndroidNotificationDetails(
      'challenge_timer',
      'Challenge Timer',
      channelDescription: 'Notification for challenge timer',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      icon: '@drawable/syntrabird_notification',
    );
    const details = NotificationDetails(android: androidDetails);
    final canSchedule = await canScheduleExactAlarms();
    final scheduledTime = DateTime.now().add(Duration(seconds: mainTimer));

    await flutterLocalNotificationsPlugin!.zonedSchedule(
      id: 0,
      title: S.of(context).timeUpNotificationTitle,
      body: S.of(context).timeUpNotificationBody,
      scheduledDate: tz.TZDateTime.now(tz.local).add(Duration(seconds: mainTimer)),
      notificationDetails: details,
      androidScheduleMode: canSchedule
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexact,
      matchDateTimeComponents: null,
    );
    // Store the scheduled notification time for Android reboot rescheduling
    await storeScheduledNotification(scheduledTime);
  }

  /// Cancels the scheduled timer notification
  Future<void> cancelTimerNotification() async {
    await flutterLocalNotificationsPlugin?.cancel(id: 0);
  }

  /// Stores a scheduled notification time in persistent storage (Android only)
  Future<void> storeScheduledNotification(DateTime scheduledTime) async {
    // TODO: Implement for iOS if needed (using appropriate iOS background APIs)
    if (Theme.of(context).platform == TargetPlatform.android) {
      final prefs = await SharedPreferences.getInstance();
      final List<String> times =
          prefs.getStringList('flutter.scheduled_notifications') ?? [];
      times.add(scheduledTime.toIso8601String());
      await prefs.setStringList('flutter.scheduled_notifications', times);
    }
  }

  /// Checks if battery optimizations are ignored for this app (Android only)
  Future<bool> isIgnoringBatteryOptimizations() async {
    if (Theme.of(context).platform != TargetPlatform.android) return true;
    const platform = MethodChannel('channel_battery_optimizations');
    try {
      final bool result = await platform.invokeMethod(
        'isIgnoringBatteryOptimizations',
      );
      return result;
    } catch (_) {
      return false;
    }
  }

  /// Prompts the user to disable battery optimizations and check background/autostart/lockscreen settings (Android only)
  Future<void> askForAllNotificationPermissions() async {
    if (Theme.of(context).platform != TargetPlatform.android) return;
    if (await isIgnoringBatteryOptimizations()) return;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context).importantNotificationHints),
        content: Text(S.of(context).notificationPermissionsDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK'),
          ),
          ElevatedButton(
            onPressed: () async {
              final intent = AndroidIntent(
                action: 'android.settings.IGNORE_BATTERY_OPTIMIZATION_SETTINGS',
              );
              await intent.launch();
              Navigator.of(ctx).pop();
            },
            child: Text(S.of(context).openBatteryOptimization),
          ),
        ],
      ),
    );
  }
}
