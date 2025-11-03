package com.zombiegps

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.annotations.ReactModule

@ReactModule(name = ZombieGpsModule.NAME)
class ZombieGpsModule(reactContext: ReactApplicationContext) :
  NativeZombieGpsSpec(reactContext) {

  override fun getName(): String {
    return NAME
  }

  // Example method
  // See https://reactnative.dev/docs/native-modules-android
  override fun multiply(a: Double, b: Double): Double {
    return a * b
  }

  companion object {
    const val NAME = "ZombieGps"
  }
}
