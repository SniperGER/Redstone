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
		CGPoint center = self.frame.origin;
		center.x = MIN(MAX(step * roundf((center.x / step)), 0), self.superview.frame.size.width - self.frame.size.width);
		center.y = MIN(MAX(step * roundf((center.y / step)), 0), CGFLOAT_MAX);
		
		[UIView animateWithDuration:.3 animations:^{
			[self setEasingFunction:easeOutQuint forKeyPath:@"frame"];
			[self setFrame:CGRectMake(center.x,
									  center.y,
									  self.frame.size.width,
									  self.frame.size.height)];
		} completion:^(BOOL finished) {
			[self removeEasingFunctionForKeyPath:@"frame"];
		}];
		
	} else {
		self.center = CGPointMake(touchLocation.x + self->centerOffset.x, touchLocation.y + self->centerOffset.y);
	}
}

@end
