#import "RSAppSwitcherContainerView.h"

@implementation RSAppSwitcherContainerView

- (UIView *)hitTest:(CGPoint) point withEvent:(UIEvent *)event {
	UIView* view = [super hitTest:point withEvent:event];
	
	if (view == self) {
		return [[self subviews] objectAtIndex:0];
	}
	
	return view;
}

@end
