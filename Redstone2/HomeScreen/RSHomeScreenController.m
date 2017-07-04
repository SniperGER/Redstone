#import "../Redstone.h"

@implementation RSHomeScreenController

static RSHomeScreenController* sharedInstance;

+ (id)sharedInstance {
	return sharedInstance;
}

- (id)init {
	if (self = [super init]) {
		sharedInstance = self;
		
		startScreenController = [RSStartScreenController new];
		appListController = [RSAppListController new];
		launchScreenController = [RSLaunchScreenController new];
		
		self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
		[self.window setWindowLevel:-2];
		[self.window makeKeyAndVisible];
		
		wallpaperView = [[UIImageView alloc] initWithFrame:CGRectMake(-100, -100, screenWidth+200, screenHeight+200)];
		[wallpaperView setContentMode:UIViewContentModeScaleAspectFill];
		[wallpaperView setImage:[RSAesthetics homeScreenWallpaper]];
		[self.window addSubview:wallpaperView];
		
		scrollView = [[RSHomeScreenScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
		[scrollView setDelegate:self];
		[self.window addSubview:scrollView];
		
		[scrollView addSubview:startScreenController.view];
		[scrollView addSubview:appListController.view];
	}
	
	return self;
}

- (void)setParallaxPosition {
	CGFloat position = (([(UIScrollView*)startScreenController.view contentOffset].y - 0) / [(UIScrollView*)startScreenController.view contentSize].height) * 200;
	[wallpaperView setTransform:CGAffineTransformMakeTranslation(0, -position)];
}

- (void)deviceHasBeenUnlocked {
	[scrollView setAlpha:0];
	
	[UIView animateWithDuration:0.3 animations:^{
		[scrollView setEasingFunction:easeInCubic forKeyPath:@"opacity"];
		[scrollView setAlpha:1.0];
	} completion:^(BOOL finished) {
		[scrollView removeEasingFunctionForKeyPath:@"opacity"];
	}];
}

- (CGFloat)launchApplication {
	if (scrollView.contentOffset.x < screenWidth) {
		[startScreenController animateOut];
		
		return [startScreenController getMaxDelayForAnimation];
	} else {
		[appListController animateOut];
		
		return [appListController getMaxDelayForAnimation];
	}
	
	return 0;
}

- (void)scrollViewDidScroll:(UIScrollView *)_scrollView {
	CGFloat progress = MIN(_scrollView.contentOffset.x / _scrollView.frame.size.width, 0.75);
	
	[_scrollView setBackgroundColor:[[[RSAesthetics colorsForCurrentTheme] objectForKey:@"OpaqueBackgroundColor"] colorWithAlphaComponent:progress]];
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
	[scrollView setScrollEnabled:scrollEnabled];
}

- (void)setContentOffset:(CGPoint)offset {
	[scrollView setContentOffset:offset];
}

@end
