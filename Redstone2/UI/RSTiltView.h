/**
 @class RSTiltView
 @author Sniper_GER
 @discussion A view that tilts when being touched
 */

#import <UIKit/UIKit.h>

@interface RSTiltView : UIView {
	CALayer* highlightLayer;
	BOOL isTilted;
	BOOL isHighlighted;
}

@property (nonatomic, assign) BOOL tiltEnabled;
@property (nonatomic, assign) BOOL highlightEnabled;
@property (nonatomic, assign) BOOL coloredHighlight;
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, assign) BOOL isButton;

/**
 Removes transform and highlight of a tilted view
 */
- (void)untilt;

- (void)addTarget:(id)target action:(SEL)action;

@end
