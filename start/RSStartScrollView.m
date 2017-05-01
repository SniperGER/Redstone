#import "../RedstoneHeaders.h"

@implementation RSStartScrollView

- (id)initWithFrame:(CGRect)frame {
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

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	/*NSLog(@"[Redstone] Touch moved");
	UITouch *aTouch = [touches anyObject];
	CGPoint location = [aTouch locationInView:self];
	CGPoint previousLocation = [aTouch previousLocationInView:self];

	RSTile* selectedTile = [[RSStartScreenController sharedInstance] selectedTile];

	if ([aTouch view] == selectedTile) {
		[selectedTile setFrame:CGRectOffset(self.frame, (location.x - previousLocation.x), (location.y - previousLocation.y))];

		if (CGRectContainsPoint(selectedTile.frame, location)) {
			
		}
	}*/
}

@end
