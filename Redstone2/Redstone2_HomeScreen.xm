/**
 @class Redstone2_HomeScreen
 @author Sniper_GER
 @discussion Tweak part of Redstone's Home Screen component
 */

#import "Redstone.h"
#import "substrate.h"

%group homeScreen

static BOOL hasBeenUnlockedBefore;

void playApplicationZoomAnimation(int direction, void (^callback)()) {
	SBApplication* frontApp = [(SpringBoard*)[UIApplication sharedApplication] _accessibilityFrontMostApplication];
	
	RSStartScreenController* startScreenController = [[RSHomeScreenController sharedInstance] startScreenController];
	RSAppListController* appListController = [[RSHomeScreenController sharedInstance] appListController];
	RSLaunchScreenController* launchScreenController = [[RSHomeScreenController sharedInstance] launchScreenController];
	
	if (direction == 0) {
		// Home Screen to App
		
		CGFloat delay = [[RSHomeScreenController sharedInstance] launchApplication];
		[launchScreenController setLaunchIdentifier:[frontApp bundleIdentifier]];
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay+0.31 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//#if (!TARGET_OS_SIMULATOR)
			[launchScreenController animateIn];
//#endif
			
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				if ([startScreenController pinnedTiles].count > 0) {
					[[RSHomeScreenController sharedInstance] setContentOffset:CGPointZero];
				} else {
					[[RSHomeScreenController sharedInstance] setContentOffset:CGPointMake(screenWidth, 0)];
				}
				[startScreenController setContentOffset:CGPointMake(0, -24)];
				[appListController setContentOffset:CGPointZero];
			});
			
			callback();
		});
	} else if (direction == 1) {
		// App to Home Screen
		
		if ([launchScreenController launchIdentifier] != nil && ![launchScreenController isUnlocking]) {
			[launchScreenController animateCurrentApplicationSnapshot];
			
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				if ([startScreenController pinnedTiles].count > 0) {
					[startScreenController animateIn];
				}
				
				[appListController animateIn];
				
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
					[launchScreenController setLaunchIdentifier:nil];
				});
				
				callback();
			});
		} else {
			if (hasBeenUnlockedBefore) {
				[[RSHomeScreenController sharedInstance] deviceHasBeenUnlocked];
			} else {
				hasBeenUnlockedBefore = YES;
				
				[startScreenController animateIn];
				[appListController animateIn];
			}
			
			callback();
		}
		
		[launchScreenController setIsUnlocking:NO];
	}
}

%hook SpringBoard

- (long long) homeScreenRotationStyle {
	return 0;
}

- (void)frontDisplayDidChange:(id)arg1 {
	%orig(arg1);
	
	[[RSCore sharedInstance] frontDisplayDidChange:arg1];
}

%end // %hook SpringBoard

%hook SBLockScreenManager

-(BOOL)_finishUIUnlockFromSource:(int)arg1 withOptions:(id)arg2 {
	//[[RSStartScreenController sharedInstance] setTilesVisible:NO];
	
	SBApplication* frontApp = [(SpringBoard*)[UIApplication sharedApplication] _accessibilityFrontMostApplication];
	
	if (frontApp == nil) {
		[[[RSHomeScreenController sharedInstance] launchScreenController] setIsUnlocking:YES];
	}
	
	return %orig;
}

%end // %hook SBLockScreenManager

%hook SBHomeScreenViewController

- (NSInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)arg1 {
	return YES;
}

%end // %hook SBHomeScreenViewController

// iOS 10
%hook SBUIAnimationZoomApp

- (void)__startAnimation {
	playApplicationZoomAnimation([self zoomDirection], ^{
		%orig;
	});
}

%end // %hook SBUIAnimationZoomApp

// iOS 9
%hook SBUIAnimationZoomUpApp

// Home Screen to App
- (void)_startAnimation {
	playApplicationZoomAnimation(0, ^{
		%orig;
	});
}

%end // %hook SBUIAnimationZoomUpApp

// iOS 9
%hook SBUIAnimationZoomDownApp

// App to Home Screen
- (void)_startAnimation {
	playApplicationZoomAnimation(1, ^{
		%orig;
	});
}

%end // %hook SBUIAnimationZoomDownApp

%hook SBUIAnimationLockScreenToAppZoomIn

-(void)__startAnimation {
	SBApplication* frontApp = [(SpringBoard*)[UIApplication sharedApplication] _accessibilityFrontMostApplication];
	
	RSLaunchScreenController* launchScreenController = [[RSHomeScreenController sharedInstance] launchScreenController];
	
	if (frontApp != nil) {
		[launchScreenController setLaunchIdentifier:[frontApp bundleIdentifier]];
		[launchScreenController setIsUnlocking:NO];
	}
	
	%orig;
}

%end // %hook SBUIAnimationLockScreenToAppZoomIn

%hook SBIconModel

-(void)addIcon:(id)arg1 {
	%orig;
	
	RSAppListController* appListController = [[RSHomeScreenController sharedInstance] appListController];
	
	[appListController addAppForIcon:arg1];
}

%end // %hook SBIconModel

%hook SBIconImageView

