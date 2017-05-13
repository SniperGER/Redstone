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
		
		UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
		[self addGestureRecognizer:tapGestureRecognizer];
	}
	
	return self;
}

- (void)tapped {
	[[RSAppListController sharedInstance] hidePinMenu];
}

@end
