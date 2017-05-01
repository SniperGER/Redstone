#import <objc/runtime.h>
#import <AudioToolbox/AudioServices.h>

#define screenW [[UIScreen mainScreen] bounds].size.width
#define screenH [[UIScreen mainScreen] bounds].size.height

extern void AudioServicesPlaySystemSoundWithVibration(int, id, NSDictionary *);

// Redstone Core
#import "core/Redstone.h"
#import "core/RSAesthetics.h"
#import "core/RSAnimation.h"
#import "core/RSMetrics.h"
#import "core/RSPreferences.h"
#import "core/RSRootScrollView.h"
#import "core/RSTiltView.h"

#import "lib/CAKeyframeAnimation+AHEasing.h"
#import "lib/UIFont+WDCustomLoader.h"
#import "lib/UIImageAverageColorAddition.h"

#define ANIM_SCALE_DURATION 0.225
#define ANIM_ALPHA_DURATION 0.2
#define ANIM_DELAY 0.01

// Redstone Start Screen
#import "start/RSStartScreenController.h"
#import "start/RSStartScrollView.h"
#import "start/RSTile.h"

// Redstone App List

// Redstone Jump List

// Redstone Launch Screen
#import "launch/RSLaunchScreen.h"
#import "launch/RSLaunchScreenController.h"

// Common Headers

@interface SBUIController
+ (id)sharedInstance;
+ (id)sharedUserAgent;
- (id)foregroundApplicationDisplayID;
- (BOOL)deviceIsLocked;
- (BOOL)isAppSwitcherShowing;
@end

@interface SBIcon
- (NSString *)displayName;
- (id)leafIdentifier;
- (BOOL)isUninstallSupported;
@end

@interface SBIconModel : NSObject
- (id)leafIconForIdentifier:(id)arg1;
- (id)visibleIconIdentifiers;
@end

@interface SBIconController : NSObject
+ (id)sharedInstance;
- (id)model;
- (void)_launchIcon:(id)arg1;
@end

@interface SBApplication : NSObject
@end

@interface SBApplicationInfo : NSObject
@property (nonatomic,copy,readonly) NSString * displayName;
@end
