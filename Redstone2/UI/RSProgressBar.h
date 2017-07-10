/**
 @class RSProgressBar
 @author Sniper_GER
 @discussion A control that shows the progress of an ongoing process
 */

#import <UIKit/UIKit.h>

@interface RSProgressBar : UIView {
	UIView* progressLayer;
}

/**
 Sets the progress of a progress bar

 @param progress The progress to be shown on a progress bar. A float between 0 and 1
 */
- (void)setProgress:(float)progress;

@end
