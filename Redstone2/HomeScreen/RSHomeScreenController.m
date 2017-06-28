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
		[window setBackgroundColor:[UIColor magentaColor]];
		[window makeKeyAndVisible];
		
		scrollView = [[RSHomeScreenScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
		[scrollView setDelegate:self];
		[window addSubview:scrollView];
		
		[scrollView addSubview:startScreenController.view];
	}
	
	return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)_scrollView {
	CGFloat progress = MIN(_scrollView.contentOffset.x / _scrollView.contentSize.width, 0.75);
	
	[_scrollView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:progress]];
}

@end
