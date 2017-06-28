/**
 @class Redstone2_HomeScreen
 @author Sniper_GER
 @discussion Tweak part of Redstone's Home Screen component
 */

#import "Redstone.h"
#import "substrate.h"

%group homeScreen

%hook SpringBoard

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
			break;
		case 1:
			// App to Home Screen
			break;
		default: break;
	}
	%orig;
}

%end

%end // %group homeScreen

%ctor {
	if ([[[RSPreferences preferences] objectForKey:kRSPHomeScreenEnabledKey] boolValue]) {
		NSLog(@"[Redstone | Home Screen] Initializing Home Screen");
		%init(homeScreen);
	}
}
