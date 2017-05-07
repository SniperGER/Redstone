#import <objc/runtime.h>

#import "UIView+Easing.h"

#import "RSCore.h"
#import "RSMetrics.h"
#import "RSRootScrollView.h"

#import "RSStartScreenController.h"
#import "RSStartScrollView.h"
#import "RSTile.h"

#define screenWidth roundf([UIScreen mainScreen].bounds.size.width)
#define screenHeight roundf([UIScreen mainScreen].bounds.size.height)

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
