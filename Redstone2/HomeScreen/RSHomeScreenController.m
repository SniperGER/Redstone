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
		
		if ([[[RSPreferences preferences] objectForKey:@"debugAppList"] boolValue]) {
			appListController = [RSAppListController new];
		}
		//appSwitcherController = [RSAppSwitcherController new];
		launchScreenController = [RSLaunchScreenController new];
		
		self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
		[self.window setWindowLevel:-2];
		[self.window makeKeyAndVisible];
		
		wallpaperView = [[UIImageView alloc] initWithImage:[RSAesthetics homeScreenWallpaper]];
		[wallpaperView setBackgroundColor:[RSAesthetics colorsForCurrentTheme][@"InvertedForegroundColor"]];
		[wallpaperView setContentMode:UIViewContentModeScaleAspectFill];
		[wallpaperView setFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
		[wallpaperView setTransform:CGAffineTransformMakeScale(1.5, 1.5)];
		[self.window addSubview:wallpaperView];
		
		scrollView = [[RSHomeScreenScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
		[scrollView setDelegate:self];
		[self.window addSubview:scrollView];
		
		[scrollView addSubview:startScreenController.view];
		[scrollView addSubview:appListController.view];
		[scrollView addSubview:appListController.jumpList];
		
		
		if ([startScreenController pinnedTiles].count == 0) {
			[scrollView setContentOffset:CGPointMake(screenWidth, 0)];
			[scrollView setScrollEnabled:NO];
		}
		[self setParallaxPosition];
		
		self.alertControllers = [NSMutableArray new];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateWallpaper) name:@"RedstoneWallpaperChanged" object:nil];
	}
	
	return self;
}

- (RSStartScreenController*)startScreenController {
	return startScreenController;
}

- (RSAppListController*)appListController {
	return appListController;
}

- (RSAppSwitcherController*)appSwitcherController {
	return appSwitcherController;
}

- (RSLaunchScreenController*)launchScreenController {
	return launchScreenController;
}

- (void)updateWallpaper {
	[wallpaperView setImage:[RSAesthetics homeScreenWallpaper]];
}

- (RSHomeScreenScrollView*)scrollView {
	return scrollView;
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

#pragma mark App Switcher

- (void)showAppSwitcherIncludingHomeScreenCard:(BOOL)homeScreenCard {
	[appSwitcherController setHomeScreenView:startScreenController.view];
	[startScreenController.view setHidden:YES];
	[[appSwitcherController window] makeKeyAndVisible];
}

- (void)hideAppSwitcher {
	[startScreenController.view setHidden:NO];
	[[appSwitcherController window] setHidden:YES];
}

#pragma mark Delegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)_scrollView {
	CGFloat progress = MIN(_scrollView.contentOffset.x / _scrollView.frame.size.width, 0.75);
	
	[_scrollView setBackgroundColor:[[[RSAesthetics colorsForCurrentTheme] objectForKey:@"OpaqueBackgroundColor"]  colorWithAlphaComponent:progress]];
	[appListController setSectionOverlayAlpha:progress];
	[appListController updateSectionOverlayPosition];
	
	[appListController.searchBar resignFirstResponder];
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
	if ([startScreenController pinnedTiles].count > 0) {
		[scrollView setScrollEnabled:scrollEnabled];
	} else {
		[scrollView setScrollEnabled:NO];
	}
}

- (CGPoint)contentOffset {
	return scrollView.contentOffset;
}

- (void)setContentOffset:(CGPoint)offset {
	if ([startScreenController pinnedTiles].count > 0) {
		[scrollView setContentOffset:offset];
	} else {
		[scrollView setContentOffset:CGPointMake(screenWidth, 0)];
	}
}

- (void)setContentOffset:(CGPoint)offset animated:(BOOL)animated {
	[scrollView setContentOffset:offset animated:animated];
}

#pragma mark Parallax Wallpaper

- (CGFloat)parallaxPosition {
	CGFloat viewPosition = [(UIScrollView*)startScreenController.view contentOffset].y;
	CGFloat viewHeight = MAX([(UIScrollView*)startScreenController.view contentOffset].y, screenHeight);
	
	CGFloat position = (viewPosition / viewHeight) * ((screenWidth * 1.5) - screenWidth);
	return position;
}

- (void)setParallaxPosition {
	CGFloat position = [self parallaxPosition];
	
	[wallpaperView setTransform:CGAffineTransformConcat(CGAffineTransformMakeScale(1.5, 1.5), CGAffineTransformMakeTranslation(0, -position))];
}

@end
