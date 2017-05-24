#import "Redstone.h"
#import "substrate.h"

%group ios10

SBPagedScrollView* dashboardScrollView;

%hook SBDashBoardView

- (void)layoutSubviews {
	[MSHookIvar<UIView *>(self,"_pageControl") removeFromSuperview];
	%orig;
	
	if ([RSCore sharedInstance]) {
		if (![self.superview.subviews containsObject:[[RSLockScreenController sharedInstance] containerView]]) {
			[self.superview addSubview:[[RSLockScreenController sharedInstance] containerView]];
		}
	
		[[[RSLockScreenController sharedInstance] lockScreen] setHidden:NO];
		[[[RSLockScreenController sharedInstance] lockScreen] setAlpha:1];
		[self.superview bringSubviewToFront:[[RSLockScreenController sharedInstance] containerView]];
	}
	
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


%hook SBDashBoardNotificationListViewController

-(void)_setListHasContent:(BOOL)arg1 {
	%orig(NO);
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
