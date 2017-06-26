#import "../Redstone.h"

@implementation RSVolumeSlider

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		minValue = 0;
		maxValue = 1;
		
		trackLayer = [CALayer new];
		[trackLayer setFrame:CGRectMake(0, frame.size.height/2 - 2/2, frame.size.width, 2)];
		[trackLayer setBackgroundColor:[UIColor colorWithWhite:0.43 alpha:1.0].CGColor];
		[self.layer addSublayer:trackLayer];
		
		trackFillLayer = [CALayer new];
		[trackFillLayer setFrame:CGRectMake(0, frame.size.height/2 - 2/2, 0, 2)];
		[trackFillLayer setBackgroundColor:[RSAesthetics accentColor].CGColor];
		[self.layer addSublayer:trackFillLayer];
		
		thumbLayer = [CALayer new];
		[thumbLayer setFrame:CGRectMake(0, 0, 8, 24)];
		[thumbLayer setBackgroundColor:[RSAesthetics accentColor].CGColor];
		[thumbLayer setCornerRadius:4.0];
		[self.layer addSublayer:thumbLayer];
	}
	
	return self;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
	[super beginTrackingWithTouch:touch withEvent:event];
	
	CGPoint location = [touch locationInView:self];
	
	if (CGRectContainsPoint(CGRectInset(thumbLayer.frame, -14, -6), location)) {
		return YES;
	}
	
	return NO;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
	[super continueTrackingWithTouch:touch withEvent:event];
	
	CGPoint location = [touch locationInView:self];
	
	currentValue = (MIN(MAX(location.x, 0), self.frame.size.width) / self.frame.size.width) * maxValue;
	currentValue = MIN(MAX(currentValue, minValue), maxValue);
	
	[self updateLayerFrames];
	[self sendActionsForControlEvents:UIControlEventValueChanged];
	
	return YES;
}

- (void)updateLayerFrames {
	CGFloat value = (currentValue / maxValue);
	CGFloat position = (self.frame.size.width * value) - (thumbLayer.frame.size.width * value);
	
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	
	[thumbLayer setFrame:CGRectMake(position, 0, thumbLayer.frame.size.width, thumbLayer.frame.size.height)];
	[trackFillLayer setFrame:CGRectMake(0, trackFillLayer.frame.origin.y, position, trackFillLayer.frame.size.height)];
	
	[CATransaction commit];
}

- (float)currentValue {
	return currentValue;
}
- (float)minValue {
	return minValue;
}
- (float)maxValue {
	return maxValue;
}
- (void)setValue:(float)value {
	currentValue = value;
	[self updateLayerFrames];
}
- (void)setMinValue:(float)value {
	minValue = value;
	[self updateLayerFrames];
}
- (void)setMaxValue:(float)value {
	maxValue = value;
	[self updateLayerFrames];
}

@end
