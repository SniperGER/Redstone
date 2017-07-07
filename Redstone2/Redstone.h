#import <objc/runtime.h>

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
#define kRSP2ColumnLayoutKey @"2ColumnLayout"
#define kRSP3ColumnLayoutKey @"3ColumnLayout"

#pragma mark Libraries
#import "Libraries/UIView+Easing.h"
#import "Libraries/UIFont+WDCustomLoader.h"
#import "Libraries/CAKeyframeAnimation+AHEasing.h"
#import "Libraries/easing.h"

#pragma mark Core
#import "Core/RSCore.h"
#import "Core/RSPreferences.h"
#import "Core/RSMetrics.h"
#import "Core/RSAesthetics.h"

#pragma mark UI
#import "UI/RSTiltView.h"
#import "UI/RSFlyoutMenu.h"
#import "UI/RSProgressBar.h"

#pragma mark Home Screen
#import "HomeScreen/RSHomeScreenController.h"
#import "HomeScreen/RSHomeScreenScrollView.h"

#pragma mark App Switcher

#pragma mark Start Screen
#import "StartScreen/RSStartScreenController.h"
#import "StartScreen/RSStartScreenScrollView.h"
#import "StartScreen/RSTile.h"
#import "StartScreen/RSTileInfo.h"

#pragma mark App List
#import "AppList/RSAppListController.h"
#import "AppList/RSAppListScrollView.h"
#import "AppList/RSAppListSection.h"
#import "AppList/RSApp.h"
#import "AppList/RSDownloadingApp.h"

#pragma mark Launch Screen
#import "LaunchScreen/RSLaunchScreenController.h"

static RSCore* redstone;
static RSPreferences* redstonePreferences;

#import "headers/SpringBoard/SpringBoard.h"
