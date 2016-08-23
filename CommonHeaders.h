#import <UIKit/UIKit.h>
#include <objc/runtime.h>

#import "CAKeyframeAnimation+AHEasing.h"
#import "UIFont+WDCustomLoader.h"
#import "UIImageAverageColorAddition.h"
#import "RSApplicationDelegate.h"
#import "RSAesthetics.h"
#import "RSTileDelegate.h"

//#import "RSRootView.h"
//#import "RSRootScrollView.h"
//#import "RSTiltView.h"
//#import "RSTileScrollView.h"
//#import "RSAppListScrollView.h"
//#import "RSAppListSection.h"

#define RSLog(string) NSLog(@"[RedstoneLog] %@", string);
#define REDSTONE_LIBRARY_PATH @"/private/var/mobile/Library/Redstone"

@class RSRootView, /* RSTileScrollView, */ RSTiltView;

@interface SBIconController : UIViewController

-(id)model;
+(id)sharedInstance;
-(void)_launchIcon:(id)tapped;

@end

@interface SBIconModel : NSObject

-(id)visibleIconIdentifiers;
-(id)leafIconForIdentifier:(id)arg1 ;

@end

@interface SBIcon : NSObject
-(id)application;
@end

@interface SBApplicationInfo : NSObject
@property (nonatomic,copy,readonly) NSString * displayName;
@end

@interface SBApplication : NSObject
@property(readonly, nonatomic) int pid;
-(SBApplicationInfo*)_appInfo;
-(id)displayName;
-(void)setFlag:(int64_t)flag forActivationSetting:(unsigned)setting;
@end

@interface SBApplicationController : NSObject
+(id) sharedInstance;
-(SBApplication*) applicationWithBundleIdentifier:(NSString*)identifier;
-(SBApplication*) applicationWithDisplayIdentifier:(NSString*)identifier;
-(SBApplication*)applicationWithPid:(int)arg1;
-(SBApplication*) RA_applicationWithBundleIdentifier:(NSString*)bundleIdentifier;
@end

@interface SBUIController
+(id)sharedInstance;
-(void)activateApplication:(id)arg1 ;
@end

@interface SpringBoard
-(void)cancelMenuButtonRequests;
-(void)clearMenuButtonTimer;
@end

@interface UIKeyboardImpl : UIView
+ (UIKeyboardImpl*)activeInstance;
- (void)dismissKeyboard;
@end