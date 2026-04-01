import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

/// Enterprise-level Notification Service for Flutter
/// Provides professional-grade notification management with exact timing
/// and boot recovery like MyFitnessPal, Todoist, Samsung Health
class SyntraNotificationService {
  static const String _channelName = 'app.inneract.syntra/notifications';
  static const MethodChannel _channel = MethodChannel(_channelName);

  static SyntraNotificationService? _instance;
  static SyntraNotificationService get instance {
    _instance ??= SyntraNotificationService._();
    return _instance!;
  }

  SyntraNotificationService._();

  FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;
  bool _isInitialized = false;

  // Professional logging
  void _log(String message) {
    debugPrint('[SyntraNotificationService] $message');
  }

  void _logError(String message, [Object? error]) {
    debugPrint('[SyntraNotificationService] ERROR: $message ${error ?? ''}');
  }

  /// Initialize the notification service with professional configuration
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Initialize timezone data
      tz.initializeTimeZones();

      // Initialize Flutter Local Notifications
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@drawable/syntrabird_notification');

      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await _flutterLocalNotificationsPlugin!.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Initialize method channel communication with native Android
      _setupMethodChannel();

      // Add a longer delay to ensure native method channel is fully ready
      if (Platform.isAndroid) {
        _log('Waiting for native method channel to be ready...');
        await Future.delayed(const Duration(milliseconds: 500));
        _log('Native method channel should now be ready');
      }

      _isInitialized = true;
      _log('Notification service initialized successfully');

