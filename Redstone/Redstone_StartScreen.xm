#import "Redstone.h"
#import "substrate.h"

%group startscreen

extern "C" UIImage * _UICreateScreenUIImage();

BOOL switcherIsOpen;

void playZoomDownAppAnimation(BOOL applicationSnapshot) {
	[[[RSCore sharedInstance] rootScrollView] setHidden:NO];
	for (RSTile* tile in [[[RSCore sharedInstance] startScreenController] pinnedTiles]) {
		[tile.layer setOpacity:0];
	}
	
	if (applicationSnapshot && [[RSCore sharedInstance] currentApplication] != nil && ![[[RSCore sharedInstance] currentApplication] isKindOfClass:%c(SBDashBoardViewController)] && ![[[RSCore sharedInstance] currentApplication] isKindOfClass:%c(SBLockScreenViewController)]) {
		UIImage *screenImage = _UICreateScreenUIImage();
		UIImageView *screenImageView = [[UIImageView alloc] initWithImage:screenImage];
		[[[RSCore sharedInstance] window] addSubview:screenImageView];
		
		CAAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
																function:CubicEaseInOut
															   fromValue:1.0
																 toValue:0.0];
		opacity.duration = 0.225;
		opacity.removedOnCompletion = NO;
		opacity.fillMode = kCAFillModeForwards;
		
		CAAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"
															  function:CubicEaseInOut
															 fromValue:1.0
															   toValue:1.5];
		scale.duration = 0.25;
		scale.removedOnCompletion = NO;
		scale.fillMode = kCAFillModeForwards;
		
		[screenImageView.layer addAnimation:opacity forKey:@"opacity"];
		[screenImageView.layer addAnimation:scale forKey:@"scale"];
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[screenImageView removeFromSuperview];
			
			[[[RSCore sharedInstance] startScreenController] returnToHomescreen];
		});
	} else {
		[[[RSCore sharedInstance] startScreenController] returnToHomescreen];
	}
}

%hook SpringBoard

- (void)frontDisplayDidChange:(id)arg1 {
	%orig(arg1);
	
	[[RSCore sharedInstance] frontDisplayDidChange:arg1];
}

// iOS 9
- (void)_handleMenuButtonEvent {
	if ([RSCore sharedInstance] && !switcherIsOpen) {
		if (![[RSCore sharedInstance] handleMenuButtonEvent]) {
			%orig;
		} else {
			[self clearMenuButtonTimer];
			[self cancelMenuButtonRequests];
		}
	} else {
		%orig;
	}
}

%end // %hook SpringBoard

%hook SBHomeHardwareButton

// iOS 10
- (void)singlePressUp:(id)arg1 {
	if ([RSCore sharedInstance] && !switcherIsOpen) {
		if (![[RSCore sharedInstance] handleMenuButtonEvent]) {
			%orig;
		}
	} else {
		%orig(arg1);
	}
}

%end // %hook SBHomeHardwareButton

%hook SBUIAnimationZoomApp

// iOS 10
- (void)__startAnimation {
	if ([self zoomDirection] == 1) {
		playZoomDownAppAnimation(YES);
	}
	
	%orig;
}

%end // %hook SBUIAnimationZoomApp

%hook SBUIAnimationZoomDownApp

// iOS 9
- (void)_startAnimation {
	playZoomDownAppAnimation(YES);
	
	%orig;
}

%end // %hook SBUIAnimationZoomDownApp

%hook SBHomeScreenViewController

- (NSInteger)supportedInterfaceOrientations {
	return 1;
}

%end // %hook SBHomeScreenViewController

%hook SBDeckSwitcherViewController

- (void)viewDidAppear:(BOOL)arg1 {
	%orig(arg1);
	
	switcherIsOpen = YES;
	
	if ([RSCore sharedInstance]) {
		[[[RSCore sharedInstance] rootScrollView] setHidden:NO];
	}
}

- (void)viewWillDisappear:(BOOL)arg1 {
	%orig(arg1);
	
	switcherIsOpen = NO;
	
	if ([RSCore sharedInstance]) {
		[[[RSCore sharedInstance] rootScrollView] setHidden:YES];
	}
}

%end // %hook SBDeckSwitcherViewController

%hook SBIconModel

- (void)addIcon:(id)arg1 {
	%orig;
	
	[[[RSCore sharedInstance] appListController] addAppsAndSections];
}

%end // %hook SBIconModel

%hook SBApplication

- (void)setBadge:(id)arg1 {
	%orig(arg1);
	
	if ([[[RSCore sharedInstance] startScreenController] tileForLeafIdentifier:[self bundleIdentifier]]) {
		[[[[RSCore sharedInstance] startScreenController] tileForLeafIdentifier:[self bundleIdentifier]] setBadge:[arg1 intValue]];
	}
}

%end // %hook SBApplication

%hook SBWallpaperController

- (void)_handleWallpaperChangedForVariant:(int)arg1 {
	%orig(arg1);
	
	[[RSCore sharedInstance] updateWallpaper];
}

%end // %hook SBWallpaperController

static void lockedDevice(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	[[RSStartScreenController sharedInstance] deviceFinishedLock];
}

%end // %group startscreen

%ctor {
	NSDictionary* settings = [NSDictionary dictionaryWithContentsOfFile:PREFERENCES_PATH];
	
	if ([[settings objectForKey:@"enabled"] boolValue] && [[settings objectForKey:@"startScreenEnabled"] boolValue]) {
		NSLog(@"[Redstone] Initializing Start Screen");
		%init(startscreen);
		
		// Device has been locked
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, lockedDevice, CFSTR("com.apple.springboard.lockcomplete"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	}
}
