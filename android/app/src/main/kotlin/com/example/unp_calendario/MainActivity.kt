package com.pzoo.planazoo

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        ensureDefaultNotificationChannel()
    }

    /// Canal usado por FCM / Cloud Functions (`channelId: planazoo_default`).
    private fun ensureDefaultNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channelId = "planazoo_default"
        val manager = getSystemService(NotificationManager::class.java) ?: return
        if (manager.getNotificationChannel(channelId) != null) return
        val channel = NotificationChannel(
            channelId,
            "Planazoo",
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = "Invitaciones y avisos de Planazoo"
        }
        manager.createNotificationChannel(channel)
    }
}
