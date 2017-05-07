#import "Redstone.h"

@implementation RSTile

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		[self setBackgroundColor:[UIColor colorWithRed:0.0 green:0.47 blue:0.843 alpha:1.0]];
		UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveViewWithGestureRecognizer:)];
		[self addGestureRecognizer:pan];
	}
	
	return self;
}

- (void)moveViewWithGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer {
	CGPoint touchLocation = [panGestureRecognizer locationInView:self.superview];
	
	if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
		[self.superview bringSubviewToFront:self];
		
		CGPoint relativePosition = [self.superview convertPoint:self.center toView:self.superview];
		self->centerOffset = CGPointMake(relativePosition.x - touchLocation.x, relativePosition.y - touchLocation.y);
	} else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
		self->centerOffset = CGPointZero;
		
		float step = [RSMetrics tileDimensionsForSize:1].width + [RSMetrics tileBorderSpacing];
		
		CGRect newTilePosition = CGRectMake(MIN(MAX(step * roundf((self.frame.origin.x / step)), 0), self.superview.frame.size.width - self.frame.size.width),
											MIN(MAX(step * roundf((self.frame.origin.y / step)), 0), self.superview.frame.size.height - self.frame.size.height),
											self.frame.size.width,
											self.frame.size.height);
		
		[UIView animateWithDuration:.3 animations:^{
			[self setEasingFunction:easeOutQuint forKeyPath:@"frame"];
			[self setFrame:newTilePosition];
		} completion:^(BOOL finished) {
			[self removeEasingFunctionForKeyPath:@"frame"];
		}];
		[[[RSCore sharedInstance] startScreenController] moveAffectedTilesForTile:self];
	} else {
		self.center = CGPointMake(touchLocation.x + self->centerOffset.x, touchLocation.y + self->centerOffset.y);
	}
}

- (CGRect)positionWithoutTransform {
	return CGRectMake(self.layer.position.x - (self.bounds.size.width/2),
					  self.layer.position.y - (self.bounds.size.height/2),
					  self.bounds.size.width,
					  self.bounds.size.height);
}

@end
