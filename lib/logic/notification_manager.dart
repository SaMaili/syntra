import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/settings_repository.dart';
import '../services/syntra_notification_service.dart';
import '../static.dart';

@pragma('vm:entry-point')
class NotificationManager {
  /// Check if notifications are enabled in settings.
  static Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
  }

  /// Cancel all scheduled notifications.
  static Future<void> cancelAllNotifications() async {
    try {
      await SyntraNotificationService.instance.cancelAllNotifications();
      debugPrint('✅ All notifications cancelled');
    } catch (e) {
      debugPrint('❌ Error cancelling notifications: $e');
    }
  }

  /// Initialize notifications. Delegates to [SyntraNotificationService].
  static Future<void> initialize() async {
    if (!await SyntraNotificationService.instance.initialize()) {
      debugPrint('❌ Failed to initialize notification service');
      return;
    }
    await SyntraNotificationService.instance.requestPermissions();
  }

  /// Calculates user-controlled notification times for a given date.
  static Future<List<DateTime>> calculateUserControlledNotificationTimes([
    DateTime? targetDate,
  ]) async {
    final date = targetDate ?? DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    final List<DateTime> scheduledTimes = [];

    final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    if (!notificationsEnabled) {
      debugPrint('🚫 Global notifications disabled - returning empty schedule');
      return scheduledTimes;
    }

    final hasSlotSettings =
        prefs.containsKey('notification1Enabled') ||
        prefs.containsKey('notification2Enabled') ||
        prefs.containsKey('notification3Enabled');

    final notification1Enabled = prefs.getBool('notification1Enabled') ?? false;
    final notification2Enabled = prefs.getBool('notification2Enabled') ?? false;
    final notification3Enabled = prefs.getBool('notification3Enabled') ?? false;

    debugPrint(
        '🔎 Slot state @${date.toIso8601String()} | hasSlots=$hasSlotSettings, '
        'n1=$notification1Enabled, n2=$notification2Enabled, n3=$notification3Enabled');

    if (!hasSlotSettings) {
      debugPrint('📅 No slot settings found - using default schedule');
      for (final timeString in ['09:00', '14:00', '19:00']) {
        final parts = timeString.split(':');
        scheduledTimes.add(DateTime(
          date.year, date.month, date.day,
          int.parse(parts[0]), int.parse(parts[1]),
        ));
        debugPrint('📅 Added default notification time: $timeString');
      }
      return scheduledTimes;
    }

    if (!notification1Enabled && !notification2Enabled && !notification3Enabled) {
      debugPrint('🚫 All individual notification slots disabled');
      return scheduledTimes;
    }

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

  /// Schedules daily reminders using [SyntraNotificationService].
  static Future<void> scheduleDailyReminders() async {
    if (!await areNotificationsEnabled()) {
      debugPrint('🚫 Notifications disabled in settings - skipping scheduling');
      return;
    }

    final now = DateTime.now();
    debugPrint('📋 Scheduling user-controlled daily reminders...');

    final localeCode = await SettingsRepository.instance.loadLanguage() ?? 'en';
    final notificationService = SyntraNotificationService.instance;

    if (!await notificationService.initialize()) {
      debugPrint('❌ Failed to initialize notification service');
      return;
    }

    final permissions = await notificationService.requestPermissions();
    if (!permissions.hasBasicPermission) {
      debugPrint('❌ No notification permissions granted');
      return;
    }
    if (!permissions.canScheduleExactAlarms) {
      debugPrint('⚠️ Exact alarm scheduling not available - notifications may be delayed');
    }

    final notifications = <NotificationRequest>[];

    final todayTimes = await calculateUserControlledNotificationTimes(now);
    for (final scheduledTime in todayTimes) {
      if (scheduledTime.isAfter(now)) {
        final timeSlot = _getTimeSlot(scheduledTime.hour);
        notifications.add(NotificationRequest(
          id: (scheduledTime.millisecondsSinceEpoch % 2147483647).toInt(),
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
        debugPrint('📅 Added today\'s $timeSlot notification');
      }
    }

    for (int dayOffset = 1; dayOffset <= 7; dayOffset++) {
      final targetDate = now.add(Duration(days: dayOffset));
      final dayTimes = await calculateUserControlledNotificationTimes(targetDate);

      for (final scheduledTime in dayTimes) {
        final timeSlot = _getTimeSlot(scheduledTime.hour);
        notifications.add(NotificationRequest(
          id: (scheduledTime.millisecondsSinceEpoch % 2147483647).toInt(),
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
        final times = dayTimes
            .map((t) => '${t.hour}:${t.minute.toString().padLeft(2, '0')}')
            .join(', ');
        debugPrint('📅 Added day +$dayOffset notifications: $times');
      }
    }

    if (notifications.isNotEmpty) {
      debugPrint('🚀 Batch scheduling ${notifications.length} notifications...');
      final result = await notificationService.batchScheduleNotifications(notifications);
      debugPrint('✅ Batch scheduling completed: ${result.successCount}/${notifications.length} successful');
      if (result.failureCount > 0) {
        debugPrint('⚠️ ${result.failureCount} notifications failed to schedule');
      }
    } else {
      debugPrint('ℹ️ No notifications to schedule');
    }
  }

  static String _getTimeSlot(int hour) {
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

  /// Schedule a single notification at a specific time.
  static Future<bool> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    Map<String, String> data = const {},
    NotificationChannel channel = NotificationChannel.reminders,
  }) async {
    if (!await areNotificationsEnabled()) {
      debugPrint('🚫 Notifications disabled - skipping scheduleNotification');
      return false;
    }
    return SyntraNotificationService.instance.scheduleExactNotification(
      id: (scheduledTime.millisecondsSinceEpoch % 2147483647).toInt(),
      title: title,
      body: body,
      scheduledTime: scheduledTime,
      data: data,
      channel: channel,
    );
  }

  /// Send an immediate notification.
  static Future<void> sendImmediateNotification({
    required String title,
    required String body,
    Map<String, String> data = const {},
    NotificationChannel channel = NotificationChannel.reminders,
    // Legacy parameters — ignored, kept for call-site compatibility.
    String? channelId,
    String? channelName,
    String? channelDescription,
    bool? vibration,
  }) async {
    if (!await areNotificationsEnabled()) {
      debugPrint('🚫 Notifications disabled - skipping sendImmediateNotification');
      return;
    }
    await SyntraNotificationService.instance.showNotificationNow(
      id: (DateTime.now().millisecondsSinceEpoch % 2147483647).toInt(),
      title: title,
      body: body,
      data: data,
      channel: channel,
    );
  }

  /// Legacy sendNotification method for backward compatibility.
  static Future<int> sendNotification({
    required String channelId,
    required String channelName,
    required String channelDescription,
    required String title,
    required String body,
    required bool vibration,
    required DateTime scheduledTime,
  }) async {
    if (!await areNotificationsEnabled()) {
      debugPrint('🚫 Notifications disabled - skipping sendNotification');
      return -1;
    }
    final id = (scheduledTime.millisecondsSinceEpoch % 2147483647).toInt();
    final success = await SyntraNotificationService.instance.scheduleExactNotification(
      id: id,
      title: title,
      body: body,
      scheduledTime: scheduledTime,
      data: {'legacy_channel': channelId},
      channel: NotificationChannel.reminders,
    );
    debugPrint(success
        ? '✅ Notification scheduled (ID=$id)'
        : '❌ Notification scheduling failed (ID=$id)');
    return success ? id : -1;
  }

  /// Schedule a single daily reminder at a specific time.
  static Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required int id,
  }) async {
    debugPrint('📋 Scheduling single daily reminder at $hour:$minute with ID $id');

    final notificationService = SyntraNotificationService.instance;
    if (!await notificationService.initialize()) {
      debugPrint('❌ Failed to initialize notification service');
      return;
    }

    final permissions = await notificationService.requestPermissions();
    if (!permissions.hasBasicPermission) {
      debugPrint('❌ No notification permissions granted');
      return;
    }

    final localeCode = await SettingsRepository.instance.loadLanguage() ?? 'en';
    final now = DateTime.now();
    DateTime scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final success = await notificationService.scheduleExactNotification(
      id: id,
      title: AppStatic.localizedMotivationTitle(localeCode),
      body: AppStatic.randomMotivationMessage(localeCode),
      scheduledTime: scheduledTime,
      data: {'type': 'custom_reminder', 'custom_id': id.toString()},
      channel: NotificationChannel.reminders,
    );
    debugPrint(success
        ? '✅ Scheduled custom reminder for $scheduledTime'
        : '❌ Failed to schedule custom reminder');
  }

  /// Schedules a weekly recap notification for the next Sunday at 20:00.
  ///
  /// The notification body mentions how many challenges the user completed
  /// this week. Safe to call on every launch — the fixed ID (9999) means
  /// re-scheduling replaces the previous one rather than stacking.
  static Future<void> scheduleWeeklyRecap({
    required int completedThisWeek,
    required String localeCode,
  }) async {
    if (!await areNotificationsEnabled()) return;

    final notificationService = SyntraNotificationService.instance;
    if (!await notificationService.initialize()) return;

    final now = DateTime.now();
    // Days until next Sunday (weekday: 1=Mon … 7=Sun).
    final daysUntilSunday = (7 - now.weekday) % 7 == 0
        ? 7
        : (7 - now.weekday) % 7;
    final nextSunday = DateTime(
        now.year, now.month, now.day + daysUntilSunday, 20, 0);

    final body = localeCode == 'de'
        ? 'Diese Woche hast du $completedThisWeek Challenges abgeschlossen. Weiter so!'
        : 'This week you completed $completedThisWeek challenges. Keep up the great work!';

    await notificationService.scheduleExactNotification(
      id: 9999,
      title: localeCode == 'de' ? 'Wochenrückblick' : 'Weekly Recap',
      body: body,
      scheduledTime: nextSunday,
      data: {'type': 'weekly_recap'},
      channel: NotificationChannel.reminders,
    );
    debugPrint('✅ Weekly recap scheduled for $nextSunday');
  }

  /// Cancel a specific notification by ID
  static Future<void> cancelNotification(int id) async {
    await SyntraNotificationService.instance.cancelNotification(id);
    debugPrint('✅ Notification $id cancelled');
  }

  /// Test the notification system.
  static Future<void> testProfessionalNotificationSystem() async {
    debugPrint('🧪 TESTING NOTIFICATION SYSTEM...');
    await sendImmediateNotification(
      title: '🧪 Test',
      body: 'This is an immediate test notification!',
      data: {'test_type': 'immediate'},
    );
    final testTime = DateTime.now().add(const Duration(seconds: 30));
    final success = await scheduleNotification(
      title: '🧪 Scheduled Test',
      body: 'This notification was scheduled 30 seconds ago!',
      scheduledTime: testTime,
      data: {'test_type': 'scheduled'},
    );
    debugPrint(success
        ? '✅ Scheduled test notification for 30 seconds from now'
        : '❌ Failed to schedule test notification');
    debugPrint('🧪 Notification system test completed!');
  }

  /// Legacy alias.
  static Future<void> testNotificationSystem() =>
      testProfessionalNotificationSystem();
}
