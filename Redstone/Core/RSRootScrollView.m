#import "../Redstone.h"

@implementation RSRootScrollView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		[self setDelegate:self];
		
		[self setContentSize:CGSizeMake(screenWidth*2, screenHeight)];
		[self setPagingEnabled:YES];
		[self setBounces:NO];
		
		//[self setScrollEnabled:NO];
	}
	
	return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[self setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:MIN(scrollView.contentOffset.x / scrollView.frame.size.width, 0.75)]];
}

@end
