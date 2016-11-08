#import "RSStartScrollView.h"

@implementation RSStartScrollView

-(id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	if (self) {
		[self setShowsHorizontalScrollIndicator:NO];
		[self setShowsVerticalScrollIndicator:NO];
		[self setDelaysContentTouches:NO];
		[self setDelegate:self];
		[self setMultipleTouchEnabled:NO];

		[self setContentInset:UIEdgeInsetsMake(24,1,60,1)];
	}

	return self;
}

@end