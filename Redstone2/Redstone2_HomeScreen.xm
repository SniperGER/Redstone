/**
 @class Redstone2_HomeScreen
 @author Sniper_GER
 @discussion Tweak part of Redstone's Home Screen component
 */

#import "Redstone.h"
#import "substrate.h"

%group homeScreen

%hook SpringBoard

- (void)frontDisplayDidChange:(id)arg1 {
	%orig(arg1);
	%log;
	
	NSLog(@"[Redstone] %@", [RSCore sharedInstance]);
	[[RSCore sharedInstance] frontDisplayDidChange:arg1];
}

- (long long) homeScreenRotationStyle {
	return 0;
}

%end // %hook SpringBoard

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
	switch ([self zoomDirection]) {
		case 0:
			// Home Screen to App
			[[RSStartScreenController sharedInstance] animateOut];
			
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([[RSStartScreenController sharedInstance] getMaxDelayForAnimation]+0.31 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				[[RSLaunchScreenController sharedInstance] animateIn];
				
				%orig;
			});
			break;
		case 1:
			// App to Home Screen
			
			if ([[RSCore sharedInstance] currentApplication]) {
				[[RSLaunchScreenController sharedInstance] animateCurrentApplicationSnapshot];
				[[RSLaunchScreenController sharedInstance] setLaunchIdentifier:nil];
				
				[[RSStartScreenController sharedInstance] setTilesVisible:NO];
				
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
					[[RSStartScreenController sharedInstance] animateIn];
					
					%orig;
				});
			} else {
				[[RSStartScreenController sharedInstance] setTilesVisible:NO];
				[[RSStartScreenController sharedInstance] animateIn];
				
				%orig;
			}
			break;
		default: break;
	}
	//%orig;
}

%end

%end // %group homeScreen

%ctor {
	if ([[[RSPreferences preferences] objectForKey:kRSPHomeScreenEnabledKey] boolValue]) {
		NSLog(@"[Redstone | Home Screen] Initializing Home Screen");
		%init(homeScreen);
	}
}
