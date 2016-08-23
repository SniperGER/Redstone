#include <objc/runtime.h>

@class RSRootScrollView;
@class RSTileScrollView;
@class RSTileView;
@class RSJumpListView;
@class RSTiltButton;

@interface LSApplicationWorkspace
+ (id)defaultWorkspace;
- (id)allInstalledApplications;
@end

@interface LSApplicationProxy

@property (nonatomic,readonly) NSString * localizedName;
@property (nonatomic,readonly) NSString * applicationIdentifier;
@property (nonatomic,readonly) NSString * vendorName;
@property (nonatomic,readonly) NSString * itemName;
@property (nonatomic,readonly) NSString * bundlePath;
@property (nonatomic,readonly) NSURL * bundleURL;
@property (nonatomic,readonly) NSString * bundleIdentifier;

@end

@interface UIApplication (Undocumented)
- (void) launchApplicationWithIdentifier: (NSString*)identifier suspended: (BOOL)suspended;
@end

@interface SBApplicationController

+(id)sharedInstance;
-(id)applicationWithBundleIdentifier:(id)arg1 ;

@end

@interface SBApplication

- (void)setFlag:(int64_t)flag forActivationSetting:(unsigned)setting;

@end

@interface SBUIController

+(id)sharedInstance;
-(void)activateApplication:(id)arg1 ;

@end

#import "RSTileDelegate.h"
#import "RSRootScrollView.h"
#import "RSTileScrollView.h"
#import "RSTiltButton.h"
#import "RSTileView.h"
#import "RSAppList.h"
#import "RSAppListApp.h"
#import "RSAppListSection.h"
#import "RSJumpListView.h"
#import "RSAllAppSButton.h"

#import "CAKeyframeAnimation+AHEasing.h"