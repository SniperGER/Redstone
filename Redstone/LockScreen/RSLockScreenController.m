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
		
		self.overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
		[self.overlayView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
		[self.overlayView setAlpha:0.0];
		[self.containerView addSubview:self.overlayView];
		
		self.lockScreen = [[RSLockScreen alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
		[self.lockScreen setDelegate:self];
		[self.containerView addSubview:self.lockScreen];
		
		self.mediaControls = [[RSMediaControls alloc] initWithFrame:CGRectMake(0, 40, screenWidth, 132)];
		[self.mediaControls setHidden:YES];
		[self.lockScreen addSubview:self.mediaControls];
		
		self.passcodeView = [[RSPasscodeView alloc] initWithFrame:CGRectMake(0, screenHeight*2-382, screenWidth, 382)];
		[self.passcodeView setHidden:![[objc_getClass("SBUserAgent") sharedUserAgent] deviceIsPasscodeLocked]];
		[self.lockScreen addSubview:self.passcodeView];
	}
	
	return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	self.isScrolling = YES;
	CGFloat alpha = 1 - (scrollView.contentOffset.y / (scrollView.bounds.size.height * 0.6));
	
	[self.lockScreen.timeLabel setAlpha:alpha];
	[self.lockScreen.dateLabel setAlpha:alpha];
	[self.mediaControls setAlpha:alpha];
	
	if ([[objc_getClass("SBUserAgent") sharedUserAgent] deviceIsPasscodeLocked]) {
		[self.overlayView setAlpha:1 - alpha];
	}
	
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	if (scrollView.contentOffset.y >= (scrollView.contentSize.height/2)) {
		if ([[objc_getClass("SBUserAgent") sharedUserAgent] deviceIsPasscodeLocked]) {
			self.isShowingPasscodeScreen = YES;
			return;
		}
		
		
		
		if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_9_x_Max) {
			[self.lockScreen setHidden:YES];
		} else if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_8_x_Max) {
			[self.containerView setHidden:YES];
		}
		
		self.isScrolling = NO;
		
		[[objc_getClass("SBLockScreenManager") sharedInstance] attemptUnlockWithPasscode:nil];
	} else {
		self.isShowingPasscodeScreen = NO;
		self.isScrolling = NO;
	}
}

- (void)setTime:(NSString*)time {
	[self.lockScreen.timeLabel setText:time];
	[self.lockScreen.timeLabel sizeToFit];
	
	CGRect timeLabelFrame = self.lockScreen.timeLabel.frame;
	[self.lockScreen.timeLabel setFrame:CGRectMake(24, screenHeight - 160 - timeLabelFrame.size.height, timeLabelFrame.size.width, timeLabelFrame.size.height)];
}
- (void)setDate:(NSString*)date {
	[self.lockScreen.dateLabel setText:date];
	[self.lockScreen.dateLabel sizeToFit];
	
	CGRect dateLabelFrame = self.lockScreen.dateLabel.frame;
	[self.lockScreen.dateLabel setFrame:CGRectMake(24, screenHeight - 130 - dateLabelFrame.size.height, dateLabelFrame.size.width, dateLabelFrame.size.height)];
}

- (void)resetLockScreen {
	UIView* dashBoardView = [[[objc_getClass("SBLockScreenManager") sharedInstance] lockScreenViewController] view];
	[dashBoardView setAlpha:1];
	
	[self.lockScreen setContentOffset:CGPointZero];
	
	[self.lockScreen setAlpha:0];
	[self.lockScreen.timeLabel setAlpha:1];
	[self.lockScreen.dateLabel setAlpha:1];
	[self.overlayView setAlpha:0.0];
	[self.mediaControls setAlpha:1];
	[self.passcodeView resetPasscodeTextField];
}

@end
