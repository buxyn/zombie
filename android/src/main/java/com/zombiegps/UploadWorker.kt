package com.zombiegps

import android.content.Context
import androidx.work.Worker
import androidx.work.WorkerParameters
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import java.io.IOException

class UploadWorker(appContext: Context, workerParams: WorkerParameters) :
    Worker(appContext, workerParams) {

    override fun doWork(): Result {
        val prefs = applicationContext.getSharedPreferences(ZombieGpsModule.NAME, Context.MODE_PRIVATE)
        val configJson = prefs.getString("uploadConfig", null) ?: return Result.failure()

        val gson = Gson()
        val type = object : TypeToken<Map<String, Any>>() {}.type
        val config: Map<String, Any> = gson.fromJson(configJson, type)

        val apiUrl = config["apiURL"] as? String ?: return Result.failure()
        
        val lat = inputData.getDouble("latitude", 0.0)
        val lng = inputData.getDouble("longitude", 0.0)
        
        if (lat == 0.0 && lng == 0.0) return Result.failure()

        val locationFormat = config["locationFormat"] as? String ?: "both"
        val geohashLengthDouble = config["geohashLength"] as? Double
        val geohashLength = geohashLengthDouble?.toInt() ?: 12
        
        val bodyMap = mutableMapOf<String, Any>()
        
        if (locationFormat == "latLng" || locationFormat == "both") {
            bodyMap["latitude"] = lat
            bodyMap["longitude"] = lng
        }
        
        if (locationFormat == "geohash" || locationFormat == "both") {
            val geohash = GeohashHelper.geohashFromLatitude(lat, lng, geohashLength)
            bodyMap["geohash"] = geohash
        }

        val params = config["params"] as? Map<*, *>
        if (params != null) {
            bodyMap["params"] = params
        }

        val jsonBody = gson.toJson(bodyMap)
        
        val client = OkHttpClient()
        val mediaType = "application/json; charset=utf-8".toMediaType()
        val requestBody = jsonBody.toRequestBody(mediaType)
        
        val requestBuilder = Request.Builder()
            .url(apiUrl)
            .post(requestBody)

        val headers = config["headers"] as? Map<*, *>
        headers?.forEach { (key, value) ->
            if (key is String && value is String) {
                requestBuilder.addHeader(key, value)
            }
        }

        try {
            val response = client.newCall(requestBuilder.build()).execute()
            if (!response.isSuccessful) {
                return Result.failure()
            }
        } catch (e: IOException) {
            return Result.retry()
        }

        return Result.success()
    }
}
