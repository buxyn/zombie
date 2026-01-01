package com.zombiegps

object GeohashHelper {
    private const val BASE32_MAP = "0123456789bcdefghjkmnpqrstuvwxyz"

    fun geohashFromLatitude(latitude: Double, longitude: Double, length: Int): String {
        val geohash = StringBuilder()
        var minLat = -90.0
        var maxLat = 90.0
        var minLng = -180.0
        var maxLng = 180.0
        var isEven = true
        var bit = 0
        var ch = 0

        while (geohash.length < length) {
            if (isEven) {
                val mid = (minLng + maxLng) / 2
                if (longitude >= mid) {
                    ch = ch or (1 shl (4 - bit))
                    minLng = mid
                } else {
                    maxLng = mid
                }
            } else {
                val mid = (minLat + maxLat) / 2
                if (latitude >= mid) {
                    ch = ch or (1 shl (4 - bit))
                    minLat = mid
                } else {
                    maxLat = mid
                }
            }
            isEven = !isEven
            if (bit < 4) {
                bit++
            } else {
                geohash.append(BASE32_MAP[ch])
                bit = 0
                ch = 0
            }
        }
        return geohash.toString()
    }
}
