#import "Redstone.h"
#import "substrate.h"

%group ios10

SBPagedScrollView* dashboardScrollView;

%hook SBDashBoardScrollGestureController

- (id)initWithDashBoardView:(id)arg1 systemGestureManager:(id)arg2 {
	id r = %orig;
	
	dashboardScrollView = MSHookIvar<SBPagedScrollView*>(r, "_scrollView");
	
	return r;
}

%end // %hook SBDashBoardScrollGestureController

%hook SBPagedScrollView

- (void)layoutSubviews {
	if (self == dashboardScrollView) {
		[self setScrollEnabled:NO];
		[self setUserInteractionEnabled:NO];
		[self setContentOffset:CGPointMake(-screenWidth, 0)];
	} else {
		%orig;
	}
}

%end // %hook SBDashBoardScrollGestureController

%hook SBDashBoardViewController

-(void)startLockScreenFadeInAnimationForSource:(int)arg1 {
	[[RSLockScreenController sharedInstance] resetLockScreen];
	
	%orig(arg1);
}

%end // %hook SBDashBoardViewController

%hook SBDashBoardView

- (void)layoutSubviews {
	[MSHookIvar<UIView *>(self,"_pageControl") removeFromSuperview];
	[self setHidden:YES];
	
	if (![self.superview.subviews containsObject:[[RSLockScreenController sharedInstance] containerView]]) {
		[self.superview addSubview:[[RSLockScreenController sharedInstance] containerView]];
	}
	
	[self.superview bringSubviewToFront:[[RSLockScreenController sharedInstance] containerView]];
}

%end // %hook SBDashBoardView

%hook SBFLockScreenDateView

- (void)layoutSubviews {
	[MSHookIvar<SBUILegibilityLabel *>(self,"_timeLabel") removeFromSuperview];
	[MSHookIvar<SBUILegibilityLabel *>(self,"_dateSubtitleView") removeFromSuperview];
	[MSHookIvar<SBUILegibilityLabel *>(self,"_customSubtitleView") removeFromSuperview];
	
	[[RSLockScreenController sharedInstance] setLockScreenTime:[MSHookIvar<SBUILegibilityLabel *>(self,"_timeLabel") string]];
	[[RSLockScreenController sharedInstance] setLockScreenDate:[MSHookIvar<SBUILegibilityLabel *>(self,"_dateSubtitleView") string]];
	
	%orig;
}

%end // %hook SBFLockScreenDateView

%hook SBLockScreenManager

- (BOOL)_finishUIUnlockFromSource:(int)arg1 withOptions:(id)arg2 {
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[[RSLockScreenController sharedInstance] resetLockScreen];
	});
	
	return %orig;
}

%end // %hook SBLockScreenManager

%hook SBMediaController

-(void)_nowPlayingInfoChanged {
	%orig;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RedstoneNowPlayingUpdate" object:nil];
}

%end // %hook SBMediaController

%hook SBUIPasscodeLockViewWithKeypad

- (void)layoutSubviews {
	[[[RSLockScreenController sharedInstance] passcodeEntryController] setCurrentKeypad:self];
	%orig;
}

- (void)passcodeEntryFieldTextDidChange:(id)arg1 {
	[[[RSLockScreenController sharedInstance] passcodeEntryController] handlePasscodeTextChanged];
	
	%orig;
}

%end // %hook SBUIPasscodeLockViewWithKeypad

%hook SBFUserAuthenticationController

-(void)_handleSuccessfulAuthentication:(id)arg1 responder:(id)arg2 {
	[[[RSLockScreenController sharedInstance] passcodeEntryController] handleSuccessfulAuthentication];
	%orig;
}

- (void)_handleFailedAuthentication:(id)arg1 error:(id)arg2 responder:(id)arg3 {
	[[[RSLockScreenController sharedInstance] passcodeEntryController] handleFailedAuthentication];
	%orig;
}

%end // %hook SBFUserAuthenticationController

%hook SBDashBoardMesaUnlockBehavior

- (void)handleBiometricEvent:(unsigned long long)arg1 {
	%orig;
	
	if(arg1 == 10) {
		[[[RSLockScreenController sharedInstance] passcodeEntryController] handleFailedMesaAuthentication];
	}
}

%end // %hook SBDashBoardMesaUnlockBehavior

%hook SBBacklightController

- (void)_startFadeOutAnimationFromLockSource:(int)arg1 {
	if ([[RSLockScreenController sharedInstance] isScrolling] || [[RSLockScreenController sharedInstance] isShowingPasscodeScreen]) {
		[self resetIdleTimer];
		return;
	}
	
	%orig(arg1);
}

%end // %hook SBBacklightController

