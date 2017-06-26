#import <UIKit/UIKit.h>

@interface RSVolumeSlider : UIControl {
	float minValue;
	float maxValue;
	float currentValue;
	
	CALayer* trackLayer;
	CALayer* trackFillLayer;
	CALayer* thumbLayer;
	
	CGPoint previousLocation;
}

- (float)currentValue;
- (float)minValue;
- (float)maxValue;
- (void)setValue:(float)value;
- (void)setMinValue:(float)value;
- (void)setMaxValue:(float)value;

@end