-(void)setProgressState:(long long)arg1 paused:(BOOL)arg2 percent:(double)arg3 animated:(BOOL)arg4 {
	%orig;
	
	RSAppListController* appListController = [[RSHomeScreenController sharedInstance] appListController];
	
	[appListController setDownloadProgressForIcon:[[self icon] applicationBundleID] progress:arg3 state:arg1];
}

%end // %hook SBIconImageView

%hook SBApplication

- (void)setBadge:(id)arg1 {
	%orig(arg1);
	
	RSStartScreenController* startScreenController = [[RSHomeScreenController sharedInstance] startScreenController];
	
	if ([startScreenController tileForLeafIdentifier:[self bundleIdentifier]]) {
		[[startScreenController tileForLeafIdentifier:[self bundleIdentifier]] setBadge:[arg1 intValue]];
	}
}

%end // %hook SBApplication

%hook SBDeckSwitcherViewController

/*- (void)viewWillAppear:(BOOL)arg1 {
	%orig;
	
	SBApplication* frontApp = [(SpringBoard*)[UIApplication sharedApplication] _accessibilityFrontMostApplication];
	
	[self.view setHidden:([RSAppSwitcherController sharedInstance] != nil)];
	[[[RSLaunchScreenController sharedInstance] window] setHidden:YES];
	[[RSHomeScreenController sharedInstance] showAppSwitcherIncludingHomeScreenCard:YES];
}

- (void)viewWillDisappear:(BOOL)arg1 {
	%orig;
	
	[self.view setHidden:([RSAppSwitcherController sharedInstance] != nil)];
	[[[RSLaunchScreenController sharedInstance] window] setHidden:YES];
}

- (void)animateDismissalToDisplayItem:(id)arg1 forTransitionRequest:(id)arg2 withCompletion:(id)arg3 {
	%orig;
	
	[self.view setHidden:YES];
	[[RSHomeScreenController sharedInstance] hideAppSwitcher];
}*/

- (void)viewWillAppear:(BOOL)arg1 {
	%orig;
	
	RSLaunchScreenController* launchScreenController = [[RSHomeScreenController sharedInstance] launchScreenController];
	RSAppSwitcherController* appSwitcherController = [[RSHomeScreenController sharedInstance] appSwitcherController];
	
	[[launchScreenController window] setHidden:YES];
	
	if (appSwitcherController) {
		[self.view setHidden:YES];
	}
}

- (void)viewDidDisappear:(BOOL)arg1 {
	%orig;
	
	RSLaunchScreenController* launchScreenController = [[RSHomeScreenController sharedInstance] launchScreenController];
	RSAppSwitcherController* appSwitcherController = [[RSHomeScreenController sharedInstance] appSwitcherController];
	
	[[launchScreenController window] setHidden:YES];
	
	if (appSwitcherController) {
		[self.view setHidden:NO];
	}
}

- (void)_animatePresentationWithCompletionBlock:(/*^block*/id)arg1  {
	RSAppSwitcherController* appSwitcherController = [[RSHomeScreenController sharedInstance] appSwitcherController];
	
	if (appSwitcherController) {
		[[RSHomeScreenController sharedInstance] showAppSwitcherIncludingHomeScreenCard:YES];
	}
	
	%log;
	%orig;
}

- (void)_animateDismissalWithCompletionBlock:(/*^block*/id)arg1 {
	RSAppSwitcherController* appSwitcherController = [[RSHomeScreenController sharedInstance] appSwitcherController];
	
	if (appSwitcherController) {
		[[RSHomeScreenController sharedInstance] hideAppSwitcher];
	}
	
	%log;
	%orig;
}

%end // %hook SBDeckSwitcherViewController

%hook BBServer

- (void)_addBulletin:(BBBulletin*)arg1 {
	%orig;
	
	RSStartScreenController* startScreenController = [[RSHomeScreenController sharedInstance] startScreenController];
	
	RSTile* tile = [startScreenController tileForLeafIdentifier:[arg1 section]];
	if (tile) {
		[tile addBulletin:arg1];
	}
}

- (void)_removeBulletin:(BBBulletin*)arg1 rescheduleTimerIfAffected:(BOOL)arg2 shouldSync:(BOOL)arg3 {
	RSStartScreenController* startScreenController = [[RSHomeScreenController sharedInstance] startScreenController];
	
	RSTile* tile = [startScreenController tileForLeafIdentifier:[arg1 section]];
	if (tile) {
		[tile removeBulletin:arg1];
	}
	
	%orig;
}

%end // %hook BBServer

%hook SBWallpaperController

- (void)_handleWallpaperChangedForVariant:(int)arg1 {
	%orig(arg1);
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RedstoneWallpaperChanged" object:nil];
}

%end // %hook SBWallpaperController

static void WallpaperChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	[RSPreferences reloadPreferences];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RedstoneWallpaperChanged" object:nil];
}

static void AccentColorChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	[RSPreferences reloadPreferences];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RedstoneAccentColorChanged" object:nil];
}

%end // %group homeScreen

%ctor {
	if ([[[RSPreferences preferences] objectForKey:kRSPHomeScreenEnabledKey] boolValue]) {
		NSLog(@"[Redstone | Home Screen] Initializing Home Screen");
		%init(homeScreen);
		
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, WallpaperChangedCallback, CFSTR("ml.festival.redstone.WallpaperChanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, AccentColorChangedCallback, CFSTR("ml.festival.redstone.AccentColorChanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	}
}
