#import <Foundation/Foundation.h>
#import "../GeohashHelper.h"

typedef struct {
    double lat;
    double lng;
    int length;
    NSString * __unsafe_unretained expected;
} TestCase;

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        TestCase tests[] = {
            {35.709026, 139.731992, 6, @"xn775s"},
            {35.681236, 139.767125, 6, @"xn76ur"},
            {35.681236, 139.767125, 1, @"x"},
            {0.0, 0.0, 4, @"s000"},
            {-22.9068, -43.1729, 5, @"75cm9"},
            {37.7749, -122.4194, 6, @"9q8yyk"},
            {35.709026, 139.731992, 12, @"xn775stspkuv"},
            
            // 東京駅
            {35.681236, 139.767125, 12, @"xn76urx6606p"},
            
            // 兵庫県 (明石海峡大橋付近)
            {34.617300, 135.021000, 12, @"xn0hbmzk3k6w"},
            
            // サンフランシスコ (西経・北半球)
            {37.774900, -122.419400, 12, @"9q8yyk8ytpxr"},
            
            // リオデジャネイロ (西経・南半球)
            {-22.906800, -43.172900, 12, @"75cm9tfqnwbx"},
            
            // 境界値 (0,0)
            {0.0, 0.0, 12, @"s00000000000"},
        };
        
        int count = sizeof(tests) / sizeof(TestCase);
        int failedCount = 0;
        
        printf("=== Running %d Tests ===\n", count);

        for (int i = 0; i < count; i++) {
            TestCase t = tests[i];
            
            NSString *result = [GeohashHelper geohashFromLatitude:t.lat
                                                        longitude:t.lng
                                                           length:t.length];
            
            BOOL passed = [result isEqualToString:t.expected];
            
            if (passed) {
                printf("✅ Test %d: PASS (%s)\n", i+1, [result UTF8String]);
            } else {
                failedCount++;
                printf("❌ Test %d: FAIL\n", i+1);
                printf("   Input:    lat: %f, lng: %f, len: %d\n", t.lat, t.lng, t.length);
                printf("   Expected: %s\n", [t.expected UTF8String]);
                printf("   Got:      %s\n", [result UTF8String]);
            }
        }
        
        printf("-----------------------------\n");
        if (failedCount == 0) {
            printf("🎉 All tests passed!\n");
            return 0;
        } else {
            printf("🔥 %d tests failed.\n", failedCount);
            return 1;
        }
    }
}
