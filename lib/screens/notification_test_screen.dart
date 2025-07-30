import 'package:flutter/material.dart';
import '../services/syntra_notification_service.dart';
import '../widgets/notification_permission_widget.dart';

/**
 * Professional Example Usage and Testing Screen
 * Demonstrates how to use the enterprise-level notification system
 * Similar to settings screens in MyFitnessPal, Todoist, Samsung Health
 */
class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({Key? key}) : super(key: key);

  @override
  _NotificationTestScreenState createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  final _service = SyntraNotificationService.instance;
  List<ScheduledNotificationInfo> _scheduledNotifications = [];
  bool _isLoading = false;
  NotificationPermissionStatus? _permissionStatus;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    setState(() => _isLoading = true);

    try {
      final initialized = await _service.initialize();
      if (initialized) {
        await _checkPermissions();
        await _loadScheduledNotifications();
      }
    } catch (e) {
      _showSnackBar('Failed to initialize: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkPermissions() async {
    final status = await _service.requestPermissions();
    setState(() => _permissionStatus = status);
  }

  Future<void> _loadScheduledNotifications() async {
    final notifications = await _service.getScheduledNotifications();
    setState(() => _scheduledNotifications = notifications);
  }

  Future<void> _showPermissionDialog() async {
    final granted = await NotificationPermissionWidget.showPermissionDialog(context);
    if (granted) {
      await _checkPermissions();
      _showSnackBar('Permissions granted successfully!', Colors.green);
    }
  }

  Future<void> _scheduleTestNotification() async {
    // Schedule a test notification 10 seconds from now
    final scheduledTime = DateTime.now().add(const Duration(seconds: 10));

    final success = await _service.scheduleExactNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: '🎯 Test Reminder',
      body: 'This is a test notification from Syntra!',
      scheduledTime: scheduledTime,
      data: {
        'type': 'test',
        'challenge_id': 'test_challenge',
      },
      channel: NotificationChannel.reminders,
    );

    if (success) {
      _showSnackBar('Test notification scheduled for ${_formatTime(scheduledTime)}', Colors.green);
      await _loadScheduledNotifications();
    } else {
      _showSnackBar('Failed to schedule notification', Colors.red);
    }
  }

  Future<void> _scheduleWeeklyReminders() async {
    final now = DateTime.now();
    final notifications = <NotificationRequest>[];

    // Schedule daily reminders for the next 7 days (like professional apps)
    for (int i = 1; i <= 7; i++) {
      final scheduledTime = DateTime(
        now.year,
        now.month,
        now.day + i,
        9, // 9 AM
        0,
      );

      notifications.add(NotificationRequest(
        id: 1000 + i,
        title: '💪 Daily Challenge Reminder',
        body: 'Time for your daily challenge! Keep building those healthy habits.',
        scheduledTime: scheduledTime,
        data: {
          'type': 'daily_reminder',
          'day': i.toString(),
        },
        channel: NotificationChannel.reminders,
      ));
    }

    final result = await _service.batchScheduleNotifications(notifications);

    _showSnackBar(
      'Scheduled ${result.successCount}/${notifications.length} weekly reminders',
      result.allSuccessful ? Colors.green : Colors.orange,
    );

    await _loadScheduledNotifications();
  }

  Future<void> _scheduleImmediateNotification() async {
    await _service.showNotificationNow(
      id: 9999,
      title: '🚀 Immediate Test',
      body: 'This notification appears immediately!',
      data: {'type': 'immediate_test'},
    );

    _showSnackBar('Immediate notification sent!', Colors.blue);
  }

  Future<void> _cancelNotification(int id) async {
    final success = await _service.cancelNotification(id);
    if (success) {
      _showSnackBar('Notification cancelled', Colors.orange);
      await _loadScheduledNotifications();
    } else {
      _showSnackBar('Failed to cancel notification', Colors.red);
    }
  }

  Future<void> _rescheduleAll() async {
    final success = await _service.rescheduleAllNotifications();
    _showSnackBar(
      success ? 'All notifications rescheduled' : 'Failed to reschedule',
      success ? Colors.green : Colors.red,
    );
    await _loadScheduledNotifications();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month} ${_formatTime(date)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification System Test'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadScheduledNotifications,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPermissionStatus(),
                  const SizedBox(height: 24),
                  _buildTestActions(),
                  const SizedBox(height: 24),
                  _buildScheduledNotificationsList(),
                ],
              ),
            ),
    );
  }

  Widget _buildPermissionStatus() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.security,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Permission Status',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_permissionStatus != null) ...[
              _buildStatusItem('Basic Notifications', _permissionStatus!.hasBasicPermission),
              _buildStatusItem('Exact Timing', _permissionStatus!.hasExactAlarmPermission),
              _buildStatusItem('Can Schedule Exact', _permissionStatus!.canScheduleExactAlarms),
            ] else
              const Text('Checking permissions...'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showPermissionDialog,
                icon: const Icon(Icons.settings),
                label: const Text('Manage Permissions'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, bool isGranted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isGranted ? Icons.check_circle : Icons.cancel,
            color: isGranted ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildTestActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.science,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Test Actions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _scheduleTestNotification,
                  icon: const Icon(Icons.schedule, size: 18),
                  label: const Text('Test (10s)'),
                ),
                ElevatedButton.icon(
                  onPressed: _scheduleImmediateNotification,
                  icon: const Icon(Icons.flash_on, size: 18),
                  label: const Text('Immediate'),
                ),
                ElevatedButton.icon(
                  onPressed: _scheduleWeeklyReminders,
                  icon: const Icon(Icons.date_range, size: 18),
                  label: const Text('Weekly'),
                ),
                ElevatedButton.icon(
                  onPressed: _rescheduleAll,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Reschedule'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduledNotificationsList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.list,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Scheduled Notifications (${_scheduledNotifications.length})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_scheduledNotifications.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No scheduled notifications',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _scheduledNotifications.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final notification = _scheduledNotifications[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Icon(
                        Icons.notifications,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      notification.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notification.body),
                        const SizedBox(height: 4),
                        Text(
                          'Scheduled: ${_formatDate(notification.scheduledTime)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () => _cancelNotification(notification.id),
                    ),
                    isThreeLine: true,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
