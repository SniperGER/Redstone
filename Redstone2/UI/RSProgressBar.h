/**
 @class RSProgressBar
 @author Sniper_GER
 @discussion A control that shows the progress of an ongoing process
 */

#import <UIKit/UIKit.h>

@interface RSProgressBar : UIView {
	UIView* progressLayer;
}

- (void)setProgress:(float)progress;

@end
