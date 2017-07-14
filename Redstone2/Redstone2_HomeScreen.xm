/**
 @class Redstone2_HomeScreen
 @author Sniper_GER
 @discussion Tweak part of Redstone's Home Screen component
 */

#import "Redstone.h"
#import "substrate.h"

%group homeScreen

static BOOL isUnlocking;
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
		isUnlocking = YES;
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
				[[RSHomeScreenController sharedInstance] setContentOffset:CGPointZero];
				[(UIScrollView*)[[RSStartScreenController sharedInstance] view] setContentOffset:CGPointMake(0, -24)];
				[(UIScrollView*)[[RSAppListController sharedInstance] view] setContentOffset:CGPointZero];
			});
			
			%orig;
		});
	} else if ([self zoomDirection] == 1) {
		// App to Home Screen
		
		NSLog(@"[Redstone | Animation] App to Home Screen, frontApp: %@, isUnlocking: %i", [[RSLaunchScreenController sharedInstance] launchIdentifier], isUnlocking);
		
		if ([[RSLaunchScreenController sharedInstance] launchIdentifier] != nil && !isUnlocking) {
			[[RSLaunchScreenController sharedInstance] animateCurrentApplicationSnapshot];
			
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				[[RSStartScreenController sharedInstance] animateIn];
				
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
		
		isUnlocking = NO;
	}
}

%end // %hook SBUIAnimationZoomApp

%hook SBUIAnimationLockScreenToAppZoomIn

-(void)__startAnimation {
	SBApplication* frontApp = [(SpringBoard*)[UIApplication sharedApplication] _accessibilityFrontMostApplication];
	
	NSLog(@"[Redstone | Animation] Lock Screen to App: %@", [frontApp bundleIdentifier]);
	
	if (frontApp != nil) {
		[[RSLaunchScreenController sharedInstance] setLaunchIdentifier:[frontApp bundleIdentifier]];
		isUnlocking = NO;
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

%end // %group homeScreen

%ctor {
	if ([[[RSPreferences preferences] objectForKey:kRSPHomeScreenEnabledKey] boolValue]) {
		NSLog(@"[Redstone | Home Screen] Initializing Home Screen");
		%init(homeScreen);
	}
}
