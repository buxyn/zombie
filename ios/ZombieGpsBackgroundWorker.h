#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZombieGpsBackgroundWorkerDelegate <NSObject>
- (void)zombieGpsWorkerDidUpdateLocation:(CLLocation *)location;
@end

@interface ZombieGpsBackgroundWorker : NSObject

@property (nonatomic, weak, nullable) id<ZombieGpsBackgroundWorkerDelegate> delegate;

+ (instancetype)sharedWorker;

- (void)startMonitoring;
- (void)stopMonitoring;
- (void)configureWithDictionary:(NSDictionary *)config
                        resolve:(void (^)(void))resolve
                         reject:(void (^)(NSString *code, NSString *message, NSError *_Nullable error))reject;

@end

NS_ASSUME_NONNULL_END
