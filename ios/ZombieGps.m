#import "ZombieGps.h"

@interface ZombieGps ()
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation ZombieGps

RCT_EXPORT_MODULE();

- (instancetype)init {
  if (self = [super init]) {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    self.locationManager.allowsBackgroundLocationUpdates = YES;
  }
  return self;
}

RCT_EXPORT_METHOD(startMonitoring) {
  [self.locationManager startMonitoringSignificantLocationChanges];
}

RCT_EXPORT_METHOD(stopMonitoring) {
  [self.locationManager stopMonitoringSignificantLocationChanges];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations
{
  CLLocation *loc = [locations lastObject];
  if (!loc) return;

  [self sendEventWithName:@"ZombieGPSLocation"
    body:@{
      @"latitude": @(loc.coordinate.latitude),
      @"longitude": @(loc.coordinate.longitude),
      @"timestamp": @(loc.timestamp.timeIntervalSince1970)
    }];
}

- (NSArray<NSString *> *)supportedEvents {
  return @[@"ZombieGPSLocation"];
}

@end
