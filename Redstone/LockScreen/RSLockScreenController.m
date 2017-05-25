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
		
		wallpaperView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
		[wallpaperView setImage:[RSAesthetics lockScreenWallpaper]];
		[self.containerView addSubview:wallpaperView];
		
		wallpaperOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
		[wallpaperOverlayView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.75]];
		[wallpaperOverlayView setAlpha:0];
		[self.containerView addSubview:wallpaperOverlayView];
		
		lockScreenScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
		[lockScreenScrollView setContentSize:CGSizeMake(screenWidth, screenHeight*2)];
		[lockScreenScrollView setBounces:NO];
		[lockScreenScrollView setPagingEnabled:YES];
		[lockScreenScrollView setShowsVerticalScrollIndicator:NO];
		[lockScreenScrollView setShowsHorizontalScrollIndicator:NO];
		[lockScreenScrollView setDelegate:self];
		[self.containerView addSubview:lockScreenScrollView];
		
		self.lockScreenView = [[RSLockScreenView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
		[lockScreenScrollView addSubview:self.lockScreenView];
	}
	
	return self;
}

- (void)setLockScreenTime:(NSString*)time {
	[self.lockScreenView setTime:time];
	
	[wallpaperOverlayView setHidden:![[objc_getClass("SBUserAgent") sharedUserAgent] deviceIsPasscodeLocked]];
}

- (void)setLockScreenDate:(NSString*)date {
	[self.lockScreenView setDate:date];
}

- (void)resetLockScreen {
	[lockScreenScrollView setContentOffset:CGPointZero];
	[self.lockScreenView setAlpha:1];
	[wallpaperOverlayView setAlpha:0];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	CGFloat alpha = 1 - MIN(scrollView.contentOffset.y / (scrollView.bounds.size.height * 0.6), 1);
	
	[self.lockScreenView setAlpha:alpha];
	[wallpaperOverlayView setAlpha:1-alpha];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	if (scrollView.contentOffset.y >= scrollView.frame.size.height) {
		if ([[objc_getClass("SBUserAgent") sharedUserAgent] deviceIsPasscodeLocked]) {
			
		} else {
			[[objc_getClass("SBLockScreenManager") sharedInstance] attemptUnlockWithPasscode:nil];
		}
	}
}

@end
