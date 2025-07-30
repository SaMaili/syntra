package app.inneract.syntra

import android.app.AlarmManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import app.inneract.syntra.notifications.SyntraNotificationManager
import io.flutter.plugin.common.MethodCall

class MainActivity: FlutterActivity() {
    private val CHANNEL = "app.inneract.syntra/notifications"
    private lateinit var notificationManager: SyntraNotificationManager
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        android.util.Log.d("MainActivity", "Starting Flutter engine configuration...")

        try {
            // Initialize notification manager first
            android.util.Log.d("MainActivity", "Initializing notification manager...")
            notificationManager = SyntraNotificationManager(this)
            android.util.Log.d("MainActivity", "Notification manager initialized successfully")

            // Set up method channel with comprehensive error handling
            methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            methodChannel?.setMethodCallHandler { call, result ->
                try {
                    android.util.Log.d("MainActivity", "Method call received: ${call.method} with arguments: ${call.arguments}")
                    handleMethodCall(call, result)
                } catch (e: Exception) {
                    android.util.Log.e("MainActivity", "Error handling method call: ${call.method}", e)
                    result.error("NATIVE_ERROR", "Error in native method: ${e.message}", null)
                }
            }

            android.util.Log.d("MainActivity", "Method channel '${CHANNEL}' configured successfully")

            // Verify method channel is ready
            android.util.Log.d("MainActivity", "Method channel ready for calls")

        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "Error configuring Flutter engine", e)
        }
    }

    private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "canScheduleExactAlarms" -> {
                result.success(canScheduleExactAlarms())
            }
            "requestExactAlarmPermission" -> {
                requestExactAlarmPermission()
                result.success(null)
            }
            "scheduleExactNotification" -> {
                val id = call.argument<Int>("id") ?: 0
                val title = call.argument<String>("title") ?: ""
                val body = call.argument<String>("body") ?: ""
                val triggerTime = call.argument<Long>("triggerTime") ?: 0L
                val data = call.argument<Map<String, String>>("data") ?: emptyMap()
                val channelId = call.argument<String>("channelId") ?: "syntra_reminders"

                val success = notificationManager.scheduleExactNotification(
                    id, title, body, triggerTime, data, channelId
                )
                result.success(success)
            }
            "batchScheduleNotifications" -> {
                val notifications = call.argument<List<Map<String, Any>>>("notifications") ?: emptyList()

                // Convert raw maps to NotificationRequest objects
                val notificationRequests = notifications.map { notifMap ->
                    SyntraNotificationManager.NotificationRequest(
                        id = notifMap["id"] as? Int ?: 0,
                        title = notifMap["title"] as? String ?: "",
                        body = notifMap["body"] as? String ?: "",
                        triggerTime = notifMap["triggerTime"] as? Long ?: 0L,
                        data = notifMap["data"] as? Map<String, String> ?: emptyMap(),
                        channelId = notifMap["channelId"] as? String ?: "syntra_reminders"
                    )
                }

                val batchResult = notificationManager.batchScheduleNotifications(notificationRequests)

                // Convert BatchResult to map for Dart
                val resultMap = mapOf(
                    "results" to batchResult.results.map { (id, success) ->
                        mapOf("id" to id, "success" to success)
                    },
                    "successCount" to batchResult.successCount,
                    "failureCount" to batchResult.failureCount
                )

                result.success(resultMap)
            }
            "cancelNotification" -> {
                val id = call.argument<Int>("id") ?: 0
                val success = notificationManager.cancelNotification(id)
                result.success(success)
            }
            "showNotificationNow" -> {
                val id = call.argument<Int>("id") ?: 0
                val title = call.argument<String>("title") ?: ""
                val body = call.argument<String>("body") ?: ""
                val data = call.argument<Map<String, String>>("data") ?: emptyMap()
                val channelId = call.argument<String>("channelId") ?: "syntra_reminders"

                notificationManager.showNotificationNow(id, title, body, data, channelId)
                result.success(null)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun canScheduleExactAlarms(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
            alarmManager.canScheduleExactAlarms()
        } else {
            true
        }
    }

    private fun requestExactAlarmPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM)
            startActivity(intent)
        }
    }
}
