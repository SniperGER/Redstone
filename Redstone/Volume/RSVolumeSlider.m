#import "../Redstone.h"

@implementation RSVolumeSlider

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame]; // 340x36
	
	if (self) {
		//[self setBackgroundColor:[UIColor greenColor]];
		minValue = 0;
		maxValue = 1;
		
		trackLayer = [CALayer new];
		[trackLayer setFrame:CGRectMake(0, 11, frame.size.width, 2)];
		[trackLayer setBackgroundColor:[UIColor colorWithWhite:0.43 alpha:1.0].CGColor];
		[self.layer addSublayer:trackLayer];
		
		trackFillLayer = [CALayer new];
		[trackFillLayer setFrame:CGRectMake(0, 11, 0, 2)];
		[trackFillLayer setBackgroundColor:[RSAesthetics accentColor].CGColor];
		[self.layer addSublayer:trackFillLayer];
		
		thumbLayer = [CALayer new];
		[thumbLayer setFrame:CGRectMake(0, 0, 8, 24)];
		[thumbLayer setBackgroundColor:[RSAesthetics accentColor].CGColor];
		[thumbLayer setCornerRadius:4];
		[self.layer addSublayer:thumbLayer];
	}
	
	return self;
}

- (void)setValue:(float)value {
	currentValue = MIN(MAX(value, minValue), maxValue);
	[self updateLayerFrames];
}

- (float)value {
	return currentValue;
}

- (void)setMinValue:(float)value {
	minValue = value;
	[self updateLayerFrames];
}

- (float)minValue {
	return minValue;
}

- (void)setMaxValue:(float)value {
	maxValue = value;
	[self updateLayerFrames];
}

- (float)maxValue {
	return maxValue;
}

- (CGFloat)positionForValue:(double)value {
	return (self.frame.size.width*value) - (8*value);
}

- (void)updateLayerFrames {
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	
	[trackFillLayer setFrame:CGRectMake(0, 11, [self positionForValue:currentValue], 2)];
	[thumbLayer setFrame:CGRectMake([self positionForValue:currentValue], 0, 8, 24)];
	
	[CATransaction commit];
}

- (CGFloat)boundValue:(CGFloat)value {
	return MIN(MAX(value, minValue), maxValue);
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
	CGPoint location = [touch locationInView:self];
	
	if (CGRectContainsPoint(CGRectInset(thumbLayer.frame, -14, 0), location)) {
		return YES;
	}
	
	return NO;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
	CGPoint location = [touch locationInView:self];
	
	currentValue = MIN(MAX(location.x, 0), self.frame.size.width) / self.frame.size.width;
	currentValue = MIN(MAX(currentValue, minValue), maxValue);
	
	[self updateLayerFrames];
	
	[self sendActionsForControlEvents:UIControlEventValueChanged];
	return YES;
}

@end
