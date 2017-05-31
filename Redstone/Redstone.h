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
#import "Core/RSModalAlert.h"
#import "Core/RSTiltView.h"
#import "Core/RSNotificationView.h"

#import "Start/RSStartScreenController.h"
#import "Start/RSStartScrollView.h"
#import "Start/RSTile.h"
#import "Start/RSTileInfo.h"

#import "Launch/RSLaunchScreenController.h"
#import "Launch/RSLaunchScreen.h"

#import "AppList/RSAppListController.h"
#import "AppList/RSAppList.h"
#import "AppList/RSApp.h"
#import "AppList/RSAppListSection.h"
#import "AppList/RSPinMenu.h"
#import "AppList/RSSearchBar.h"
#import "AppList/RSJumpList.h"

#import "LockScreen/RSLockScreenController.h"
#import "LockScreen/RSLockScreenView.h"
#import "LockScreen/RSLockScreenMediaControlsView.h"
#import "LockScreen/RSLockScreenPasscodeEntryController.h"
#import "LockScreen/RSLockScreenPasscodeEntryView.h"
#import "LockScreen/RSLockScreenPasscodeEntryTextField.h"
#import "LockScreen/RSLockScreenPasscodeEntryButton.h"

#define screenWidth roundf([UIScreen mainScreen].bounds.size.width)
#define screenHeight roundf([UIScreen mainScreen].bounds.size.height)
#define deg2rad(angle) ((angle) / 180.0 * M_PI)

#if TARGET_OS_SIMULATOR

#define RESOURCE_PATH @"/opt/simject/FESTIVAL/Redstone"
#define PREFERENCES_PATH @"/opt/simject/FESTIVAL/ml.festival.redstone.plist"
#define LOCK_WALLPAPER_PATH [NSString stringWithFormat:@"%@/Library/SpringBoard/LockBackground.cpbitmap", NSHomeDirectory()]
#define HOME_WALLPAPER_PATH [NSString stringWithFormat:@"%@/Library/SpringBoard/HomeBackground.cpbitmap", NSHomeDirectory()]

#else

#define RESOURCE_PATH @"/var/mobile/Library/FESTIVAL/Redstone"
#define PREFERENCES_PATH @"/var/mobile/Library/Preferences/ml.festival.redstone.plist"
#define LOCK_WALLPAPER_PATH @"/var/mobile/Library/SpringBoard/LockBackground.cpbitmap"
#define HOME_WALLPAPER_PATH @"/var/mobile/Library/SpringBoard/HomeBackground.cpbitmap"

#endif

static RSCore* redstone;

@interface SpringBoard : NSObject
- (void)cancelMenuButtonRequests;
- (void)clearMenuButtonTimer;
@end

@interface SBUIController : NSObject
+ (id)sharedInstance;
- (id)window;
@end

@interface SBIconController : NSObject
+ (id)sharedInstance;
- (id)model;
- (void)_launchIcon:(id)arg1;
@end

@interface SBIcon : NSObject
- (id)applicationBundleID;
@end

@interface SBLeafIcon : NSObject
- (id)displayName;
- (id)application;
- (id)applicationBundleID;
- (BOOL)isUninstallSupported;
- (id)uninstallAlertTitle;
- (id)uninstallAlertBody;
- (id)uninstallAlertConfirmTitle;
- (id)uninstallAlertCancelTitle;
- (void)setUninstalled;
- (void)completeUninstall;
- (id)getUnmaskedIconImage:(int)arg1;
@end

@interface SBApplication : NSObject
- (id)bundleIdentifier;
- (BOOL)isUninstallSupported;
- (id)badgeNumberOrString;
@end

@interface SBApplicationController : NSObject
+ (id)sharedInstance;
- (void)uninstallApplication:(SBApplication*)application;
@end

@interface SBIconModel : NSObject
- (SBLeafIcon*)leafIconForIdentifier:(id)arg1;
- (id)visibleIconIdentifiers;
- (void)removeIconForIdentifier:(id)arg1;
- (id)applicationIconForBundleIdentifier:(id)arg1;
@end

@interface SBUIAnimationZoomApp : NSObject
- (NSInteger)zoomDirection;
@end

@interface SBLockScreenManager : NSObject
+ (id)sharedInstance;
- (id)lockScreenViewController;
- (void)attemptUnlockWithPasscode:(id)arg1;
- (BOOL)_attemptUnlockWithPasscode:(id)arg1 finishUIUnlock:(BOOL)arg2 ;
- (void)_setPasscodeVisible:(BOOL)arg1 animated:(BOOL)arg2;
@end

@interface SBUILegibilityLabel : UIView
- (id)string;
@end

@interface SBWallpaperController : NSObject
@end

@interface SBBacklightController : NSObject
- (void)resetIdleTimer;
@end

@interface SBMediaController : NSObject
+ (id)sharedInstance;
- (id)nowPlayingTitle;
- (id)nowPlayingArtist;
- (BOOL)togglePlayPause;
- (BOOL)changeTrack:(int)arg1;
- (id)nowPlayingApplication;
@end

@interface SBDashBoardView : UIView

@end

@interface SBPagedScrollView : UIScrollView

@end

@interface SBLockScreenView : UIView

@end

@interface SBUserAgent : NSObject
+ (id)sharedUserAgent;
- (BOOL)deviceIsLocked;
- (BOOL)deviceIsPasscodeLocked;
@end

@interface BBBulletin : NSObject
- (id)title;
- (id)subtitle;
- (id)message;
- (id)content;
- (id)section;
@end

@interface NCNotificationShortLookView : UIView
-(NSString *)primaryText;
-(NSString *)primarySubtitleText;
-(NSString *)secondaryText;

- (BOOL)isNCNotification;
@end

@interface NCNotificationShortLookViewController : UIViewController
-(id)notificationRequest;
@end

@interface NCNotificationRequest : NSObject
-(BBBulletin *)bulletin;
@end

@interface SBBannerContextView : UIView
@end

@interface SBUIBannerContext : NSObject
- (id)item;
@end

@interface SBBulletinBannerItem : NSObject
- (id)title;
- (id)seedBulletin;
@end

@interface SBUIPasscodeLockViewWithKeypad : UIView
- (id)initWithLightStyle:(BOOL)arg1;
- (id)passcode;
- (void)passcodeLockNumberPad:(id)arg1 keyDown:(id)arg2;
- (void)passcodeLockNumberPad:(id)arg1 keyUp:(id)arg2;
- (void)passcodeLockNumberPadBackspaceButtonHit:(id)arg1;
@end

@interface SBUIPasscodeLockNumberPad : UIView
+(id)_buttonForCharacter:(unsigned int)arg1 withLightStyle:(BOOL)arg2;
@end

@interface SBPasscodeNumberPadButton : UIView
@end
