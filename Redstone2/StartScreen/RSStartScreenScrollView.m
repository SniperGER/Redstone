#import "../Redstone.h"

@implementation RSStartScreenScrollView

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self setClipsToBounds:NO];
		[self setDelaysContentTouches:NO];
		[self setContentInset:UIEdgeInsetsMake(24, 0, 70, 0)];
		[self setContentOffset:CGPointMake(0, -24)];
		
		[self setShowsVerticalScrollIndicator:NO];
		[self setShowsHorizontalScrollIndicator:NO];
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
