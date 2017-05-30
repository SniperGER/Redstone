/*#import "Redstone.h"
#import "substrate.h"

%group ios10

SBPagedScrollView* dashboardScrollView;

%hook SBDashBoardView

- (void)layoutSubviews {
	[MSHookIvar<UIView *>(self,"_pageControl") removeFromSuperview];
	
	if ([RSCore sharedInstance]) {
		if (![self.superview.subviews containsObject:[[RSLockScreenController sharedInstance] containerView]]) {
			[self.superview addSubview:[[RSLockScreenController sharedInstance] containerView]];
		}
	
		[[[RSLockScreenController sharedInstance] lockScreen] setHidden:NO];
		[[[RSLockScreenController sharedInstance] lockScreen] setAlpha:1];
		[self.superview bringSubviewToFront:[[RSLockScreenController sharedInstance] containerView]];
	}
	
	%orig;
	[self setHidden:YES];
}

%end

%hook SBFLockScreenDateView

- (void)layoutSubviews {
	[MSHookIvar<UILabel *>(self,"_timeLabel") removeFromSuperview];
	[MSHookIvar<UILabel *>(self,"_dateSubtitleView") removeFromSuperview];
	[MSHookIvar<UILabel *>(self,"_customSubtitleView") removeFromSuperview];
	
	if ([RSCore sharedInstance]) {
		[[RSLockScreenController sharedInstance] setTime:[MSHookIvar<SBUILegibilityLabel *>(self,"_timeLabel") string]];
		[[RSLockScreenController sharedInstance] setDate:[MSHookIvar<SBUILegibilityLabel *>(self,"_dateSubtitleView") string]];
		[self bringSubviewToFront:[[RSLockScreenController sharedInstance] containerView]];
		
		[[[RSLockScreenController sharedInstance] mediaControls] setHidden:([[%c(SBMediaController) sharedInstance] nowPlayingApplication] == nil)];
		[[[RSLockScreenController sharedInstance] passcodeView] setHidden:(![[%c(SBUserAgent) sharedUserAgent] deviceIsPasscodeLocked])];
	}
	
	%orig;
}

%end

%hook SBDashBoardMainPageView

- (void)layoutSubviews {
	[MSHookIvar<UILabel *>(self,"_callToActionLabel") removeFromSuperview];
	%orig;
}

%end


%hook MPUMediaControlsTitlesView

- (void)updateTrackInformationWithNowPlayingInfo:(id)arg1 {
	%orig(arg1);
	
	[[[RSLockScreenController sharedInstance] mediaControls] updateNowPlayingInfo:arg1];
}

%end

%hook SBMediaController

-(void)_nowPlayingAppIsPlayingDidChange {
	%orig;
	
	[[[[RSLockScreenController sharedInstance] containerView] superview] layoutSubviews];
}

%end

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

%end

%hook SBDashBoardScrollGestureController

- (id)initWithDashBoardView:(id)arg1 systemGestureManager:(id)arg2 {
	self = %orig;
	
	dashboardScrollView = MSHookIvar<SBPagedScrollView*>(self,"_scrollView");
	
	return self;
}

%end

%end // %group ios 10

%group ios9

BOOL isUnlocking;

%hook SBLockScreenViewController

- (void)prepareForUIUnlock {
	isUnlocking = YES;
	%orig;
}

-(void)finishUIUnlockFromSource:(int)arg1 {
	%orig;
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		isUnlocking = NO;
	});
}

%end

%hook SBLockScreenViewControllerBase

- (void)startLockScreenFadeInAnimationForSource:(int)arg1 {
	[[[RSLockScreenController sharedInstance] containerView] setHidden:NO];
	[[[RSLockScreenController sharedInstance] lockScreen] setAlpha:1];
	
	%orig;
}

%end

%hook SBLockScreenView

- (void)layoutSubviews {
	%orig;
	
	if ([RSCore sharedInstance] && !isUnlocking) {
		if (![self.superview.subviews containsObject:[[RSLockScreenController sharedInstance] containerView]]) {
			[self.superview addSubview:[[RSLockScreenController sharedInstance] containerView]];
		}
		
		[[[RSLockScreenController sharedInstance] containerView] setHidden:NO];
		[[[RSLockScreenController sharedInstance] lockScreen] setAlpha:1];
		[self.superview bringSubviewToFront:[[RSLockScreenController sharedInstance] containerView]];
	}
	
	[self setHidden:YES];
}

%end

%hook SBFLockScreenDateView

- (void)layoutSubviews {
	[MSHookIvar<UILabel *>(self,"_legibilityTimeLabel") removeFromSuperview];
	[MSHookIvar<UILabel *>(self,"_legibilityDateLabel") removeFromSuperview];
	
	if ([RSCore sharedInstance]) {
		[[RSLockScreenController sharedInstance] setTime:[MSHookIvar<SBUILegibilityLabel *>(self,"_legibilityTimeLabel") string]];
		[[RSLockScreenController sharedInstance] setDate:[MSHookIvar<SBUILegibilityLabel *>(self,"_legibilityDateLabel") string]];
		//[self bringSubviewToFront:[[RSLockScreenController sharedInstance] containerView]];
		
		[[[RSLockScreenController sharedInstance] mediaControls] setHidden:([[%c(SBMediaController) sharedInstance] nowPlayingApplication] == nil)];
	}
	
	%orig;
}

%end

%hook MPUMediaControlsTitlesView

- (void)updateTrackInformationWithNowPlayingInfo:(id)arg1 {
	%orig(arg1);
	
	[[[RSLockScreenController sharedInstance] mediaControls] updateNowPlayingInfo:arg1];
}

%end

%hook SBMediaController

-(void)_nowPlayingAppIsPlayingDidChange {
	%orig;
	
	[[[[RSLockScreenController sharedInstance] containerView] superview] layoutSubviews];
}

%end

%end // %group ios9

%ctor {
	NSDictionary* settings = [NSDictionary dictionaryWithContentsOfFile:PREFERENCES_PATH];
	
	if ([[settings objectForKey:@"lockScreenEnabled"] boolValue]) {
		if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_9_x_Max) {
			%init(ios10);
		} else if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_8_x_Max) {
			%init(ios9);
		}
	}
}
*/
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
	[[[RSLockScreenController sharedInstance] mediaControlsView] setHidden:([[%c(SBMediaController) sharedInstance] nowPlayingApplication] == nil)];
}

