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

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	if (CGRectContainsPoint(self.frame, point) || [[RSStartScreenController sharedInstance] isEditing]) {
		return YES;
	}
	
	return [super pointInside:point withEvent:event];
}

@end
