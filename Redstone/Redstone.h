#import <objc/runtime.h>
#import <AudioToolbox/AudioServices.h>

#import "Lib/UIView+Easing.h"
#import "Lib/CAKeyframeAnimation+AHEasing.h"
#import "Lib/UIFont+WDCustomLoader.h"

#import "Core/RSCore.h"
#import "Core/RSAesthetics.h"
#import "Core/RSMetrics.h"
#import "Core/RSRootScrollView.h"
#import "Core/RSPreferences.h"

#import "Start/RSStartScreenController.h"
#import "Start/RSStartScrollView.h"
#import "Start/RSTile.h"

#import "Launch/RSLaunchScreenController.h"
#import "Launch/RSLaunchScreen.h"

#import "AppList/RSAppListController.h"
#import "AppList/RSAppList.h"
#import "AppList/RSApp.h"
#import "AppList/RSAppListSection.h"
#import "AppList/RSPinMenu.h"
#import "AppList/RSSearchBar.h"
#import "AppList/RSJumpList.h"

#define screenWidth roundf([UIScreen mainScreen].bounds.size.width)
#define screenHeight roundf([UIScreen mainScreen].bounds.size.height)
#define deg2rad(angle) ((angle) / 180.0 * M_PI)

#if TARGET_OS_SIMULATOR

#define RESOURCE_PATH @"/opt/simject/FESTIVAL/Redstone"
#define PREFERENCES_PATH @"/opt/simject/FESTIVAL/ml.festival.redstone.plist"

#else

#define RESOURCE_PATH @"/var/mobile/Library/FESTIVAL/Redstone"
#define PREFERENCES_PATH @"/var/mobile/Library/Preferences/ml.festival.redstone.plist"

#endif

@interface SBUIController : NSObject
+ (id)sharedInstance;
- (id)window;
@end

@interface SBHomeScreenWindow : UIWindow
- (id)subviews;
@end

@interface SBIconController : NSObject
+ (id)sharedInstance;
- (id)model;
- (void)_launchIcon:(id)arg1;
@end

@interface SBLeafIcon : NSObject
- (id)displayName;
- (id)application;
- (BOOL)isUninstallSupported;
@end

@interface SBApplication : NSObject
- (id)bundleIdentifier;
@end

@interface SBIconModel : NSObject
- (SBLeafIcon*)leafIconForIdentifier:(id)arg1;
- (id)visibleIconIdentifiers;
@end

@interface SBUIAnimationZoomApp : NSObject
- (NSInteger)zoomDirection;
@end
