#import "Tweak.h"
#import "RedstoneHeaders.h"

NSMutableDictionary* settings;
Redstone* redstone;

static void loadPrefs() {
	settings = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/ml.festival.redstone.plist"];

	if (!settings) {
		// Set default settings if they're not set
		settings = [[NSMutableDictionary alloc] init];

		[settings setValue:[NSNumber numberWithBool:YES] forKey:@"enabled"];
		[settings setValue:[NSNumber numberWithBool:YES] forKey:@"startScreenEnabled"];
		[settings writeToFile:@"/var/mobile/Library/Preferences/ml.festival.redstone.plist" atomically:YES];
	}
}

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	loadPrefs();

	if (redstone) {
		[redstone updatePreferences];
		
		if ([[settings objectForKey:@"enabled"] boolValue] && [[settings objectForKey:@"startScreenEnabled"] boolValue]) {
			[Redstone hideAllExcept:nil];
		} else {
			[Redstone showAllExcept:nil];
		}
	}
}


%group main

%hook SpringBoard

%new
- (void)loadRedstone {
	// Create Redstone instance
	redstone = [[Redstone alloc] initWithWindow:[[%c(SBUIController) sharedInstance] window]];
}

- (void)applicationDidFinishLaunching:(id)arg1 {
	%orig(arg1);

	[self loadRedstone];
}

- (void)_handleMenuButtonEvent {
	%orig;
}

- (void)frontDisplayDidChange:(id)arg1 {
	%orig(arg1);

	loadPrefs();
	if ([[settings objectForKey:@"enabled"] boolValue] && [[settings objectForKey:@"startScreenEnabled"] boolValue]) {
		[redstone frontDisplayDidChange:arg1];
	}
}

// Disable Home Screen Rotation (montajd)
- (long long)homeScreenRotationStyle {
	loadPrefs();

	if ([[settings objectForKey:@"enabled"] boolValue] && [[settings objectForKey:@"startScreenEnabled"] boolValue]) {
		return 0;
	}
	return %orig;
}
- (bool)homeScreenSupportsRotation {
	loadPrefs();

	if ([[settings objectForKey:@"enabled"] boolValue] && [[settings objectForKey:@"startScreenEnabled"] boolValue]) {
		return NO;
	}
	return %orig;
}

%end // %hook SpringBoard

%hook SBLockScreenViewController

-(void)finishUIUnlockFromSource:(int)arg1 {
	%orig(arg1);
	loadPrefs();

	if ([[settings objectForKey:@"enabled"] boolValue] && [[settings objectForKey:@"startScreenEnabled"] boolValue]) {
		[redstone finishUIUnlockFromSource];
	}
}

%end // %hook SBLockScreenViewController

%hook SBUIAnimationZoomDownApp

-(void)_startAnimation {
	%orig;
	loadPrefs();

	if ([[settings objectForKey:@"enabled"] boolValue] && [[settings objectForKey:@"startScreenEnabled"] boolValue]) {
		[Redstone hideAllExcept:[redstone rootScrollView]];
		[[RSStartScreenController sharedInstance] returnToHomescreen];
	}
}

%end // %hook SBUIAnimationZoomDownApp

%hook SBWallpaperController
- (void)_handleWallpaperChangedForVariant:(int)variant {
    %orig();
    loadPrefs();

    if ([[settings objectForKey:@"enabled"] boolValue] && [[settings objectForKey:@"startScreenEnabled"] boolValue]) {
		[[RSStartScreenController sharedInstance] loadTiles];
	}
}
%end // %hook SBWallpaperController

%hook SBDeckSwitcherViewController

-(void)viewDidAppear:(BOOL)arg1 {
	%orig(arg1);
	loadPrefs();

	if ([[settings objectForKey:@"enabled"] boolValue] && [[settings objectForKey:@"startScreenEnabled"] boolValue]) {
		[Redstone hideAllExcept:[redstone rootScrollView]];
	}
}
-(void)viewWillDisappear:(BOOL)arg1 {
	%orig(arg1);
	loadPrefs();

	if ([[settings objectForKey:@"enabled"] boolValue] && [[settings objectForKey:@"startScreenEnabled"] boolValue]) {
		[Redstone hideAllExcept:nil];
	}
}

%end

%end // %group main

%ctor {
	loadPrefs();

	// Preferences changes
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PreferencesChangedCallback, CFSTR("ml.festival.redstone.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);

	if ([[settings objectForKey:@"enabled"] boolValue]) {
		%init(main);
	}
}