#import "../Redstone.h"

@implementation RSAppListScrollView

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self setShowsVerticalScrollIndicator:NO];
		[self setShowsHorizontalScrollIndicator:NO];
		[self setDelaysContentTouches:NO];
		[self setClipsToBounds:YES];
		[self setContentInset:UIEdgeInsetsMake(0, 0, 80, 0)];
		
		[self setTranslatesAutoresizingMaskIntoConstraints:NO];
	}
	
	return self;
}

@end
