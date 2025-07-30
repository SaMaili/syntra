package app.inneract.syntra.notifications

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * Professional NotificationReceiver that handles notification delivery
 * Triggered by AlarmManager when exact notifications should be shown
 */
class SyntraNotificationReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "SyntraNotificationRcvr"

        private fun logInfo(message: String) {
            Log.i(TAG, message)
        }

        private fun logError(message: String, throwable: Throwable? = null) {
            Log.e(TAG, message, throwable)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        try {
            val notificationId = intent.getIntExtra("notification_id", -1)
            val title = intent.getStringExtra("title") ?: "Syntra Reminder"
            val body = intent.getStringExtra("body") ?: "Don't forget your challenge!"
            val channelId = intent.getStringExtra("channel_id") ?: SyntraNotificationManager.CHANNEL_REMINDERS

            if (notificationId == -1) {
                logError("Invalid notification ID received")
                return
            }

            // Extract custom data
            val data = mutableMapOf<String, String>()
            intent.extras?.keySet()?.forEach { key ->
                if (key.startsWith("data_")) {
                    val dataKey = key.removePrefix("data_")
                    val dataValue = intent.getStringExtra(key)
                    if (dataValue != null) {
                        data[dataKey] = dataValue
                    }
                }
            }

            logInfo("Receiving notification trigger: ID=$notificationId, Title=$title")

            // Show the notification
            val notificationManager = SyntraNotificationManager(context)
            notificationManager.showNotificationNow(
                notificationId,
                title,
                body,
                data,
                channelId
            )

            // Mark as triggered in stored notifications
            markNotificationAsTriggered(context, notificationId)

            logInfo("Successfully triggered notification: ID=$notificationId")

        } catch (e: Exception) {
            logError("Error in notification receiver", e)
        }
    }

    /**
     * Mark notification as triggered in persistent storage
     */
    private fun markNotificationAsTriggered(context: Context, notificationId: Int) {
        try {
            val notificationManager = SyntraNotificationManager(context)
            val notifications = notificationManager.getScheduledNotifications().toMutableList()

            val index = notifications.indexOfFirst { it.id == notificationId }
            if (index >= 0) {
                notifications[index] = notifications[index].copy(wasTriggered = true)

                // Save updated list back to preferences
                val prefs = context.getSharedPreferences("syntra_notifications", Context.MODE_PRIVATE)
                val jsonArray = org.json.JSONArray()
                notifications.forEach { notification ->
                    jsonArray.put(notification.toJson())
                }

                prefs.edit()
                    .putString("scheduled_notifications", jsonArray.toString())
                    .apply()

                logInfo("Marked notification $notificationId as triggered")
            }
        } catch (e: Exception) {
            logError("Failed to mark notification as triggered: $notificationId", e)
        }
    }
}
