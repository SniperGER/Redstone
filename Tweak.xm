@interface UIStatusBar
-(void)setForegroundColor:(UIColor *)arg1 ;
@end

@interface SpringBoard {
	UIStatusBar* _statusBar;
}
+(id)sharedApplication;
-(void)loadRedstone;
-(void)cancelMenuButtonRequests;
-(void)clearMenuButtonTimer;
@end

@interface SBUIController
+(id)sharedUserAgent;
-(id)foregroundApplicationDisplayID;
-(BOOL)deviceIsLocked;
-(BOOL)isAppSwitcherShowing;
@end

@interface _UILegibilitySettings
-(void)setStyle:(long long)arg1;
-(void)setContentColor:(UIColor *)arg1 ;
-(void)setPrimaryColor:(UIColor *)arg1 ;
-(void)setSecondaryColor:(UIColor *)arg1 ;
@end

@interface SBWallpaperController
+(id)sharedInstance;
-(void)_updateSeparateWallpaper;
@end

@interface UIKeyboardImpl : UIView
+ (UIKeyboardImpl*)activeInstance;
- (void)dismissKeyboard;
@end

#import "Redstone.h"
#import "RSAppListController.h"
#import "RSStartScreenController.h"
#import "CAKeyframeAnimation+AHEasing.h"

Redstone* redstone;
UIStatusBar *statusBar;
BOOL appSwitcherIsOpen = NO;

extern "C" UIImage * _UICreateScreenUIImage();

%group main;

%hook SpringBoard

-(BOOL)canShowLockScreenHUDControls {
	return %orig;
}

%new
-(void)loadRedstone {
	NSMutableDictionary* settings = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/ml.festival.redstone.plist"];

	if (settings == nil) {
		[settings setValue:[NSNumber numberWithBool:YES] forKey:@"enabled"];
		[settings setValue:[NSNumber numberWithBool:YES] forKey:@"startScreenEnabled"];
	}

	if ([[settings objectForKey:@"enabled"] boolValue]) {
		//[RSAesthetics loadFonts];

		//if ([[settings objectForKey:@"startScreenEnabled"] boolValue]) {
			redstone = [[Redstone alloc] initWithWindow:[[%c(SBUIController) sharedInstance] window]];

			[[redstone window] setUserInteractionEnabled:YES];

			id hiddenView = nil;
			if (![[%c(SBUserAgent) sharedUserAgent] deviceIsLocked]) {
				hiddenView = redstone.rootScrollView;
			}

			[Redstone hideAllExcept:hiddenView];
			[[%c(SBWallpaperController) sharedInstance] _updateSeparateWallpaper];
		//}
	}
}

-(void)applicationDidFinishLaunching:(id)arg1 {
	%orig(arg1);

	statusBar = MSHookIvar<UIStatusBar *>([%c(SpringBoard) sharedApplication], "_statusBar");
	[self loadRedstone];
}

-(void)_handleMenuButtonEvent {
	if (!appSwitcherIsOpen && redstone) {
		if (![redstone hanldeMenuButtonPressed]) {
			%orig;
		} else {
			[self clearMenuButtonTimer];
			[self cancelMenuButtonRequests];
		}
	} else {
		%orig;
	}
}

-(void)frontDisplayDidChange:(id)arg1 {
	%orig(arg1);
	
	if (redstone) {
		[redstone setCurrentApplication:arg1];
	}
}


%end

%hook SBLockScreenViewController

-(void)finishUIUnlockFromSource:(int)arg1 {
	%orig(arg1);

	if (redstone) {
		id hiddenView = nil;

		if ([[%c(SBUserAgent) sharedUserAgent] foregroundApplicationDisplayID]) {
			hiddenView = nil;
		} else {
			hiddenView = redstone.rootScrollView;
			[redstone.startScreenController returnToHomescreen];
			if ([[RSAppListController sharedInstance] pinMenu]) {
				[[RSAppListController sharedInstance] hidePinMenu];
			}
		}

		[Redstone hideAllExcept:hiddenView];
	}
}