%end // %hook SBDashBoardView

%hook SBFLockScreenDateView

- (void)layoutSubviews {
	[MSHookIvar<SBUILegibilityLabel *>(self,"_timeLabel") removeFromSuperview];
	[MSHookIvar<SBUILegibilityLabel *>(self,"_dateSubtitleView") removeFromSuperview];
	[MSHookIvar<SBUILegibilityLabel *>(self,"_customSubtitleView") removeFromSuperview];
	
	[[RSLockScreenController sharedInstance] setLockScreenTime:[MSHookIvar<SBUILegibilityLabel *>(self,"_timeLabel") string]];
	[[RSLockScreenController sharedInstance] setLockScreenDate:[MSHookIvar<SBUILegibilityLabel *>(self,"_dateSubtitleView") string]];
	
	[[[RSLockScreenController sharedInstance] mediaControlsView] setHidden:([[%c(SBMediaController) sharedInstance] nowPlayingApplication] == nil)];
	
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

%hook MPUMediaControlsTitlesView

- (void)updateTrackInformationWithNowPlayingInfo:(id)arg1 {
	%orig(arg1);
	
	[[[RSLockScreenController sharedInstance] mediaControlsView] updateNowPlayingInfo:arg1];
}

%end // %hook MPUMediaControlsTitlesView

%hook SBMediaController

-(void)_nowPlayingAppIsPlayingDidChange {
	%orig;
	
	[[NSOperationQueue mainQueue] addOperationWithBlock:^ {
		[[[RSLockScreenController sharedInstance] mediaControlsView] setHidden:([[%c(SBMediaController) sharedInstance] nowPlayingApplication] == nil)];
	}];
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

-(void)_sendAddBulletin:(BBBulletin*)arg1 toFeeds:(unsigned long long)arg2 {
	[[NSOperationQueue mainQueue] addOperationWithBlock:^ {
		if (arg2 != 1 && [[%c(SBUserAgent) sharedUserAgent] deviceIsLocked]) {
			RSNotificationView* notificationView = [[RSNotificationView alloc] notificationForBulletin:arg1 isStatic:NO];
			[[RSLockScreenController sharedInstance] displayNotification:notificationView];
		}
	}];
	
	%log;
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
	[[[RSLockScreenController sharedInstance] mediaControlsView] setHidden:([[%c(SBMediaController) sharedInstance] nowPlayingApplication] == nil)];
}

%end // %hook SBLockScreenView

%hook SBFLockScreenDateView

- (void)layoutSubviews {
	[MSHookIvar<SBUILegibilityLabel *>(self,"_legibilityTimeLabel") removeFromSuperview];
	[MSHookIvar<SBUILegibilityLabel *>(self,"_legibilityDateLabel") removeFromSuperview];
	
	[[RSLockScreenController sharedInstance] setLockScreenTime:[MSHookIvar<SBUILegibilityLabel *>(self,"_legibilityTimeLabel") string]];
	[[RSLockScreenController sharedInstance] setLockScreenDate:[MSHookIvar<SBUILegibilityLabel *>(self,"_legibilityDateLabel") string]];
	
	[[[RSLockScreenController sharedInstance] mediaControlsView] setHidden:([[%c(SBMediaController) sharedInstance] nowPlayingApplication] == nil)];
	
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

%hook MPUMediaControlsTitlesView

- (void)updateTrackInformationWithNowPlayingInfo:(id)arg1 {
	%orig(arg1);
	
	[[[RSLockScreenController sharedInstance] mediaControlsView] updateNowPlayingInfo:arg1];
}

%end // %hook MPUMediaControlsTitlesView

%hook SBMediaController

-(void)_nowPlayingAppIsPlayingDidChange {
	%orig;
	
	[[NSOperationQueue mainQueue] addOperationWithBlock:^ {
		[[[RSLockScreenController sharedInstance] mediaControlsView] setHidden:([[%c(SBMediaController) sharedInstance] nowPlayingApplication] == nil)];
	}];
}

%end // %hook SBMediaController

%hook SBUIPasscodeLockViewWithKeypad

- (void)layoutSubviews {
	%log;
	[[[RSLockScreenController sharedInstance] passcodeEntryController] setCurrentKeypad:self];
	%orig;
}

- (void)passcodeEntryFieldTextDidChange:(id)arg1 {
	%log;
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
			RSNotificationView* notificationView = [[RSNotificationView alloc] notificationForBulletin:arg1 isStatic:NO];
			[[RSLockScreenController sharedInstance] displayNotification:notificationView];
		}
	}];
	
	%log;
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
