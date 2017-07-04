/**
 @class Redstone2_HomeScreen
 @author Sniper_GER
 @discussion Tweak part of Redstone's Home Screen component
 */

#import "Redstone.h"
#import "substrate.h"

%group homeScreen

BOOL isUnlocking;
BOOL hasBeenUnlockedBefore;

%hook SpringBoard

- (long long) homeScreenRotationStyle {
	return 0;
}

- (void)frontDisplayDidChange:(id)arg1 {
	%orig(arg1);
	
	[[RSCore sharedInstance] frontDisplayDidChange];
}

%end // %hook SpringBoard

%hook SBLockScreenManager

-(BOOL)_finishUIUnlockFromSource:(int)arg1 withOptions:(id)arg2 {
	//[[RSStartScreenController sharedInstance] setTilesVisible:NO];
	isUnlocking = YES;
	
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
	
	switch ([self zoomDirection]) {
		case 0: {
			// Home Screen to App
			CGFloat delay = [[RSHomeScreenController sharedInstance] launchApplication];
			[[RSLaunchScreenController sharedInstance] setLaunchIdentifier:[frontApp bundleIdentifier]];
			
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay+0.31 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				[[RSLaunchScreenController sharedInstance] animateIn];
				
				[(UIScrollView*)[[RSStartScreenController sharedInstance] view] setContentOffset:CGPointMake(0, -24)];
				[(UIScrollView*)[[RSAppListController sharedInstance] view] setContentOffset:CGPointZero];
				
				%orig;
				
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
					[[RSHomeScreenController sharedInstance] setContentOffset:CGPointZero];
				});
			});
			break;
		}
		case 1:
			// App to Home Screen
			if (!isUnlocking) {
				[[RSHomeScreenController sharedInstance] setContentOffset:CGPointZero];
				[(UIScrollView*)[[RSStartScreenController sharedInstance] view] setContentOffset:CGPointMake(0, -24)];
				[(UIScrollView*)[[RSAppListController sharedInstance] view] setContentOffset:CGPointZero];
			}
			
			isUnlocking = NO;
			
			if ([[RSLaunchScreenController sharedInstance] launchIdentifier] != nil) {
				[[RSLaunchScreenController sharedInstance] animateCurrentApplicationSnapshot];
				[[RSLaunchScreenController sharedInstance] setLaunchIdentifier:nil];
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
					[[RSStartScreenController sharedInstance] animateIn];
					
					%orig;
				});
			} else {
				if (hasBeenUnlockedBefore) {
					[[RSHomeScreenController sharedInstance] deviceHasBeenUnlocked];
				} else {
					[[RSStartScreenController sharedInstance] animateIn];
					hasBeenUnlockedBefore = YES;
				}
				
				%orig;
			}
			break;
		default: break;
	}
	//%orig;
}

%end

%hook SBIconImageView

-(void)setProgressState:(long long)arg1 paused:(BOOL)arg2 percent:(double)arg3 animated:(BOOL)arg4 {
	%orig;
}

%end // %hook SBIconImageView

%hook SBDeckSwitcherViewController

- (void)viewWillAppear:(BOOL)arg1 {
	%orig;
	
	[[[RSLaunchScreenController sharedInstance] window] setHidden:YES];
}

%end // %hook SBDeckSwitcherViewController

%end // %group homeScreen

%ctor {
	if ([[[RSPreferences preferences] objectForKey:kRSPHomeScreenEnabledKey] boolValue]) {
		NSLog(@"[Redstone | Home Screen] Initializing Home Screen");
		%init(homeScreen);
	}
}
