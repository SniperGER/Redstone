#pragma mark Definitions
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

#pragma mark Settings Keys
#define kRSPEnabledKey @"enabled"
#define kRSPHomeScreenEnabledKey @"homeScreenEnabled"
#define kRSPLockScreenEnabledKey @"lockScreenEnabled"
#define kRSPNotificationsEnabledKey @"notificationsEnabled"
#define kRSPVolumeControlEnabledKey @"volumeControlEnabled"

#pragma mark Core
#import "Core/RSCore.h"
#import "Core/RSPreferences.h"

#pragma mark Home Screen
#import "HomeScreen/RSHomeScreenController.h"
#import "HomeScreen/RSHomeScreenScrollView.h"

#pragma mark App Switcher
#import "StartScreen/RSStartScreenController.h"

static RSCore* redstone;
static RSPreferences* redstonePreferences;

#import "headers/SpringBoard/SBUIController.h"
#import "headers/SpringBoard/SBUIAnimationZoomApp.h"