      return true;
    } catch (e) {
      _logError('Failed to initialize notification service', e);
      return false;
    }
  }

  /// Setup method channel for Flutter-Native communication (Android only)
  void _setupMethodChannel() {
    if (!Platform.isAndroid) return;
    _channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'onNotificationReceived':
          await _handleNotificationReceived(call.arguments);
          break;
        case 'onBootCompleted':
          await _handleBootCompleted();
          break;
        default:
          _logError('Unknown method call: ${call.method}');
      }
    });
  }

  /// Professional permission request flow like enterprise apps
  Future<NotificationPermissionStatus> requestPermissions() async {
    try {
      _log('Requesting notification permissions...');

      // For Android, try to check permissions first without requesting immediately
      bool hasBasicPermission = false;
      bool hasExactAlarmPermission = true;
      bool canScheduleExactAlarms = true;

      if (Platform.isAndroid) {
        try {
          // First check if we already have notification permission
          final currentStatus = await Permission.notification.status;

          if (currentStatus == PermissionStatus.granted) {
            hasBasicPermission = true;
            _log('Notification permission already granted');
          } else {
            // Try to request permission, but handle Activity detection issues
            try {
              final requestResult = await Permission.notification.request();
              hasBasicPermission = requestResult == PermissionStatus.granted;

              if (hasBasicPermission) {
                _log('Notification permission granted after request');
              } else {
                _log('Notification permission denied after request');
              }
            } catch (activityError) {
              _logError('Failed to request notification permission due to Activity issue', activityError);

              // Fallback: assume we have permission if we can't detect Activity
              // This is a common issue in Flutter when the Activity isn't ready
              hasBasicPermission = currentStatus != PermissionStatus.denied;
              _log('Using fallback permission status due to Activity detection issue');
            }
          }

          // Check exact alarm permission for Android 12+ - wait for method channel to be ready
          try {
            // Add extra delay to ensure method channel is available (based on logs showing later success)
            _log('Waiting for method channel to be fully ready for permission check...');
            //await Future.delayed(const Duration(milliseconds: 3000));

            final result = await _channel.invokeMethod<bool>('canScheduleExactAlarms');
            canScheduleExactAlarms = result ?? false;
            _log('Successfully checked exact alarm permission: $canScheduleExactAlarms');

            if (!canScheduleExactAlarms) {
              _log('Exact alarms not allowed, will request permission');
              try {
                // Request exact alarm permission
                await _channel.invokeMethod('requestExactAlarmPermission');

                // Check again after request
                final resultAfter = await _channel.invokeMethod<bool>('canScheduleExactAlarms');
                canScheduleExactAlarms = resultAfter ?? false;
                hasExactAlarmPermission = canScheduleExactAlarms;
              } catch (exactAlarmError) {
                _logError('Error requesting exact alarm permission', exactAlarmError);
                hasExactAlarmPermission = false;
                canScheduleExactAlarms = false;
              }
            } else {
              _log('Exact alarms already allowed');
            }
          } catch (e) {
            _logError('Error checking exact alarm permission - using fallback', e);
            // Fallback: assume exact alarms are available on older Android versions
            hasExactAlarmPermission = true;
            canScheduleExactAlarms = true;
            _log('Using fallback exact alarm permission (assuming available)');
          }
        } catch (e) {
          _logError('General Android permission error', e);
          // Fallback for Android
          hasBasicPermission = true; // Assume basic permission for older Android versions
          hasExactAlarmPermission = true; // Assume exact alarms work
          canScheduleExactAlarms = true;
        }
      } else {
        // For non-Android platforms, assume permissions are handled differently
        hasBasicPermission = true;
      }

      final status = NotificationPermissionStatus(
        hasBasicPermission: hasBasicPermission,
        hasExactAlarmPermission: hasExactAlarmPermission,
        canScheduleExactAlarms: canScheduleExactAlarms,
      );

      _log('Final permission status: ${status.toString()}');
      return status;

    } catch (e) {
      _logError('Error in permission request flow', e);

      // Fallback status - assume basic permissions and exact alarms work
      return NotificationPermissionStatus(
        hasBasicPermission: true,
        hasExactAlarmPermission: true,
        canScheduleExactAlarms: true,
      );
    }
  }

  /// Schedule exact notification with enterprise-level reliability
  Future<bool> scheduleExactNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    Map<String, String>? data,
    NotificationChannel channel = NotificationChannel.reminders,
  }) async {
    if (!_isInitialized) {
      _logError('Service not initialized');
      return false;
    }

    // Respect global notifications toggle
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool('notifications_enabled') ?? true;
      if (!enabled) {
        _log('Global notifications disabled - skipping scheduleExactNotification');
        return false;
      }
    } catch (e) {
      // If prefs fails, continue; NotificationManager guards should handle
    }

    try {
      final triggerTime = scheduledTime.millisecondsSinceEpoch;

      if (Platform.isAndroid) {
        try {
          // Try native Android implementation directly
          final result = await _channel.invokeMethod<bool>('scheduleExactNotification', {
            'id': id,
            'title': title,
            'body': body,
            'triggerTime': triggerTime,
            'data': data ?? {},
            'channelId': _getChannelId(channel),
          });

          if (result == true) {
            // Store notification data locally for cross-platform access
            await _storeNotificationLocally(
              id: id,
              title: title,
              body: body,
              scheduledTime: scheduledTime,
              data: data,
              channel: channel,
            );

            _log('Scheduled exact notification: ID=$id, Time=$scheduledTime');
            return true;
          } else {
            _logError('Native Android scheduling returned false - using fallback');
          }
        } catch (e) {
          _logError('Error with native Android scheduling - using fallback', e);
        }
      }

      // Fallback to Flutter Local Notifications (for non-Android or when native fails)
      _log('Using Flutter Local Notifications fallback for ID=$id');
      return await _scheduleWithFallback(
        id: id,
        title: title,
        body: body,
        scheduledTime: scheduledTime,
        data: data,
        channel: channel,
      );

    } catch (e) {
      _logError('Error scheduling exact notification', e);
      return false;
    }
  }

  /// Batch schedule notifications for efficiency (like professional apps)
  Future<BatchScheduleResult> batchScheduleNotifications(
    List<NotificationRequest> notifications,
  ) async {
    if (!_isInitialized) {
      _logError('Service not initialized');
      return BatchScheduleResult([], 0, notifications.length);
    }

    // Respect global notifications toggle
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool('notifications_enabled') ?? true;
      if (!enabled) {
        _log('Global notifications disabled - skipping batchScheduleNotifications');
        return BatchScheduleResult([], 0, notifications.length);
      }
    } catch (_) {}

    try {
      _log('Batch scheduling ${notifications.length} notifications...');

      if (Platform.isAndroid) {
        try {
          // Try native batch scheduling directly
          final nativeRequests = notifications.map((req) => {
            'id': req.id,
            'title': req.title,
            'body': req.body,
            'triggerTime': req.scheduledTime.millisecondsSinceEpoch,
            'data': req.data,
            'channelId': _getChannelId(req.channel),
          }).toList();

          final result = await _channel.invokeMethod<Map>('batchScheduleNotifications', {
            'notifications': nativeRequests,
          });

          if (result != null) {
            final successCount = result['successCount'] as int? ?? 0;
            final failureCount = result['failureCount'] as int? ?? 0;
            final results = (result['results'] as List? ?? [])
                .map((r) => NotificationResult(r['id'] as int, r['success'] as bool))
                .toList();

            // Store successful notifications locally
            for (int i = 0; i < notifications.length; i++) {
              if (i < results.length && results[i].success) {
                await _storeNotificationLocally(
                  id: notifications[i].id,
                  title: notifications[i].title,
                  body: notifications[i].body,
                  scheduledTime: notifications[i].scheduledTime,
                  data: notifications[i].data,
                  channel: notifications[i].channel,
                );
              }
            }

            _log('Native batch schedule completed: $successCount success, $failureCount failed');
            return BatchScheduleResult(results, successCount, failureCount);
          } else {
            _logError('Native batch scheduling returned null - using fallback');
          }
        } catch (e) {
          _logError('Error with native batch scheduling - using fallback', e);
        }
      }

      // Fallback: schedule individually (either non-Android or native method failed)
      _log('Using individual notification scheduling fallback');
      final results = <NotificationResult>[];
      int successCount = 0;

      for (final notification in notifications) {
        final success = await scheduleExactNotification(
          id: notification.id,
          title: notification.title,
          body: notification.body,
          scheduledTime: notification.scheduledTime,
          data: notification.data,
          channel: notification.channel,
        );

        results.add(NotificationResult(notification.id, success));
        if (success) successCount++;
      }

      _log('Fallback batch schedule completed: $successCount success, ${notifications.length - successCount} failed');
      return BatchScheduleResult(results, successCount, notifications.length - successCount);

    } catch (e) {
      _logError('Error in batch schedule', e);
      return BatchScheduleResult([], 0, notifications.length);
    }
  }

  /// Cancel scheduled notification
  Future<bool> cancelNotification(int id) async {
    try {
      if (Platform.isAndroid) {
        final result = await _channel.invokeMethod<bool>('cancelNotification', {'id': id});
        if (result == true) {
          await _removeStoredNotification(id);
          _log('Cancelled notification: ID=$id');
          return true;
        }
      } else {
        await _flutterLocalNotificationsPlugin?.cancel(id: id);
        await _removeStoredNotification(id);
        return true;
      }
      return false;
    } catch (e) {
      _logError('Error cancelling notification', e);
      return false;
    }
  }

  /// Cancel all scheduled notifications
  Future<bool> cancelAllNotifications() async {
    try {
      _log('Cancelling all notifications...');
      
      if (Platform.isAndroid) {
        final result = await _channel.invokeMethod<bool>('cancelAllNotifications');
        if (result == true) {
          await _clearAllStoredNotifications();
          _log('All notifications cancelled via Android native');
          return true;
        }
      }
      
      // Fallback to Flutter Local Notifications
      await _flutterLocalNotificationsPlugin?.cancelAll();
      await _clearAllStoredNotifications();
      _log('All notifications cancelled via Flutter fallback');
      return true;
    } catch (e) {
      _logError('Error cancelling all notifications', e);
      return false;
    }
  }

  /// Get all scheduled notifications
  Future<List<ScheduledNotificationInfo>> getScheduledNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString('syntra_scheduled_notifications') ?? '[]';
      final List<dynamic> notificationsList = json.decode(notificationsJson);

      return notificationsList
          .map((json) => ScheduledNotificationInfo.fromJson(json))
          .where((notification) => notification.scheduledTime.isAfter(DateTime.now()))
          .toList();
    } catch (e) {
      _logError('Error getting scheduled notifications', e);
      return [];
    }
  }

  /// Professional method to reschedule all notifications (used after boot/update)
  Future<bool> rescheduleAllNotifications() async {
    try {
      _log('Rescheduling all notifications...');

      // Respect global notifications toggle
      try {
        final prefs = await SharedPreferences.getInstance();
        final enabled = prefs.getBool('notifications_enabled') ?? true;
        if (!enabled) {
          _log('Global notifications disabled - skipping rescheduleAllNotifications');
          await cancelAllNotifications();
          return true;
        }
      } catch (_) {}

      final scheduledNotifications = await getScheduledNotifications();
      if (scheduledNotifications.isEmpty) {
        _log('No notifications to reschedule');
        return true;
      }

      final requests = scheduledNotifications
          .map((info) => NotificationRequest(
                id: info.id,
                title: info.title,
                body: info.body,
                scheduledTime: info.scheduledTime,
                data: info.data,
                channel: info.channel,
              ))
          .toList();

      final result = await batchScheduleNotifications(requests);

      _log('Rescheduled ${result.successCount}/${requests.length} notifications');
      return result.successCount == requests.length;

    } catch (e) {
      _logError('Error rescheduling notifications', e);
      return false;
    }
  }

  /// Show notification immediately (for testing and debugging)
  Future<void> showNotificationNow({
    required int id,
    required String title,
    required String body,
    Map<String, String>? data,
    NotificationChannel channel = NotificationChannel.reminders,
  }) async {
    try {
      // Respect global notifications toggle
      try {
        final prefs = await SharedPreferences.getInstance();
        final enabled = prefs.getBool('notifications_enabled') ?? true;
        if (!enabled) {
          _log('Global notifications disabled - skipping showNotificationNow');
          return;
        }
      } catch (_) {}

      if (Platform.isAndroid) {
        await _channel.invokeMethod('showNotificationNow', {
          'id': id,
          'title': title,
          'body': body,
          'data': data ?? {},
          'channelId': _getChannelId(channel),
        });
      } else {
        await _flutterLocalNotificationsPlugin?.show(
          id: id,
          title: title,
          body: body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              _getChannelId(channel),
              _getChannelName(channel),
              importance: Importance.high,
              priority: Priority.high,
              icon: '@drawable/syntrabird_notification',
            ),
          ),
        );
      }

      _log('Showed notification immediately: ID=$id');
    } catch (e) {
      _logError('Error showing immediate notification', e);
    }
  }

  /// Sync global notifications enabled to native layer (Android BootReceiver)
  Future<void> setNativeNotificationsEnabled(bool enabled) async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('setNotificationsEnabled', {
        'enabled': enabled,
      });
      _log('Synced native notifications_enabled = $enabled');
    } catch (e) {
      _logError('Failed to sync native notifications_enabled', e);
    }
  }

  // Helper methods and internal implementation

  String _getChannelId(NotificationChannel channel) {
    switch (channel) {
      case NotificationChannel.reminders:
        return 'syntra_reminders';
      case NotificationChannel.challenges:
        return 'syntra_challenges';
      case NotificationChannel.system:
        return 'syntra_system';
    }
  }

  String _getChannelName(NotificationChannel channel) {
    switch (channel) {
      case NotificationChannel.reminders:
        return 'Challenge Reminders';
      case NotificationChannel.challenges:
        return 'Challenge Updates';
      case NotificationChannel.system:
        return 'System Notifications';
    }
  }

  Future<bool> _scheduleWithFallback({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    Map<String, String>? data,
    required NotificationChannel channel,
  }) async {
    try {
      await _flutterLocalNotificationsPlugin?.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _getChannelId(channel),
            _getChannelName(channel),
            importance: Importance.high,
            priority: Priority.high,
            icon: '@drawable/syntrabird_notification',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      await _storeNotificationLocally(
        id: id,
        title: title,
        body: body,
        scheduledTime: scheduledTime,
        data: data,
        channel: channel,
      );

      return true;
    } catch (e) {
      _logError('Fallback scheduling failed', e);
      return false;
    }
  }

  Future<void> _storeNotificationLocally({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    Map<String, String>? data,
    required NotificationChannel channel,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString('syntra_scheduled_notifications') ?? '[]';
      final List<dynamic> notificationsList = json.decode(notificationsJson);

      // Remove existing notification with same ID
      notificationsList.removeWhere((n) => n['id'] == id);

      // Add new notification
      notificationsList.add({
        'id': id,
        'title': title,
        'body': body,
        'scheduledTime': scheduledTime.toIso8601String(),
        'data': data ?? {},
        'channel': channel.index,
        'createdAt': DateTime.now().toIso8601String(),
      });

      await prefs.setString('syntra_scheduled_notifications', json.encode(notificationsList));
    } catch (e) {
      _logError('Error storing notification locally', e);
    }
  }

  Future<void> _removeStoredNotification(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString('syntra_scheduled_notifications') ?? '[]';
      final List<dynamic> notificationsList = json.decode(notificationsJson);

      notificationsList.removeWhere((n) => n['id'] == id);

      await prefs.setString('syntra_scheduled_notifications', json.encode(notificationsList));
    } catch (e) {
      _logError('Error removing stored notification', e);
    }
  }

  Future<void> _clearAllStoredNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('syntra_scheduled_notifications');
      _log('Cleared all stored notifications');
    } catch (e) {
      _logError('Error clearing stored notifications', e);
    }
  }

  Future<void> _handleNotificationReceived(Map<String, dynamic> arguments) async {
    _log('Notification received: $arguments');
    // Handle custom notification logic here
  }

  Future<void> _handleBootCompleted() async {
    _log('Boot completed - triggering notification reschedule');
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool('notifications_enabled') ?? true;
      if (!enabled) {
        _log('Global notifications disabled at boot - skipping reschedule');
        await cancelAllNotifications();
        return;
      }
    } catch (_) {}
    await rescheduleAllNotifications();
  }

  void _onNotificationTapped(NotificationResponse response) {
    _log('Notification tapped: ${response.id}');
    // Handle notification tap logic here
  }
}

