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
	
	if (![self.subviews containsObject:[[RSCore sharedInstance] lockScreenController].containerView]) {
		[self addSubview:[[RSCore sharedInstance] lockScreenController].containerView];
	}
	
	if ([RSCore sharedInstance]) {
		[[[RSCore sharedInstance] lockScreenController].lockScreen setHidden:NO];
		[self bringSubviewToFront:[[RSCore sharedInstance] lockScreenController].containerView];
	}
}

%end

%hook SBFLockScreenDateView

- (void)layoutSubviews {
	[MSHookIvar<UILabel *>(self,"_timeLabel") removeFromSuperview];
	[MSHookIvar<UILabel *>(self,"_dateSubtitleView") removeFromSuperview];
	[MSHookIvar<UILabel *>(self,"_customSubtitleView") removeFromSuperview];
	
	if ([RSCore sharedInstance]) {
		[[[RSCore sharedInstance] lockScreenController] setTime:[MSHookIvar<SBUILegibilityLabel *>(self,"_timeLabel") string]];
		[[[RSCore sharedInstance] lockScreenController] setDate:[MSHookIvar<SBUILegibilityLabel *>(self,"_dateSubtitleView") string]];
		[self bringSubviewToFront:[[RSCore sharedInstance] lockScreenController].containerView];
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
