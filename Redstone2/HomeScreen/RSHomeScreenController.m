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
		
		wallpaperView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
		[wallpaperView setContentMode:UIViewContentModeScaleAspectFill];
		[wallpaperView setImage:[RSAesthetics homeScreenWallpaper]];
		[wallpaperView setTransform:CGAffineTransformMakeScale(1.5, 1.5)];
		[self.window addSubview:wallpaperView];
		
		scrollView = [[RSHomeScreenScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
		[scrollView setDelegate:self];
		[self.window addSubview:scrollView];
		
		[scrollView addSubview:startScreenController.view];
		[scrollView addSubview:appListController.view];
		[scrollView addSubview:appListController.jumpList];
		
		[self setParallaxPosition];
		
		self.alertControllers = [NSMutableArray new];
	}
	
	return self;
}

- (RSHomeScreenScrollView*)scrollView {
	return scrollView;
}

- (CGFloat)parallaxPosition {
	return (([(UIScrollView*)startScreenController.view contentOffset].y - 0) / [(UIScrollView*)startScreenController.view contentSize].height) * (screenWidth*1.5 - screenWidth);
}

- (void)setParallaxPosition {
	CGFloat position = (([(UIScrollView*)startScreenController.view contentOffset].y - 0) / [(UIScrollView*)startScreenController.view contentSize].height) * (screenWidth*1.5 - screenWidth);
	
	[wallpaperView setTransform:CGAffineTransformConcat(CGAffineTransformMakeScale(1.5, 1.5), CGAffineTransformMakeTranslation(0, -position))];
}

- (void)deviceHasBeenUnlocked {
	[scrollView setAlpha:0];
	
	[startScreenController startLiveTiles];
	
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
	
	[_scrollView setBackgroundColor:[[[RSAesthetics colorsForCurrentTheme] objectForKey:@"OpaqueBackgroundColor"]  colorWithAlphaComponent:progress]];
	[[RSAppListController sharedInstance] setSectionOverlayAlpha:progress];
	[[RSAppListController sharedInstance] updateSectionOverlayPosition];
	
	[appListController.searchBar resignFirstResponder];
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
	[scrollView setScrollEnabled:scrollEnabled];
}

- (CGPoint)contentOffset {
	return scrollView.contentOffset;
}

- (void)setContentOffset:(CGPoint)offset {
	[scrollView setContentOffset:offset];
}

- (void)setContentOffset:(CGPoint)offset animated:(BOOL)animated {
	[scrollView setContentOffset:offset animated:animated];
}

@end
