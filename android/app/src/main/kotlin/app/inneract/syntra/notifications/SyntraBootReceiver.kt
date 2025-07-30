package app.inneract.syntra.notifications

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import android.util.Log
import org.json.JSONArray
import org.json.JSONObject
import java.util.*

/**
 * Professional-grade Boot Receiver for enterprise-level notification reliability
 * Handles all boot scenarios including device restart, app updates, timezone changes
 * Similar to implementations in MyFitnessPal, Todoist, Samsung Health
 */
class SyntraBootReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "SyntraBootReceiver"
        private const val PREFS_NAME = "syntra_notifications"
        private const val KEY_SCHEDULED_NOTIFICATIONS = "scheduled_notifications"
        private const val KEY_LAST_BOOT_TIME = "last_boot_time"
        private const val KEY_NOTIFICATION_ENABLED = "notifications_enabled"

        // Professional logging for production debugging
        private fun logInfo(message: String) {
            Log.i(TAG, message)
        }

        private fun logError(message: String, throwable: Throwable? = null) {
            Log.e(TAG, message, throwable)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action
        logInfo("Boot receiver triggered with action: $action")

        try {
            when (action) {
                Intent.ACTION_BOOT_COMPLETED,
                "android.intent.action.LOCKED_BOOT_COMPLETED" -> {
                    logInfo("Device boot completed - rescheduling notifications")
                    handleBootCompleted(context)
                }
                Intent.ACTION_REBOOT -> {
                    logInfo("Device reboot detected - rescheduling notifications")
                    handleBootCompleted(context)
                }
                "android.intent.action.QUICKBOOT_POWERON",
                "com.htc.intent.action.QUICKBOOT_POWERON" -> {
                    logInfo("Quick boot detected - rescheduling notifications")
                    handleBootCompleted(context)
                }
                Intent.ACTION_MY_PACKAGE_REPLACED,
                Intent.ACTION_PACKAGE_REPLACED -> {
                    logInfo("App updated - rescheduling notifications")
                    handleAppUpdate(context)
                }
                Intent.ACTION_TIMEZONE_CHANGED -> {
                    logInfo("Timezone changed - adjusting notification times")
                    handleTimezoneChange(context)
                }
                "android.intent.action.TIME_SET" -> {
                    logInfo("System time changed - validating notifications")
                    handleTimeChange(context)
                }
                else -> {
                    logInfo("Unhandled boot action: $action")
                }
            }
        } catch (e: Exception) {
            logError("Error in boot receiver", e)
        }
    }

    /**
     * Handle device boot completion - restore all scheduled notifications
     */
    private fun handleBootCompleted(context: Context) {
        val prefs = getNotificationPrefs(context)
        val currentTime = System.currentTimeMillis()

        // Update last boot time for tracking
        prefs.edit().putLong(KEY_LAST_BOOT_TIME, currentTime).apply()

        // Check if notifications are enabled
        if (!prefs.getBoolean(KEY_NOTIFICATION_ENABLED, true)) {
            logInfo("Notifications disabled - skipping boot restoration")
            return
        }

        // Restore all scheduled notifications
        restoreScheduledNotifications(context, prefs)

        // Clean up expired notifications
        cleanupExpiredNotifications(context, prefs)

        logInfo("Boot restoration completed successfully")
    }

    /**
     * Handle app update - preserve notification data and reschedule
     */
    private fun handleAppUpdate(context: Context) {
        val prefs = getNotificationPrefs(context)

        // Mark that an update occurred for analytics
        prefs.edit().putLong("last_app_update", System.currentTimeMillis()).apply()

        // Reschedule all notifications with preserved data
        restoreScheduledNotifications(context, prefs)

        logInfo("App update handling completed")
    }

    /**
     * Handle timezone change - adjust all notification times
     */
    private fun handleTimezoneChange(context: Context) {
        val prefs = getNotificationPrefs(context)
        val scheduledNotifications = getScheduledNotifications(prefs)

        if (scheduledNotifications.isEmpty()) {
            logInfo("No notifications to adjust for timezone change")
            return
        }

        // Cancel existing alarms
        val notificationManager = SyntraNotificationManager(context)
        scheduledNotifications.forEach { notification ->
            notificationManager.cancelAlarm(notification.id)
        }

        // Reschedule with timezone adjustment
        scheduledNotifications.forEach { notification ->
            if (notification.triggerTime > System.currentTimeMillis()) {
                // Only reschedule future notifications
                val success = notificationManager.scheduleExactNotification(
                    notification.id,
                    notification.title,
                    notification.body,
                    notification.triggerTime,
                    notification.data
                )

                if (success) {
                    logInfo("Rescheduled notification ${notification.id} for timezone change")
                } else {
                    logError("Failed to reschedule notification ${notification.id}")
                }
            }
        }

        logInfo("Timezone change handling completed")
    }

    /**
     * Handle system time change - validate notification scheduling
     */
    private fun handleTimeChange(context: Context) {
        val prefs = getNotificationPrefs(context)
        val scheduledNotifications = getScheduledNotifications(prefs)

        // Check for notifications that might have been missed due to time change
        val currentTime = System.currentTimeMillis()
        val missedNotifications = scheduledNotifications.filter { notification ->
            notification.triggerTime <= currentTime &&
            !notification.wasTriggered &&
            (currentTime - notification.triggerTime) < (5 * 60 * 1000) // Within 5 minutes
        }

        if (missedNotifications.isNotEmpty()) {
            logInfo("Found ${missedNotifications.size} potentially missed notifications")
            val notificationManager = SyntraNotificationManager(context)

            // Trigger missed notifications immediately
            missedNotifications.forEach { notification ->
                notificationManager.showNotificationNow(
                    notification.id,
                    notification.title,
                    notification.body,
                    notification.data
                )

                // Mark as triggered
                markNotificationAsTriggered(prefs, notification.id)
            }
        }

        logInfo("Time change handling completed")
    }

    /**
     * Restore all scheduled notifications from persistent storage
     */
    private fun restoreScheduledNotifications(context: Context, prefs: SharedPreferences) {
        val scheduledNotifications = getScheduledNotifications(prefs)

        if (scheduledNotifications.isEmpty()) {
            logInfo("No scheduled notifications to restore")
            return
        }

        val notificationManager = SyntraNotificationManager(context)
        val currentTime = System.currentTimeMillis()
        var restoredCount = 0
        var expiredCount = 0

        scheduledNotifications.forEach { notification ->
            if (notification.triggerTime > currentTime && !notification.wasTriggered) {
                // Only restore future, non-triggered notifications
                val success = notificationManager.scheduleExactNotification(
                    notification.id,
                    notification.title,
                    notification.body,
                    notification.triggerTime,
                    notification.data
                )

                if (success) {
                    restoredCount++
                    logInfo("Restored notification: ${notification.id}")
                } else {
                    logError("Failed to restore notification: ${notification.id}")
                }
            } else {
                expiredCount++
            }
        }

        logInfo("Restoration complete: $restoredCount restored, $expiredCount expired")
    }

    /**
     * Clean up expired notifications from storage
     */
    private fun cleanupExpiredNotifications(context: Context, prefs: SharedPreferences) {
        val scheduledNotifications = getScheduledNotifications(prefs)
        val currentTime = System.currentTimeMillis()
        val cleanupThreshold = currentTime - (24 * 60 * 60 * 1000) // 24 hours ago

        val validNotifications = scheduledNotifications.filter { notification ->
            notification.triggerTime > cleanupThreshold
        }

        if (validNotifications.size < scheduledNotifications.size) {
            saveScheduledNotifications(prefs, validNotifications)
            val cleanedCount = scheduledNotifications.size - validNotifications.size
            logInfo("Cleaned up $cleanedCount expired notifications")
        }
    }

    /**
     * Get notification SharedPreferences
     */
    private fun getNotificationPrefs(context: Context): SharedPreferences {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    }

    /**
     * Get all scheduled notifications from storage
     */
    private fun getScheduledNotifications(prefs: SharedPreferences): List<ScheduledNotification> {
        val notificationsJson = prefs.getString(KEY_SCHEDULED_NOTIFICATIONS, "[]")
        val notifications = mutableListOf<ScheduledNotification>()

        try {
            val jsonArray = JSONArray(notificationsJson)
            for (i in 0 until jsonArray.length()) {
                val jsonObject = jsonArray.getJSONObject(i)
                notifications.add(ScheduledNotification.fromJson(jsonObject))
            }
        } catch (e: Exception) {
            logError("Error parsing scheduled notifications", e)
        }

        return notifications
    }

    /**
     * Save scheduled notifications to storage
     */
    private fun saveScheduledNotifications(prefs: SharedPreferences, notifications: List<ScheduledNotification>) {
        val jsonArray = JSONArray()
        notifications.forEach { notification ->
            jsonArray.put(notification.toJson())
        }

        prefs.edit()
            .putString(KEY_SCHEDULED_NOTIFICATIONS, jsonArray.toString())
            .apply()
    }

    /**
     * Mark a notification as triggered
     */
    private fun markNotificationAsTriggered(prefs: SharedPreferences, notificationId: Int) {
        val notifications = getScheduledNotifications(prefs).toMutableList()
        val index = notifications.indexOfFirst { it.id == notificationId }

        if (index >= 0) {
            notifications[index] = notifications[index].copy(wasTriggered = true)
            saveScheduledNotifications(prefs, notifications)
        }
    }

    /**
     * Data class for scheduled notification information
     */
    data class ScheduledNotification(
        val id: Int,
        val title: String,
        val body: String,
        val triggerTime: Long,
        val data: Map<String, String> = emptyMap(),
        val wasTriggered: Boolean = false,
        val createdAt: Long = System.currentTimeMillis()
    ) {
        fun toJson(): JSONObject {
            val json = JSONObject()
            json.put("id", id)
            json.put("title", title)
            json.put("body", body)
            json.put("triggerTime", triggerTime)
            json.put("wasTriggered", wasTriggered)
            json.put("createdAt", createdAt)

            // Convert data map to JSON
            val dataJson = JSONObject()
            data.forEach { (key, value) ->
                dataJson.put(key, value)
            }
            json.put("data", dataJson)

            return json
        }

        companion object {
            fun fromJson(json: JSONObject): ScheduledNotification {
                val dataJson = json.optJSONObject("data") ?: JSONObject()
                val data = mutableMapOf<String, String>()

                dataJson.keys().forEach { key ->
                    data[key] = dataJson.getString(key)
                }

                return ScheduledNotification(
                    id = json.getInt("id"),
                    title = json.getString("title"),
                    body = json.getString("body"),
                    triggerTime = json.getLong("triggerTime"),
                    data = data,
                    wasTriggered = json.optBoolean("wasTriggered", false),
                    createdAt = json.optLong("createdAt", System.currentTimeMillis())
                )
            }
        }
    }
}
