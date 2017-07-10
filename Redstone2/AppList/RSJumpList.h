/**
 @class RSJumpList
 @author Sniper_GER
 @discussion A list view to quickly navigate between App List sections
 */

#import <UIKit/UIKit.h>

@interface RSJumpList : UIView {
	UIScrollView* alphabetScrollView;
}

@property (nonatomic, assign) BOOL isOpen;

/**
 Fires the Jump List animation for showing the Jump List
 */
- (void)animateIn;

/**
 Fires the Jump List animation for hiding the Jump List
 */
- (void)animateOut;

@end
