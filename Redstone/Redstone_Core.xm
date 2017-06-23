#import "Redstone.h"
#import "substrate.h"

%group core

static BOOL switcherIsOpen;

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)arg1 {
	%orig(arg1);
	
	redstone = [[RSCore alloc] initWithWindow:[[%c(SBUIController) sharedInstance] window]];
	[redstone setSharedSpringBoard:self];
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

%hook SBDeckSwitcherViewController

- (void)viewDidAppear:(BOOL)arg1 {
	%orig(arg1);
	
	switcherIsOpen = YES;
}

- (void)viewWillDisappear:(BOOL)arg1 {
	%orig(arg1);
	
	switcherIsOpen = NO;
}

%end // %hook SBDeckSwitcherViewController

%end // %group core

%ctor {
	[[RSPreferences alloc] init];
	
	if ([[[RSPreferences preferences] objectForKey:@"enabled"] boolValue]) {
		NSLog(@"[Redstone] Initializing");
		%init(core);
	}
}
