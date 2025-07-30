package app.inneract.syntra.notifications

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import android.provider.Settings
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import org.json.JSONArray
import org.json.JSONObject
import java.util.*
import app.inneract.syntra.R

/**
 * Enterprise-level NotificationManager for exact timing and reliability
 * Implements professional patterns used by MyFitnessPal, Todoist, Samsung Health
 */
class SyntraNotificationManager(private val context: Context) {

    companion object {
        private const val TAG = "SyntraNotificationMgr"
        private const val PREFS_NAME = "syntra_notifications"
        private const val KEY_SCHEDULED_NOTIFICATIONS = "scheduled_notifications"

        // Professional notification channels
        const val CHANNEL_REMINDERS = "syntra_reminders"
        const val CHANNEL_CHALLENGES = "syntra_challenges"
        const val CHANNEL_ACHIEVEMENTS = "syntra_achievements"
        const val CHANNEL_SYSTEM = "syntra_system"

        // Request codes for different notification types
        private const val REQUEST_CODE_BASE = 10000
        private const val REQUEST_CODE_REMINDER = REQUEST_CODE_BASE + 1
        private const val REQUEST_CODE_CHALLENGE = REQUEST_CODE_BASE + 2
        private const val REQUEST_CODE_ACHIEVEMENT = REQUEST_CODE_BASE + 3

        private fun logInfo(message: String) {
            Log.i(TAG, message)
        }

        private fun logError(message: String, throwable: Throwable? = null) {
            Log.e(TAG, message, throwable)
        }
    }

    private val alarmManager: AlarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
    private val notificationManager: NotificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    private val prefs: SharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    init {
        createNotificationChannels()
    }

    /**
     * Create professional notification channels
     */
    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channels = listOf(
                NotificationChannel(
                    CHANNEL_REMINDERS,
                    "Challenge Reminders",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "Notifications for challenge reminders and daily goals"
                    enableVibration(true)
                    setShowBadge(true)
                },
                NotificationChannel(
                    CHANNEL_CHALLENGES,
                    "Challenge Updates",
                    NotificationManager.IMPORTANCE_DEFAULT
                ).apply {
                    description = "Updates about your active challenges"
                    enableVibration(true)
                    setShowBadge(true)
                },
                NotificationChannel(
                    CHANNEL_SYSTEM,
                    "System Notifications",
                    NotificationManager.IMPORTANCE_LOW
                ).apply {
                    description = "System updates and maintenance notifications"
                    setShowBadge(false)
                }
            )

            channels.forEach { channel ->
                notificationManager.createNotificationChannel(channel)
            }

