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

- (void)animateIn;

- (void)animateOut;

@end
