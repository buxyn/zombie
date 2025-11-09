#import "ZombieGps.h"
#import "ZombieGpsBackgroundWorker.h"

@interface ZombieGps () <ZombieGpsBackgroundWorkerDelegate>
@property (nonatomic, strong) ZombieGpsBackgroundWorker *worker;
@end

@implementation ZombieGps

RCT_EXPORT_MODULE();

- (instancetype)init {
  if (self = [super init]) {
    _worker = [ZombieGpsBackgroundWorker sharedWorker];
    _worker.delegate = self;
  }
  return self;
}

RCT_EXPORT_METHOD(ready:(NSDictionary *)config
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  __weak typeof(self) weakSelf = self;
  [self.worker configureWithDictionary:config
  resolve:^{
    if (resolve) {
      resolve(@(YES));
    }
    weakSelf.worker.delegate = weakSelf;
  }
  reject:^(NSString *code, NSString *message, NSError *error) {
    if (reject) {
      reject(code, message, error);
    }
  }];
}

RCT_EXPORT_METHOD(startMonitoring) {
  [self.worker startMonitoring];
}

RCT_EXPORT_METHOD(stopMonitoring) {
  [self.worker stopMonitoring];
}

- (void)zombieGpsWorkerDidUpdateLocation:(CLLocation *)location {
  if (!self.bridge) {
    return;
  }

  [self sendEventWithName:@"ZombieGPSLocation"
    body:@{
      @"latitude": @(location.coordinate.latitude),
      @"longitude": @(location.coordinate.longitude),
      @"timestamp": @(location.timestamp.timeIntervalSince1970)
    }];
}

- (NSArray<NSString *> *)supportedEvents {
  return @[@"ZombieGPSLocation"];
}

@end
