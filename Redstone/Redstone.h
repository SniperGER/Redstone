#import <objc/runtime.h>
#import <AudioToolbox/AudioServices.h>

#import "Lib/UIView+Easing.h"
#import "Lib/CAKeyframeAnimation+AHEasing.h"

#import "Core/RSCore.h"
#import "Core/RSAesthetics.h"
#import "Core/RSMetrics.h"
#import "Core/RSRootScrollView.h"

#import "Start/RSStartScreenController.h"
#import "Start/RSStartScrollView.h"
#import "Start/RSTile.h"

#define screenWidth roundf([UIScreen mainScreen].bounds.size.width)
#define screenHeight roundf([UIScreen mainScreen].bounds.size.height)

#if TARGET_OS_SIMULATOR
#define RESOURCE_PATH @"/opt/simject/FESTIVAL/Redstone"
#else
#define RESOURCE_PATH @"/var/mobile/Library/FESTIVAL/Redstone"
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

@interface SBIconModel : NSObject
- (id)leafIconForIdentifier:(id)arg1;
@end

@interface SBIcon : NSObject
- (id)displayName;
@end

@interface SBUIAnimationZoomApp : NSObject
- (NSInteger)zoomDirection;
@end
