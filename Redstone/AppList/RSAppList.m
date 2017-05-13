#import "../Redstone.h"

@implementation RSAppList

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		[self setShowsVerticalScrollIndicator:NO];
		[self setShowsHorizontalScrollIndicator:NO];
		[self setDelaysContentTouches:NO];
		[self setClipsToBounds:YES];
		[self setContentInset:UIEdgeInsetsMake(0, 0, 80, 0)];
	}
	
	return self;
}

@end
