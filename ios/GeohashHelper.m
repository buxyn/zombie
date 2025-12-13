#import "GeohashHelper.h"

@implementation GeohashHelper
static const char kBase32Map[] = "0123456789bcdefghjkmnpqrstuvwxyz";

+ (NSString *)geohashFromLatitude:(double)latitude longitude:(double)longitude length:(int)length {
    NSMutableString *geohash = [NSMutableString stringWithCapacity:length];
    double minLat = -90.0, maxLat = 90.0;
    double minLng = -180.0, maxLng = 180.0;
    BOOL isEven = YES;
    int bit = 0;
    int ch = 0;
    
    while (geohash.length < length) {
        if (isEven) {
            double mid = (minLng + maxLng) / 2;
            if (longitude >= mid) { ch |= (1 << (4 - bit)); minLng = mid; }
            else { maxLng = mid; }
        } else {
            double mid = (minLat + maxLat) / 2;
            if (latitude >= mid) { ch |= (1 << (4 - bit)); minLat = mid; }
            else { maxLat = mid; }
        }
        isEven = !isEven;
        if (bit < 4) { bit++; }
        else { [geohash appendFormat:@"%c", kBase32Map[ch]]; bit = 0; ch = 0; }
    }
    return geohash;
}
@end
