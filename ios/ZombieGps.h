#import <React/RCTEventEmitter.h>
#import <React/RCTBridgeModule.h>
#import <CoreLocation/CoreLocation.h>

@interface ZombieGps : RCTEventEmitter <RCTBridgeModule, CLLocationManagerDelegate>
@end