%hook BBServer

- (void)_sendAddBulletin:(BBBulletin*)arg1 toFeeds:(unsigned long long)arg2 {
	[[NSOperationQueue mainQueue] addOperationWithBlock:^ {
		if (arg2 != 1 && [[%c(SBUserAgent) sharedUserAgent] deviceIsLocked]) {
			RSNotificationView* notificationView = [[RSNotificationView alloc] initNotificationForBulletin:arg1 isStatic:NO];
			[[RSLockScreenController sharedInstance] displayNotification:notificationView];
		}
	}];
	
	%orig;
}

%end // %hook BBServer

%hook SBWallpaperController

- (void)_handleWallpaperChangedForVariant:(int)arg1 {
	%orig(arg1);
	
	[[RSLockScreenController sharedInstance] updateWallpaper];
}

%end // %hook SBWallpaperController

%end // %group ios10

%group ios9

%hook SBLockScreenView

- (void)layoutSubviews {
	%orig;
	[self setHidden:YES];
	
	if (![self.superview.subviews containsObject:[[RSLockScreenController sharedInstance] containerView]]) {
		[self.superview addSubview:[[RSLockScreenController sharedInstance] containerView]];
	}
	
	[self.superview bringSubviewToFront:[[RSLockScreenController sharedInstance] containerView]];
}

%end // %hook SBLockScreenView

%hook SBFLockScreenDateView

- (void)layoutSubviews {
	[MSHookIvar<SBUILegibilityLabel *>(self,"_legibilityTimeLabel") removeFromSuperview];
	[MSHookIvar<SBUILegibilityLabel *>(self,"_legibilityDateLabel") removeFromSuperview];
	
	[[RSLockScreenController sharedInstance] setLockScreenTime:[MSHookIvar<SBUILegibilityLabel *>(self,"_legibilityTimeLabel") string]];
	[[RSLockScreenController sharedInstance] setLockScreenDate:[MSHookIvar<SBUILegibilityLabel *>(self,"_legibilityDateLabel") string]];
	
	%orig;
}

%end // %hook SBFLockScreenDateView

%hook SBLockScreenManager

- (BOOL)_finishUIUnlockFromSource:(int)arg1 withOptions:(id)arg2 {
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[[RSLockScreenController sharedInstance] resetLockScreen];
	});
	
	return %orig;
}

%end // %hook SBLockScreenManager

%hook SBMediaController

-(void)_nowPlayingInfoChanged {
	%orig;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RedstoneNowPlayingUpdate" object:nil];
}

%end // %hook SBMediaController

%hook SBUIPasscodeLockViewWithKeypad

- (void)layoutSubviews {
	[[[RSLockScreenController sharedInstance] passcodeEntryController] setCurrentKeypad:self];
	%orig;
}

- (void)passcodeEntryFieldTextDidChange:(id)arg1 {
	%orig;
}

%end // %hook SBUIPasscodeLockViewWithKeypad

%hook SBBacklightController

- (void)_startFadeOutAnimationFromLockSource:(int)arg1 {
	if ([[RSLockScreenController sharedInstance] isScrolling] || [[RSLockScreenController sharedInstance] isShowingPasscodeScreen]) {
		[self resetIdleTimer];
		return;
	}
	
	%orig(arg1);
}

%end // %hook SBBacklightController

%hook BBServer

-(void)_sendAddBulletin:(BBBulletin*)arg1 toFeeds:(unsigned long long)arg2 {
	[[NSOperationQueue mainQueue] addOperationWithBlock:^ {
		if (arg2 != 1 && [[%c(SBUserAgent) sharedUserAgent] deviceIsLocked]) {
			RSNotificationView* notificationView = [[RSNotificationView alloc] initNotificationForBulletin:arg1 isStatic:NO];
			[[RSLockScreenController sharedInstance] displayNotification:notificationView];
		}
	}];
	
	%orig;
}

%end // %hook BBServer

%hook SBWallpaperController

- (void)_handleWallpaperChangedForVariant:(int)arg1 {
	%orig(arg1);
	
	[[RSLockScreenController sharedInstance] updateWallpaper];
}

%end // %hook SBWallpaperController

%end // %group ios9

%ctor {
	NSDictionary* settings = [NSDictionary dictionaryWithContentsOfFile:PREFERENCES_PATH];
	
	if ([[settings objectForKey:@"enabled"] boolValue] && [[settings objectForKey:@"lockScreenEnabled"] boolValue]) {
		NSLog(@"[Redstone] Initializing Lock Screen");
		
		if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_9_x_Max) {
			%init(ios10)
		} else if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_8_x_Max) {
			%init(ios9);
		}
	}
}
