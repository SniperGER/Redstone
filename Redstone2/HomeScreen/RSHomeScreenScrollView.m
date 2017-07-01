#import "../Redstone.h"

@implementation RSHomeScreenScrollView

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self setContentSize:CGSizeMake(frame.size.width*2, frame.size.height)];
		[self setPagingEnabled:YES];
		[self setBounces:NO];
		[self setShowsVerticalScrollIndicator:NO];
		[self setShowsHorizontalScrollIndicator:NO];
	}
	
	return self;
}

@end
