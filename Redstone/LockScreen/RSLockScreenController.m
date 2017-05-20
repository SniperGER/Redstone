#import "../Redstone.h"

@implementation RSLockScreenController

static RSLockScreenController* sharedInstance;

+ (id)sharedInstance {
	return sharedInstance;
}

- (id)init {
	self = [super init];
	
	if (self) {
		sharedInstance = self;
		self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
		
		self.wallpaperView = [[UIImageView alloc] initWithImage:[RSAesthetics lockScreenWallpaper]];
		[self.wallpaperView setFrame:[[UIScreen mainScreen] bounds]];
		[self.containerView addSubview:self.wallpaperView];
		
		self.lockScreen = [[RSLockScreen alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
		[self.lockScreen setDelegate:self];
		[self.containerView addSubview:self.lockScreen];
	}
	
	return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	self.isScrolling = YES;
	CGFloat alpha = 1 - (scrollView.contentOffset.y / (scrollView.bounds.size.height * 0.6));
	
	[self.lockScreen.timeLabel setAlpha:alpha];
	[self.lockScreen.dateLabel setAlpha:alpha];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	if (scrollView.contentOffset.y >= (scrollView.contentSize.height/2)) {
		UIView* dashBoardView = [[[objc_getClass("SBLockScreenManager") sharedInstance] lockScreenViewController] view];
		
		[[objc_getClass("SBLockScreenManager") sharedInstance] attemptUnlockWithPasscode:nil];
		[self.lockScreen setContentOffset:CGPointZero];
		[self.lockScreen setHidden:YES];
		[dashBoardView setAlpha:1];
		self.isScrolling = NO;
		
	} else {
		self.isScrolling = NO;
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
