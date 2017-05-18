#import "Redstone.h"
#import "substrate.h"

extern "C" UIImage * _UICreateScreenUIImage();

RSCore* redstone;
BOOL switcherIsOpen;

void playZoomDownAppAnimation() {
	[redstone.rootScrollView setHidden:NO];
	for (RSTile* tile in [redstone.startScreenController pinnedTiles]) {
		[tile.layer setOpacity:0];
	}
	
	if ([redstone currentApplication] != nil && ![[redstone currentApplication] isKindOfClass:%c(SBDashBoardViewController)]) {
		UIImage *screenImage = _UICreateScreenUIImage();
		UIImageView *screenImageView = [[UIImageView alloc] initWithImage:screenImage];
		[redstone.window addSubview:screenImageView];
		
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
			
			[redstone.startScreenController returnToHomescreen];
		});
	} else {
		[redstone.startScreenController returnToHomescreen];
	}
}

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)arg1 {
	%orig(arg1);
	
	redstone = [[RSCore alloc] initWithWindow:[[%c(SBUIController) sharedInstance] window]];
	[RSCore hideAllExcept:nil];
}

- (void)frontDisplayDidChange:(id)arg1 {
	%orig(arg1);
	
	[redstone frontDisplayDidChange:arg1];
}

%end

%hook SBHomeHardwareButton
- (void)singlePressUp:(id)arg1 {
	if (redstone && !switcherIsOpen) {
		if (![redstone handleMenuButtonEvent]) {
			%orig;
		}
	} else {
		%orig(arg1);
	}
}
%end

%hook SBUIAnimationZoomApp

- (void)__startAnimation {
	if ([self zoomDirection] == 1) {
		playZoomDownAppAnimation();
	}
	
	%orig;
}

%end

%hook SBUIAnimationZoomDownApp

- (void)_startAnimation {
	playZoomDownAppAnimation();
	
	%orig;
}

%end

%hook SBHomeScreenViewController

- (NSInteger)supportedInterfaceOrientations {
	return 1;
}

%end

%hook SBDeckSwitcherViewController

- (void)viewDidAppear:(BOOL)arg1 {
	%orig(arg1);
	
	switcherIsOpen = YES;
	
	if (redstone) {
		[redstone.rootScrollView setHidden:NO];
	}
}

- (void)viewWillDisappear:(BOOL)arg1 {
	%orig(arg1);
	
	switcherIsOpen = NO;
	
	if (redstone) {
		[redstone.rootScrollView setHidden:YES];
	}
}

%end

%hook SBIconModel

- (void)addIcon:(id)arg1 {
	%orig;
	
	[redstone.appListController addAppsAndSections];
}

%end

%hook SBApplication

- (void)setBadge:(id)arg1 {
	%orig(arg1);
	
	if ([redstone.startScreenController tileForLeafIdentifier:[self bundleIdentifier]]) {
		[[redstone.startScreenController tileForLeafIdentifier:[self bundleIdentifier]] setBadge:arg1];
	}
}

%end
