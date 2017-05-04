#import "Redstone.h"

@implementation RSStartScrollView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		[self setContentInset:UIEdgeInsetsMake(24, 0, 60, 0)];
		[self setClipsToBounds:NO];
	}
	
	return self;
}

@end
