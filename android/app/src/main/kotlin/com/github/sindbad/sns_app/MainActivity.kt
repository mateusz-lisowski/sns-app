package com.github.sindbad.sns_app

import android.content.Context
import android.os.BatteryManager
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {
    private val eventChannelName = "com.github.sindbad/battery"
    private var handler: Handler? = null
    private var runnable: Runnable? = null
    private val TAG = "MainActivity"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, eventChannelName).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    Log.d(TAG, "onListen called: Starting battery stream.")
                    val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
                    handler = Handler(Looper.getMainLooper())
                    runnable = object : Runnable {
                        override fun run() {
                            val current = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CURRENT_NOW)
                            Log.d(TAG, "Polling for battery current: $current µA")
                            events?.success(current)
                            handler?.postDelayed(this, 1000)
                        }
                    }
                    handler?.post(runnable!!)
                }

                override fun onCancel(arguments: Any?) {
                    Log.d(TAG, "onCancel called: Stopping battery stream.")
                    handler?.removeCallbacks(runnable!!)
                    runnable = null
                    handler = null
                }
            }
        )
    }
}