-(long long)statusBarStyle {
	return 0;
}

%end

%hook SBHomeScreenViewController

-(unsigned long long)supportedInterfaceOrientations {
	return 1;
}

%end

%hook SBWallpaperController

-(id)legibilitySettingsForVariant:(long long)arg1 {
	_UILegibilitySettings* settings = %orig(arg1);

	if (redstone && arg1 == 1) {
		if ([[%c(SBUIController) sharedInstance] isAppSwitcherShowing]) {
			[settings setStyle:1];
			[settings setContentColor:[UIColor whiteColor]];
			[settings setPrimaryColor:[UIColor whiteColor]];
			[settings setSecondaryColor:[UIColor whiteColor]];
		} else {
			[settings setStyle:1];
			[settings setContentColor:[UIColor whiteColor]];
			[settings setPrimaryColor:[UIColor whiteColor]];
			[settings setSecondaryColor:[UIColor whiteColor]];
		}
	}

	return settings;
}

%end

%hook SBDeckSwitcherViewController

-(void)viewDidAppear:(BOOL)arg1 {
	%orig(arg1);

	appSwitcherIsOpen = YES;

	if (redstone) {
		[redstone.rootScrollView setHidden:NO];
		[[redstone wallpaperView] setHidden:NO];
	}
}
-(void)viewWillDisappear:(BOOL)arg1 {
	%orig(arg1);

	appSwitcherIsOpen = NO;

	if (redstone) {
		[redstone.rootScrollView setHidden:YES];
		[[redstone wallpaperView] setHidden:YES];
	}
}

%end

%hook SBUIAnimationZoomDownApp

-(void)_startAnimation {
	%orig;

	if (redstone) {
		[redstone.rootScrollView setHidden:NO];
		[[redstone wallpaperView] setHidden:NO];
		[redstone.startScreenController setIsEditing:NO];

		for (UIView* subview in [[redstone.startScreenController startScrollView] subviews]) {
			[subview.layer setOpacity:0];
		}

		UIImage *screenImage = _UICreateScreenUIImage();
		UIImageView *screenImageView = [[UIImageView alloc] initWithImage:screenImage];
		[redstone.window addSubview:screenImageView];

		CAAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
																function:CubicEaseInOut
															   fromValue:1.0
																 toValue:0.0];
		opacity.duration = 0.325;
		opacity.removedOnCompletion = NO;
		opacity.fillMode = kCAFillModeForwards;
		
		CAAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"
															  function:CubicEaseInOut
															 fromValue:1.0
															   toValue:1.5];
		scale.duration = 0.35;
		scale.removedOnCompletion = NO;
		scale.fillMode = kCAFillModeForwards;

		[screenImageView.layer addAnimation:opacity forKey:@"opacity"];
		[screenImageView.layer addAnimation:scale forKey:@"scale"];

		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[screenImageView removeFromSuperview];

			[redstone.startScreenController returnToHomescreen];
		});
	}
}

%end

%end // %group main

static void lockedDevice(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	UIKeyboardImpl *impl = [%c(UIKeyboardImpl) activeInstance];
	[impl dismissKeyboard];
}

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	NSUserDefaults* defaults = [[NSUserDefaults alloc] initWithSuiteName:@"ml.festival.redstone"];
	if ([[defaults objectForKey:@"enabled"] boolValue]) {
		if (redstone) {
			[redstone updatePreferences];
		}
	} else {
		[Redstone hideAllExcept:nil];
	}
}

%ctor {
	//if (redstone) {
		// Device has been locked
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, lockedDevice, CFSTR("com.apple.springboard.lockcomplete"), NULL, CFNotificationSuspensionBehaviorCoalesce);

		// Preferences changes
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PreferencesChangedCallback, CFSTR("ml.festival.redstone.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);

		%init(main);
	//}
}