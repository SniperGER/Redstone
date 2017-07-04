#import "../Redstone.h"

@implementation RSAppListScrollView

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self setShowsVerticalScrollIndicator:YES];
		[self setShowsHorizontalScrollIndicator:NO];
		[self setDelaysContentTouches:NO];
		[self setClipsToBounds:YES];
		[self setContentInset:UIEdgeInsetsMake(0, 0, 80, 0)];
		
		[self setContentSize:CGSizeMake(screenWidth, 1000)];
	}
	
	return self;
}

@end
