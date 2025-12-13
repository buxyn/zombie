// ZombieGpsBackgroundWorker.m
#import "ZombieGpsBackgroundWorker.h"
#import <React/RCTLog.h>
#import "GeohashHelper.h"

static NSString *const kZombieGpsUploadConfigDefaultsKey = @"ZombieGpsUploadConfig";

@interface ZombieGpsBackgroundWorker () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong, nullable) NSDictionary *uploadConfig;
@property (nonatomic, assign) BOOL didInitializeLocationManager;
@end

@implementation ZombieGpsBackgroundWorker

+ (instancetype)sharedWorker {
  static ZombieGpsBackgroundWorker *worker = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    worker = [[self alloc] initPrivate];
  });
  return worker;
}

- (instancetype)initPrivate {
  if (self = [super init]) {
    [self setupLocationManager];
    [self loadPersistedUploadConfig];
  }
  return self;
}

- (instancetype)init {
  @throw [NSException exceptionWithName:@"ZombieGpsBackgroundWorkerInit"
                                 reason:@"Use +[ZombieGpsBackgroundWorker sharedWorker]"
                               userInfo:nil];
}

- (void)setupLocationManager {
  if (self.didInitializeLocationManager) {
    return;
  }
  self.locationManager = [[CLLocationManager alloc] init];
  self.locationManager.delegate = self;
  self.locationManager.pausesLocationUpdatesAutomatically = NO;
  self.locationManager.allowsBackgroundLocationUpdates = YES;
  self.didInitializeLocationManager = YES;
}

- (void)startMonitoring {
  [self.locationManager startMonitoringSignificantLocationChanges];
}

- (void)stopMonitoring {
  [self.locationManager stopMonitoringSignificantLocationChanges];
}

- (void)configureWithDictionary:(NSDictionary *)config
                        resolve:(void (^)(void))resolve
                         reject:(void (^)(NSString *, NSString *, NSError *_Nullable))reject {
  NSString *urlString = config[@"apiURL"];
  if (![urlString isKindOfClass:[NSString class]] || urlString.length == 0) {
    reject(@"zombie_gps_invalid_config", @"apiURL is required for ZombieGps.ready", nil);
    return;
  }

  NSURL *url = [NSURL URLWithString:urlString];
  if (url == nil) {
    reject(@"zombie_gps_invalid_config", @"apiURL must be a valid URL", nil);
    return;
  }

  NSMutableDictionary *normalized = [NSMutableDictionary dictionary];
  normalized[@"apiURL"] = urlString;

  NSDictionary *headers = config[@"headers"];
  if ([headers isKindOfClass:[NSDictionary class]]) {
    normalized[@"headers"] = headers;
  }

  NSDictionary *params = config[@"params"];
  if ([params isKindOfClass:[NSDictionary class]]) {
    normalized[@"params"] = params;
  }

  NSString *locationFormat = config[@"locationFormat"];
  if ([locationFormat isKindOfClass:[NSString class]] && locationFormat.length > 0) {
    normalized[@"locationFormat"] = locationFormat;
  } else {
    normalized[@"locationFormat"] = @"both";
  }

  NSNumber *geohashLength = config[@"geohashLength"];
  if ([geohashLength isKindOfClass:[NSNumber class]]) {
    normalized[@"geohashLength"] = geohashLength;
  } else {
    normalized[@"geohashLength"] = @(12);
  }

  self.uploadConfig = [normalized copy];

  [[NSUserDefaults standardUserDefaults] setObject:self.uploadConfig
                                            forKey:kZombieGpsUploadConfigDefaultsKey];
  [[NSUserDefaults standardUserDefaults] synchronize];

  if (resolve) {
    resolve();
  }
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
  CLLocation *loc = [locations lastObject];
  if (!loc) {
    return;
  }

  if ([self.delegate respondsToSelector:@selector(zombieGpsWorkerDidUpdateLocation:)]) {
    [self.delegate zombieGpsWorkerDidUpdateLocation:loc];
  }

  [self uploadLocationIfPossible:loc];
}

- (void)uploadLocationIfPossible:(CLLocation *)location {
  NSDictionary *config = self.uploadConfig;
  if (config == nil) {
    return;
  }

  NSString *urlString = config[@"apiURL"];
  if (![urlString isKindOfClass:[NSString class]] || urlString.length == 0) {
    return;
  }

  NSURL *url = [NSURL URLWithString:urlString];
  if (url == nil) {
    RCTLogWarn(@"ZombieGps: invalid apiURL stored, skipping upload");
    return;
  }

  NSString *format = config[@"locationFormat"]; // "latLng", "geohash", "both"
  if (!format) format = @"both";

  NSNumber *lengthNum = config[@"geohashLength"];
  int length = (lengthNum != nil) ? [lengthNum intValue] : 12;
  if (length < 1) length = 1;
  if (length > 12) length = 12;

  NSMutableDictionary *body = [NSMutableDictionary dictionary];

  BOOL includeLatLng = [format isEqualToString:@"latLng"] || [format isEqualToString:@"both"];
  if (includeLatLng) {
    body[@"latitude"] = @(location.coordinate.latitude);
    body[@"longitude"] = @(location.coordinate.longitude);
  }

  BOOL includeGeohash = [format isEqualToString:@"geohash"] || [format isEqualToString:@"both"];
  if (includeGeohash) {
    NSString *geohash = [GeohashHelper geohashFromLatitude:location.coordinate.latitude
                                                 longitude:location.coordinate.longitude
                                                    length:length];
    body[@"geohash"] = geohash;
  }

  NSDictionary *params = config[@"params"];
  if ([params isKindOfClass:[NSDictionary class]]) {
    body[@"params"] = params;
  }

  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  request.HTTPMethod = @"POST";

  NSDictionary *headers = config[@"headers"];
  if ([headers isKindOfClass:[NSDictionary class]]) {
    [headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
      if ([key isKindOfClass:[NSString class]] && [obj isKindOfClass:[NSString class]]) {
        [request setValue:(NSString *)obj forHTTPHeaderField:(NSString *)key];
      }
    }];
  }

  NSError *jsonError = nil;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body options:0 error:&jsonError];
  if (jsonError) {
    RCTLogError(@"ZombieGps: failed to serialize upload payload: %@", jsonError);
    return;
  }

  if ([request valueForHTTPHeaderField:@"Content-Type"] == nil) {
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  }

  request.HTTPBody = jsonData;

  NSURLSession *session = [NSURLSession sharedSession];
  NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
  [task resume];
}

- (void)loadPersistedUploadConfig {
  NSDictionary *saved = [[NSUserDefaults standardUserDefaults] objectForKey:kZombieGpsUploadConfigDefaultsKey];
  if ([saved isKindOfClass:[NSDictionary class]]) {
    self.uploadConfig = saved;
  }
}

@end
