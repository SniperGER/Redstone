#import "../Redstone.h"

@implementation RSStartScrollView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		[self setContentInset:UIEdgeInsetsMake(24, 0, 64, 0)];
		[self setClipsToBounds:NO];
		[self setShowsVerticalScrollIndicator:NO];
		[self setShowsHorizontalScrollIndicator:NO];
		[self setDelaysContentTouches:NO];
	}
	
	return self;
}

@end
