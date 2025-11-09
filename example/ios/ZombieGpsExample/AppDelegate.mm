#import "AppDelegate.h"

#import <CoreLocation/CoreLocation.h>
#import <React/RCTBundleURLProvider.h>
#import <React-RCTAppDelegate/RCTDefaultReactNativeFactoryDelegate.h>
#import <React-RCTAppDelegate/RCTReactNativeFactory.h>
#import <ReactAppDependencyProvider/RCTAppDependencyProvider.h>
#import <ZombieGps/ZombieGpsBackgroundWorker.h>

@interface ReactNativeDelegate : RCTDefaultReactNativeFactoryDelegate
@end

@implementation ReactNativeDelegate

- (NSURL *)bundleURL
{
#if DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index"];
#else
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

@end

@interface AppDelegate ()
@property (nonatomic, strong) ReactNativeDelegate *reactNativeDelegate;
@property (nonatomic, strong) RCTReactNativeFactory *reactNativeFactory;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.reactNativeDelegate = [ReactNativeDelegate new];
  self.reactNativeDelegate.dependencyProvider = [RCTAppDependencyProvider new];
  self.reactNativeFactory = [[RCTReactNativeFactory alloc] initWithDelegate:self.reactNativeDelegate];

  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  [self.reactNativeFactory startReactNativeWithModuleName:@"ZombieGpsExample"
                                                 inWindow:self.window
                                            launchOptions:launchOptions];

  [self setupZombieGpsBackgroundWithLaunchOptions:launchOptions];

  return YES;
}

- (void)setupZombieGpsBackgroundWithLaunchOptions:(NSDictionary *)launchOptions
{
  ZombieGpsBackgroundWorker *worker = [ZombieGpsBackgroundWorker sharedWorker];
  [worker startMonitoring];

  if (launchOptions[UIApplicationLaunchOptionsLocationKey] != nil) {
    NSLog(@"ZombieGpsExample relaunched due to significant location change");
  }
}

@end
