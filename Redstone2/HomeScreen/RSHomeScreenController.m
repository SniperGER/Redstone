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
		
		window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
		[window setWindowLevel:-2];
		[window makeKeyAndVisible];
		
		scrollView = [[RSHomeScreenScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
		[scrollView setDelegate:self];
		[window addSubview:scrollView];
		
		[scrollView addSubview:startScreenController.view];
	}
	
	return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)_scrollView {
	CGFloat progress = MIN(_scrollView.contentOffset.x / _scrollView.frame.size.width, 0.75);
	
	[_scrollView setBackgroundColor:[[[RSAesthetics colorsForTheme:@"dark"] objectForKey:@"RedstoneOpaqueBackgroundColor"] colorWithAlphaComponent:progress]];
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
	[scrollView setScrollEnabled:scrollEnabled];
}

@end