// Data classes and enums

enum NotificationChannel {
  reminders,
  challenges,
  system,
}

class NotificationPermissionStatus {
  final bool hasBasicPermission;
  final bool hasExactAlarmPermission;
  final bool canScheduleExactAlarms;

  const NotificationPermissionStatus({
    required this.hasBasicPermission,
    required this.hasExactAlarmPermission,
    required this.canScheduleExactAlarms,
  });

  bool get hasAllPermissions => hasBasicPermission && hasExactAlarmPermission;

  @override
  String toString() {
    return 'NotificationPermissionStatus(basic: $hasBasicPermission, exactAlarm: $hasExactAlarmPermission, canSchedule: $canScheduleExactAlarms)';
  }
}

class NotificationRequest {
  final int id;
  final String title;
  final String body;
  final DateTime scheduledTime;
  final Map<String, String> data;
  final NotificationChannel channel;

  const NotificationRequest({
    required this.id,
    required String title,
    required String body,
    required this.scheduledTime,
    this.data = const {},
    this.channel = NotificationChannel.reminders,
  }) : title = title, body = body;
}

class NotificationResult {
  final int id;
  final bool success;

  const NotificationResult(this.id, this.success);
}

class BatchScheduleResult {
  final List<NotificationResult> results;
  final int successCount;
  final int failureCount;

  const BatchScheduleResult(this.results, this.successCount, this.failureCount);

  bool get allSuccessful => failureCount == 0;
  double get successRate => results.isEmpty ? 0.0 : successCount / results.length;
}

class ScheduledNotificationInfo {
  final int id;
  final String title;
  final String body;
  final DateTime scheduledTime;
  final Map<String, String> data;
  final NotificationChannel channel;
  final DateTime createdAt;

  const ScheduledNotificationInfo({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledTime,
    required this.data,
    required this.channel,
    required this.createdAt,
  });

  factory ScheduledNotificationInfo.fromJson(Map<String, dynamic> json) {
    return ScheduledNotificationInfo(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      data: Map<String, String>.from(json['data'] as Map? ?? {}),
      channel: NotificationChannel.values[json['channel'] as int? ?? 0],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'scheduledTime': scheduledTime.toIso8601String(),
      'data': data,
      'channel': channel.index,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