            logInfo("Created ${channels.size} notification channels")
        }
    }

    /**
     * Schedule exact notification with enterprise-level reliability
     * Uses exactAllowWhileIdle for precise timing like professional apps
     */
    fun scheduleExactNotification(
        id: Int,
        title: String,
        body: String,
        triggerTimeMillis: Long,
        data: Map<String, String> = emptyMap(),
        channelId: String = CHANNEL_REMINDERS
    ): Boolean {
        try {
            // Validate input parameters
            if (triggerTimeMillis <= System.currentTimeMillis()) {
                logError("Cannot schedule notification in the past: $triggerTimeMillis")
                return false
            }

            // Check for exact alarm permission on Android 12+
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                if (!alarmManager.canScheduleExactAlarms()) {
                    logError("SCHEDULE_EXACT_ALARM permission not granted")
                    return false
                }
            }

            // Create the notification intent
            val intent = Intent(context, SyntraNotificationReceiver::class.java).apply {
                putExtra("notification_id", id)
                putExtra("title", title)
                putExtra("body", body)
                putExtra("channel_id", channelId)

                // Add custom data
                data.forEach { (key, value) ->
                    putExtra("data_$key", value)
                }
            }

            val pendingIntent = PendingIntent.getBroadcast(
                context,
                id,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            // Schedule with exactAllowWhileIdle for maximum reliability
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                triggerTimeMillis,
                pendingIntent
            )

            // Store notification data for boot recovery
            storeScheduledNotification(
                SyntraBootReceiver.ScheduledNotification(
                    id = id,
                    title = title,
                    body = body,
                    triggerTime = triggerTimeMillis,
                    data = data
                )
            )

            logInfo("Scheduled exact notification: ID=$id, Time=${Date(triggerTimeMillis)}")
            return true

        } catch (e: Exception) {
            logError("Failed to schedule notification: ID=$id", e)
            return false
        }
    }

    /**
     * Batch schedule notifications for efficiency (like professional apps)
     * Useful for scheduling week/month ahead
     */
    fun batchScheduleNotifications(notifications: List<NotificationRequest>): BatchResult {
        val results = mutableListOf<Pair<Int, Boolean>>()
        var successCount = 0

        notifications.forEach { request ->
            val success = scheduleExactNotification(
                request.id,
                request.title,
                request.body,
                request.triggerTime,
                request.data,
                request.channelId
            )

            results.add(request.id to success)
            if (success) successCount++
        }

        logInfo("Batch scheduling completed: $successCount/${notifications.size} successful")
        return BatchResult(results, successCount, notifications.size - successCount)
    }

    /**
     * Cancel scheduled notification
     */
    fun cancelNotification(id: Int): Boolean {
        return try {
            cancelAlarm(id)
            removeStoredNotification(id)
            logInfo("Cancelled notification: ID=$id")
            true
        } catch (e: Exception) {
            logError("Failed to cancel notification: ID=$id", e)
            false
        }
    }

    /**
     * Cancel alarm (used internally and by BootReceiver)
     */
    fun cancelAlarm(id: Int) {
        val intent = Intent(context, SyntraNotificationReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            id,
            intent,
            PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
        )

        pendingIntent?.let {
            alarmManager.cancel(it)
            it.cancel()
        }
    }

    /**
     * Show notification immediately (used for testing and missed notifications)
     */
    fun showNotificationNow(
        id: Int,
        title: String,
        body: String,
        data: Map<String, String> = emptyMap(),
        channelId: String = CHANNEL_REMINDERS
    ) {
        try {
            // Create tap intent to open main activity (using launcher intent)
            val tapIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)?.apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }

            // Add notification data to intent if available
            tapIntent?.let { intent ->
                data.forEach { (key, value) ->
                    intent.putExtra("notification_$key", value)
                }
            }

            val tapPendingIntent = tapIntent?.let { intent ->
                PendingIntent.getActivity(
                    context,
                    id,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
            }

            // Build professional notification
            val notification = NotificationCompat.Builder(context, channelId)
                .setSmallIcon(R.drawable.ic_notification) // Use custom Syntra logo
                .setContentTitle(title)
                .setContentText(body)
                .setStyle(NotificationCompat.BigTextStyle().bigText(body))
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setDefaults(NotificationCompat.DEFAULT_ALL)
                .setAutoCancel(true)
                .apply {
                    // Only set content intent if we have a valid intent
                    tapPendingIntent?.let { setContentIntent(it) }
                }
                .setCategory(NotificationCompat.CATEGORY_REMINDER)
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .build()

            NotificationManagerCompat.from(context).notify(id, notification)
            logInfo("Showed notification immediately: ID=$id")

        } catch (e: Exception) {
            logError("Failed to show notification: ID=$id", e)
        }
    }

    /**
     * Get all scheduled notifications
     */
    fun getScheduledNotifications(): List<SyntraBootReceiver.ScheduledNotification> {
        val notificationsJson = prefs.getString(KEY_SCHEDULED_NOTIFICATIONS, "[]")
        val notifications = mutableListOf<SyntraBootReceiver.ScheduledNotification>()

        try {
            val jsonArray = JSONArray(notificationsJson)
            for (i in 0 until jsonArray.length()) {
                val jsonObject = jsonArray.getJSONObject(i)
                notifications.add(SyntraBootReceiver.ScheduledNotification.fromJson(jsonObject))
            }
        } catch (e: Exception) {
            logError("Error getting scheduled notifications", e)
        }

        return notifications
    }

    /**
     * Check if exact alarm permission is available
     */
    fun canScheduleExactAlarms(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            alarmManager.canScheduleExactAlarms()
        } else {
            true
        }
    }

    /**
     * Request exact alarm permission (Android 12+)
     */
    fun requestExactAlarmPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && !alarmManager.canScheduleExactAlarms()) {
            val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                data = android.net.Uri.parse("package:${context.packageName}")
            }

            if (context is android.app.Activity) {
                context.startActivity(intent)
            } else {
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                context.startActivity(intent)
            }
        }
    }

    /**
     * Store scheduled notification for boot recovery
     */
    private fun storeScheduledNotification(notification: SyntraBootReceiver.ScheduledNotification) {
        val notifications = getScheduledNotifications().toMutableList()

        // Remove existing notification with same ID
        notifications.removeAll { it.id == notification.id }

        // Add new notification
        notifications.add(notification)

        // Save back to preferences
        val jsonArray = JSONArray()
        notifications.forEach { notif ->
            jsonArray.put(notif.toJson())
        }

        prefs.edit()
            .putString(KEY_SCHEDULED_NOTIFICATIONS, jsonArray.toString())
            .apply()
    }

    /**
     * Remove stored notification
     */
    private fun removeStoredNotification(id: Int) {
        val notifications = getScheduledNotifications().toMutableList()
        notifications.removeAll { it.id == id }

        val jsonArray = JSONArray()
        notifications.forEach { notif ->
            jsonArray.put(notif.toJson())
        }

        prefs.edit()
            .putString(KEY_SCHEDULED_NOTIFICATIONS, jsonArray.toString())
            .apply()
    }

    /**
     * Data classes for batch operations
     */
    data class NotificationRequest(
        val id: Int,
        val title: String,
        val body: String,
        val triggerTime: Long,
        val data: Map<String, String> = emptyMap(),
        val channelId: String = CHANNEL_REMINDERS
    )

    data class BatchResult(
        val results: List<Pair<Int, Boolean>>,
        val successCount: Int,
        val failureCount: Int
    )
}
