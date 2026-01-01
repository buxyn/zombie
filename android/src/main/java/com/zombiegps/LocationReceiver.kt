package com.zombiegps

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.work.Data
import androidx.work.OneTimeWorkRequest
import androidx.work.WorkManager
import com.google.android.gms.location.LocationResult

class LocationReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (LocationResult.hasResult(intent)) {
            val locationResult = LocationResult.extractResult(intent)
            locationResult?.lastLocation?.let { location ->
                // Send to JS if app is running
                ZombieGpsModule.sendLocationEvent(location)

                // Enqueue upload work
                val data = Data.Builder()
                    .putDouble("latitude", location.latitude)
                    .putDouble("longitude", location.longitude)
                    .build()

                val uploadWork = OneTimeWorkRequest.Builder(UploadWorker::class.java)
                    .setInputData(data)
                    .build()

                WorkManager.getInstance(context).enqueue(uploadWork)
            }
        }
    }
}
