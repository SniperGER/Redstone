#import "Redstone.h"
#import "substrate.h"

%group lockscreen

%hook SBDashBoardView

- (void)layoutSubviews {
	[MSHookIvar<UIView *>(self,"_pageControl") removeFromSuperview];
	%orig;
	
	if (![self.subviews containsObject:[[RSLockScreenController sharedInstance] containerView]]) {
		[self addSubview:[[RSLockScreenController sharedInstance] containerView]];
	}
	
	if ([RSCore sharedInstance]) {
		[[[RSLockScreenController sharedInstance] lockScreen] setHidden:NO];
		[self bringSubviewToFront:[[RSLockScreenController sharedInstance] containerView]];
	}
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

%hook SBDashBoardMediaArtworkViewController

-(void)willTransitionToPresented:(BOOL)arg1 {
	%orig(NO);
	
	[[[RSLockScreenController sharedInstance] mediaControls] setHidden:!arg1];
}

%end

%hook MPUMediaControlsTitlesView

- (void)updateTrackInformationWithNowPlayingInfo:(id)arg1 {
	%orig(arg1);
	
	[[[RSLockScreenController sharedInstance] mediaControls] updateNowPlayingInfo:arg1];
}

%end

%end

%ctor {
	NSDictionary* settings = [NSDictionary dictionaryWithContentsOfFile:PREFERENCES_PATH];
	
	if ([[settings objectForKey:@"lockScreenEnabled"] boolValue]) {
		%init(lockscreen);
	}
}
