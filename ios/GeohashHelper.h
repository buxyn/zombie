#import <Foundation/Foundation.h>

@interface GeohashHelper : NSObject
+ (NSString *)geohashFromLatitude:(double)latitude longitude:(double)longitude length:(int)length;
@end
