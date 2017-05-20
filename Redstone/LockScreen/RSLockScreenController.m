#import "../Redstone.h"

@implementation RSLockScreenController

- (id)init {
	self = [super init];
	
	if (self) {
		self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
		
		UIImageView* wallpaperView = [[UIImageView alloc] initWithImage:[RSAesthetics getCurrentWallpaper]];
		[wallpaperView setFrame:[[UIScreen mainScreen] bounds]];
		[self.containerView addSubview:wallpaperView];
		
		self.lockScreen = [[RSLockScreen alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
		[self.lockScreen setDelegate:self];
		[self.containerView addSubview:self.lockScreen];
	}
	
	return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	CGFloat alpha = 1 - (scrollView.contentOffset.y / (scrollView.contentSize.height / 2));
	
	[self.lockScreen.timeLabel setAlpha:alpha];
	[self.lockScreen.dateLabel setAlpha:alpha];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	if (scrollView.contentOffset.y >= (scrollView.contentSize.height/2)) {
		UIView* dashBoardView = [[[objc_getClass("SBLockScreenManager") sharedInstance] lockScreenViewController] view];
		
		[UIView animateWithDuration:.3 animations:^{
			[dashBoardView setEasingFunction:easeOutQuint forKeyPath:@"frame"];
			
			[dashBoardView setAlpha:0];
		} completion:^(BOOL finished) {
			[dashBoardView removeEasingFunctionForKeyPath:@"frame"];
			
			[[objc_getClass("SBLockScreenManager") sharedInstance] attemptUnlockWithPasscode:nil];
			[self.lockScreen setContentOffset:CGPointZero];
			[self.lockScreen setHidden:YES];
			[dashBoardView setAlpha:1];
		}];
		
	}
}

- (void)setTime:(NSString*)time {
	[self.lockScreen.timeLabel setText:time];
	[self.lockScreen.timeLabel sizeToFit];
	
	CGRect timeLabelFrame = self.lockScreen.timeLabel.frame;
	[self.lockScreen.timeLabel setFrame:CGRectMake(24, screenHeight - 150 - timeLabelFrame.size.height, timeLabelFrame.size.width, timeLabelFrame.size.height)];
}
- (void)setDate:(NSString*)date {
	[self.lockScreen.dateLabel setText:date];
	[self.lockScreen.dateLabel sizeToFit];
	
	CGRect dateLabelFrame = self.lockScreen.dateLabel.frame;
	[self.lockScreen.dateLabel setFrame:CGRectMake(24, screenHeight - 110 - dateLabelFrame.size.height, dateLabelFrame.size.width, dateLabelFrame.size.height)];
}

@end
