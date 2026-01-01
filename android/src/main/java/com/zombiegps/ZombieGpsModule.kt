package com.zombiegps

import android.annotation.SuppressLint
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.location.Location
import android.os.Build
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.modules.core.DeviceEventManagerModule
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationServices
import com.google.gson.Gson

@ReactModule(name = ZombieGpsModule.NAME)
class ZombieGpsModule(reactContext: ReactApplicationContext) :
  NativeZombieGpsSpec(reactContext) {

  private val fusedLocationClient: FusedLocationProviderClient = LocationServices.getFusedLocationProviderClient(reactContext)

  init {
      instance = this
  }

  override fun getName(): String {
    return NAME
  }

  override fun ready(config: ReadableMap, promise: Promise) {
      try {
          val configMap = config.toHashMap()
          
          // Validate apiURL
          val apiUrl = configMap["apiURL"] as? String
          if (apiUrl.isNullOrEmpty()) {
              promise.reject("zombie_gps_invalid_config", "apiURL is required")
              return
          }

          val gson = Gson()
          val configJson = gson.toJson(configMap)

          val prefs = reactApplicationContext.getSharedPreferences(NAME, Context.MODE_PRIVATE)
          prefs.edit().putString("uploadConfig", configJson).apply()

          promise.resolve(null)
      } catch (e: Exception) {
          promise.reject("zombie_gps_error", e.message, e)
      }
  }

  @SuppressLint("MissingPermission")
  override fun startMonitoring() {
      val intent = Intent(reactApplicationContext, LocationReceiver::class.java)
      val pendingIntent = PendingIntent.getBroadcast(
          reactApplicationContext,
          0,
          intent,
          PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
      )

      val locationRequest = LocationRequest.create().apply {
          interval = 15 * 60 * 1000 // 15 minutes
          fastestInterval = 5 * 60 * 1000
          priority = LocationRequest.PRIORITY_BALANCED_POWER_ACCURACY
      }

      fusedLocationClient.requestLocationUpdates(locationRequest, pendingIntent)
  }

  override fun stopMonitoring() {
      val intent = Intent(reactApplicationContext, LocationReceiver::class.java)
      val pendingIntent = PendingIntent.getBroadcast(
          reactApplicationContext,
          0,
          intent,
          PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
      )
      fusedLocationClient.removeLocationUpdates(pendingIntent)
  }

  override fun addListener(eventName: String?) {
    // Keep: Required for RN built-in Event Emitter Calls.
  }

  override fun removeListeners(count: Double) {
    // Keep: Required for RN built-in Event Emitter Calls.
  }

  private fun sendEvent(eventName: String, params: Any?) {
      reactApplicationContext
          .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
          .emit(eventName, params)
  }

  companion object {
    const val NAME = "ZombieGps"
    private var instance: ZombieGpsModule? = null

    fun sendLocationEvent(location: Location) {
        val params = Arguments.createMap().apply {
            putDouble("latitude", location.latitude)
            putDouble("longitude", location.longitude)
            putDouble("timestamp", location.time.toDouble() / 1000)
        }
        instance?.sendEvent("ZombieGPSLocation", params)
    }
  }
}