#import "Redstone.h"
#import "substrate.h"

%group lockscreen

%hook SBDashBoardView

- (void)layoutSubviews {
	[MSHookIvar<UIView *>(self,"_pageControl") removeFromSuperview];
	%orig;
	
	if (![self.superview.subviews containsObject:[[RSLockScreenController sharedInstance] containerView]]) {
		[self.superview addSubview:[[RSLockScreenController sharedInstance] containerView]];
	}
	
	if ([RSCore sharedInstance]) {
		[[[RSLockScreenController sharedInstance] lockScreen] setHidden:NO];
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
	if (self.contentSize.width == screenWidth * 3) {
		[self setScrollEnabled:NO];
		[self setUserInteractionEnabled:NO];
		[self setContentOffset:CGPointMake(-screenWidth, 0)];
	} else {
		%orig;
	}
}

%end

%end

%ctor {
	NSDictionary* settings = [NSDictionary dictionaryWithContentsOfFile:PREFERENCES_PATH];
	
	if ([[settings objectForKey:@"lockScreenEnabled"] boolValue]) {
		%init(lockscreen);
	}
}
