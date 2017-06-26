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
		
		self.mediaControlsView = [[RSNowPlayingControls alloc] initWithFrame:CGRectMake(24, 40, screenWidth-48, 120)];
		[self.lockScreenView addSubview:self.mediaControlsView];
		
		self.passcodeEntryController = [[RSLockScreenPasscodeEntryController alloc] init];
		[lockScreenScrollView addSubview:self.passcodeEntryController.passcodeEntryView];
		
		if ([[objc_getClass("SBLockScreenManager") sharedInstance] respondsToSelector:@selector(_setPasscodeVisible:animated:)]) {
			[[objc_getClass("SBLockScreenManager") sharedInstance] _setPasscodeVisible:NO animated:NO];
		}
	}
	
	return self;
}

- (void)setLockScreenTime:(NSString*)time {
	[self.lockScreenView setTime:time];
	
	[wallpaperOverlayView setHidden:![[objc_getClass("SBUserAgent") sharedUserAgent] deviceIsPasscodeLocked]];
	[self.passcodeEntryController.passcodeEntryView setHidden:![[objc_getClass("SBUserAgent") sharedUserAgent] deviceIsPasscodeLocked]];
}

- (void)setLockScreenDate:(NSString*)date {
	[self.lockScreenView setDate:date];
}

- (void)resetLockScreen {
	[lockScreenScrollView setContentOffset:CGPointZero];
	[self.lockScreenView setAlpha:1];
	[wallpaperOverlayView setAlpha:0];
	[self.passcodeEntryController resetTextField];
	
	self.isScrolling = NO;
	self.isShowingPasscodeScreen = NO;
}

- (void)attemptManualUnlockWithCompletionHandler:(void (^)(void))completion {
	if ([[objc_getClass("SBUserAgent") sharedUserAgent] deviceIsPasscodeLocked]) {
		[lockScreenScrollView setContentOffset:CGPointMake(0, screenHeight) animated:YES];
		if ([[objc_getClass("SBLockScreenManager") sharedInstance] respondsToSelector:@selector(_setPasscodeVisible:animated:)]) {
			[[objc_getClass("SBLockScreenManager") sharedInstance] _setPasscodeVisible:YES animated:NO];
		}
		self.isShowingPasscodeScreen = YES;
		
		self.completionHandler = completion;
	} else {
		//[[objc_getClass("SBLockScreenManager") sharedInstance] attemptUnlockWithPasscode:nil];
		completion();
	}
	
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	CGFloat alpha = 1 - MIN(scrollView.contentOffset.y / (scrollView.bounds.size.height * 0.6), 1);
	
	[self.lockScreenView setAlpha:alpha];
	[wallpaperOverlayView setAlpha:1-alpha];
	self.isScrolling = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	self.isScrolling = NO;
	
	if (scrollView.contentOffset.y >= scrollView.frame.size.height) {
		if ([[objc_getClass("SBUserAgent") sharedUserAgent] deviceIsPasscodeLocked]) {
			if ([[objc_getClass("SBLockScreenManager") sharedInstance] respondsToSelector:@selector(_setPasscodeVisible:animated:)]) {
				[[objc_getClass("SBLockScreenManager") sharedInstance] _setPasscodeVisible:YES animated:NO];
			}
			self.isShowingPasscodeScreen = YES;
		} else {
			[[objc_getClass("SBLockScreenManager") sharedInstance] attemptUnlockWithPasscode:nil];
		}
	} else {
		if ([[objc_getClass("SBLockScreenManager") sharedInstance] respondsToSelector:@selector(_setPasscodeVisible:animated:)]) {
			[[objc_getClass("SBLockScreenManager") sharedInstance] _setPasscodeVisible:NO animated:NO];
		}
		self.isShowingPasscodeScreen = NO;
	}
}

- (void)updateWallpaper {
	[wallpaperView setImage:[RSAesthetics lockScreenWallpaper]];
}

@end
