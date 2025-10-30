package com.github.sindbad.sns_app

import android.content.Context
import android.location.GnssStatus
import android.location.LocationManager
import android.os.BatteryManager
import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {
    private val batteryEventChannel = "com.github.sindbad/battery"
    private val satelliteEventChannel = "com.github.sindbad/satellite"
    private var batteryHandler: Handler? = null
    private var batteryRunnable: Runnable? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Battery channel
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, batteryEventChannel).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
                    batteryHandler = Handler(Looper.getMainLooper())
                    batteryRunnable = object : Runnable {
                        override fun run() {
                            val current = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CURRENT_NOW)
                            events?.success(current)
                            batteryHandler?.postDelayed(this, 1000)
                        }
                    }
                    batteryHandler?.post(batteryRunnable!!)
                }

                override fun onCancel(arguments: Any?) {
                    batteryHandler?.removeCallbacks(batteryRunnable!!)
                    batteryRunnable = null
                    batteryHandler = null
                }
            }
        )

        // Satellite channel
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, satelliteEventChannel).setStreamHandler(
            object : EventChannel.StreamHandler {
                private var gnssStatusCallback: GnssStatus.Callback? = null

                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    val locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
                    gnssStatusCallback = object : GnssStatus.Callback() {
                        override fun onSatelliteStatusChanged(status: GnssStatus) {
                            val satellites = mutableListOf<Map<String, Any>>()
                            for (i in 0 until status.satelliteCount) {
                                val constellation = when (status.getConstellationType(i)) {
                                    GnssStatus.CONSTELLATION_GPS -> "GPS"
                                    GnssStatus.CONSTELLATION_SBAS -> "SBAS"
                                    GnssStatus.CONSTELLATION_GLONASS -> "GLONASS"
                                    GnssStatus.CONSTELLATION_QZSS -> "QZSS"
                                    GnssStatus.CONSTELLATION_BEIDOU -> "BEIDOU"
                                    GnssStatus.CONSTELLATION_GALILEO -> "GALILEO"
                                    GnssStatus.CONSTELLATION_IRNSS -> "IRNSS"
                                    else -> "UNKNOWN"
                                }
                                satellites.add(
                                    mapOf(
                                        "prn" to status.getSvid(i),
                                        "name" to "$constellation ${status.getSvid(i)}",
                                        "signalStrength" to status.getCn0DbHz(i),
                                        "azimuth" to status.getAzimuthDegrees(i),
                                        "elevation" to status.getElevationDegrees(i)
                                    )
                                )
                            }
                            events?.success(satellites)
                        }
                    }
                    try {
                        locationManager.registerGnssStatusCallback(gnssStatusCallback!!, Handler(Looper.getMainLooper()))
                    } catch (e: SecurityException) {
                        events?.error("PERMISSION_DENIED", "Location permission not granted", null)
                    }
                }

                override fun onCancel(arguments: Any?) {
                    val locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
                    if (gnssStatusCallback != null) {
                        locationManager.unregisterGnssStatusCallback(gnssStatusCallback!!)
                        gnssStatusCallback = null
                    }
                }
            }
        )
    }
}
