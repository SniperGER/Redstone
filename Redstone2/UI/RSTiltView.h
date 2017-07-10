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

/**
 Adds a target and an action to a RSTiltView.

 @param target An object that is a recipient of action messages sent by the receiver when the represented gesture occurs. \p nil is not a valid value.
 @param action A selector identifying a method of a target to be invoked by the action message. \p NULL is not a valid value.
 */
- (void)addTarget:(id)target action:(SEL)action;

@end
