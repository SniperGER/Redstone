/**
 @class Redstone2_HomeScreen
 @author Sniper_GER
 @discussion Tweak part of Redstone's Home Screen component
 */

#import "Redstone.h"
#import "substrate.h"

%group homeScreen

static BOOL hasBeenUnlockedBefore;

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
		[[RSLaunchScreenController sharedInstance] setIsUnlocking:YES];
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
	SBApplication* frontApp = [(SpringBoard*)[UIApplication sharedApplication] _accessibilityFrontMostApplication];
	
	if ([self zoomDirection] == 0) {
		// Home Screen to App
		
		CGFloat delay = [[RSHomeScreenController sharedInstance] launchApplication];
		[[RSLaunchScreenController sharedInstance] setLaunchIdentifier:[frontApp bundleIdentifier]];
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay+0.31 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
#if (!TARGET_OS_SIMULATOR)
			[[RSLaunchScreenController sharedInstance] animateIn];
#endif
			
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				if ([[RSStartScreenController sharedInstance] pinnedTiles].count > 0) {
					[[RSHomeScreenController sharedInstance] setContentOffset:CGPointZero];
				} else {
					[[RSHomeScreenController sharedInstance] setContentOffset:CGPointMake(screenWidth, 0)];
				}
				[(UIScrollView*)[[RSStartScreenController sharedInstance] view] setContentOffset:CGPointMake(0, -24)];
				[(UIScrollView*)[[RSAppListController sharedInstance] view] setContentOffset:CGPointZero];
			});
			
			%orig;
		});
	} else if ([self zoomDirection] == 1) {
		// App to Home Screen
		
		if ([[RSLaunchScreenController sharedInstance] launchIdentifier] != nil && ![[RSLaunchScreenController sharedInstance] isUnlocking]) {
			[[RSLaunchScreenController sharedInstance] animateCurrentApplicationSnapshot];
			
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				if ([[RSStartScreenController sharedInstance] pinnedTiles].count > 0) {
					[[RSStartScreenController sharedInstance] animateIn];
				}
				
				[[RSAppListController sharedInstance] animateIn];
				
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
					[[RSLaunchScreenController sharedInstance] setLaunchIdentifier:nil];
				});
				
				%orig;
			});
		} else {
			if (hasBeenUnlockedBefore) {
				[[RSHomeScreenController sharedInstance] deviceHasBeenUnlocked];
			} else {
				hasBeenUnlockedBefore = YES;
				
				[[RSStartScreenController sharedInstance] animateIn];
				[[RSAppListController sharedInstance] animateIn];
			}
			
			%orig;
		}
		
		[[RSLaunchScreenController sharedInstance] setIsUnlocking:NO];
	}
}

%end // %hook SBUIAnimationZoomApp

%hook SBUIAnimationLockScreenToAppZoomIn

-(void)__startAnimation {
	SBApplication* frontApp = [(SpringBoard*)[UIApplication sharedApplication] _accessibilityFrontMostApplication];
	
	if (frontApp != nil) {
		[[RSLaunchScreenController sharedInstance] setLaunchIdentifier:[frontApp bundleIdentifier]];
		[[RSLaunchScreenController sharedInstance] setIsUnlocking:NO];
	}
	
	%orig;
}

%end // %hook SBUIAnimationLockScreenToAppZoomIn

%hook SBIconModel

-(void)addIcon:(id)arg1 {
	%orig;
	
	[[RSAppListController sharedInstance] addAppForIcon:arg1];
}

%end // %hook SBIconModel

%hook SBIconImageView

-(void)setProgressState:(long long)arg1 paused:(BOOL)arg2 percent:(double)arg3 animated:(BOOL)arg4 {
	%orig;
	
	[[RSAppListController sharedInstance] setDownloadProgressForIcon:[[self icon] applicationBundleID] progress:arg3 state:arg1];
}

%end // %hook SBIconImageView

%hook SBApplication

- (void)setBadge:(id)arg1 {
	%orig(arg1);
	
	if ([[RSStartScreenController sharedInstance] tileForLeafIdentifier:[self bundleIdentifier]]) {
		[[[RSStartScreenController sharedInstance] tileForLeafIdentifier:[self bundleIdentifier]] setBadge:[arg1 intValue]];
	}
}

%end // %hook SBApplication

%hook SBDeckSwitcherViewController

- (void)viewWillAppear:(BOOL)arg1 {
	%orig;
	
	[[[RSLaunchScreenController sharedInstance] window] setHidden:YES];
	//[self.view setHidden:YES];
}

%end // %hook SBDeckSwitcherViewController

%hook BBServer

- (void)_addBulletin:(BBBulletin*)arg1 {
	%orig;
	
	RSTile* tile = [[RSStartScreenController sharedInstance] tileForLeafIdentifier:[arg1 section]];
	if (tile) {
		[tile addBulletin:arg1];
	}
}

- (void)_removeBulletin:(BBBulletin*)arg1 rescheduleTimerIfAffected:(BOOL)arg2 shouldSync:(BOOL)arg3 {
	RSTile* tile = [[RSStartScreenController sharedInstance] tileForLeafIdentifier:[arg1 section]];
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
