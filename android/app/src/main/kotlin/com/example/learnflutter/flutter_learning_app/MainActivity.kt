package com.example.learnflutter.flutter_learning_app

import android.content.Context
import android.os.BatteryManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * The ONE and only Android Activity of the whole Flutter app.
 * Every Flutter "screen" is drawn inside this Activity by the Flutter engine.
 *
 * Here we also register a MethodChannel so Dart can call Android APIs.
 * Dart side: lib/features/components/platform_channel_demo.dart
 */
class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getBatteryLevel" -> {
                        val level = batteryLevel()
                        if (level >= 0) result.success(level)
                        else result.error("UNAVAILABLE", "Battery level not available", null)
                    }
                    "getDeviceInfo" -> result.success(
                        mapOf(
                            "manufacturer" to Build.MANUFACTURER,
                            "model" to Build.MODEL,
                            "androidVersion" to Build.VERSION.RELEASE,
                            "sdkInt" to Build.VERSION.SDK_INT,
                        )
                    )
                    else -> result.notImplemented()
                }
            }
    }

    private fun batteryLevel(): Int {
        val bm = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        return bm.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
    }

    private companion object {
        const val CHANNEL = "learn.flutter/device"
    }
}
