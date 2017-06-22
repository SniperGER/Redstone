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

- (void)setValue:(float)value;
- (float)value;
- (void)setMinValue:(float)value;
- (float)minValue;
- (void)setMaxValue:(float)value;
- (float)maxValue;

@end
