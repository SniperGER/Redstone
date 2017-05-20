#import "Redstone.h"
#import "substrate.h"

UIScrollView* testView;

%hook SBDashBoardView

/*- (id)initWithFrame:(id)arg1 {
	self = %orig(arg1);
	
	[testView = [UIScrollView alloc] initWithFrame:CGRectMake(0,0,screenWidth,screenHeight)];
	[testView setBackgroundColor:[UIColor magentaColor]];
	[self addSubview:testView];
	
	return self;
}*/

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
