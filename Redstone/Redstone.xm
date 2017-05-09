#import "Redstone.h"
#import "substrate.h"

RSCore* redstone;

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)arg1 {
	%orig(arg1);
	
	redstone = [[RSCore alloc] initWithWindow:[[%c(SBUIController) sharedInstance] window]];
	[RSCore hideAllExcept:nil];
}

%end

%hook SBUIAnimationZoomApp

- (void)__startAnimation {
	if ([self zoomDirection] == 1) {
		[redstone.startScreenController returnToHomescreen];
	}
	
	%orig;
}

%end

%hook SBUIAnimationZoomDownApp

- (void)_startAnimation {
	[redstone.startScreenController returnToHomescreen];
	
	%orig;
}

%end

%hook SBHomeScreenViewController

- (NSInteger)supportedInterfaceOrientations {
	return 1;
}

%end
