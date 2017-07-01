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
		//appListController = [RSAppListController new];
		launchScreenController = [RSLaunchScreenController new];
		
		window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
		[window setWindowLevel:-2];
		[window makeKeyAndVisible];
		
		wallpaperView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
		[wallpaperView setContentMode:UIViewContentModeScaleAspectFill];
		[wallpaperView setImage:[RSAesthetics homeScreenWallpaper]];
		[window addSubview:wallpaperView];
		
		scrollView = [[RSHomeScreenScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
		[scrollView setDelegate:self];
		[window addSubview:scrollView];
		
		[scrollView addSubview:startScreenController.view];
	}
	
	return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)_scrollView {
	CGFloat progress = MIN(_scrollView.contentOffset.x / _scrollView.frame.size.width, 0.75);
	
	[_scrollView setBackgroundColor:[[[RSAesthetics colorsForCurrentTheme] objectForKey:@"RedstoneOpaqueBackgroundColor"] colorWithAlphaComponent:progress]];
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
	[scrollView setScrollEnabled:scrollEnabled];
}

@end
