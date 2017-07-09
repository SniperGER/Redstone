/**
 @class RSFlyoutMenu
 @author Sniper_GER
 @discussion Provides a flyout menu that contains actions
 */

#import <UIKit/UIKit.h>

@interface RSFlyoutMenu : UIView {
	NSMutableArray* actions;
}

@property (nonatomic, assign) BOOL isOpen;

/**
 Updates the Flyout's size based on visible action count
 */
- (void)updateFlyoutSize;

/**
 Adds a new action to the Flyout
 
 @param title The displayed text for the action
 @param target The object that performs the action
 @param action The action you want to execute
 */
- (void)addActionWithTitle:(NSString*)title target:(id)target action:(SEL)action;

/**
 Sets an action's visibility
 
 @param hidden Sets the visibility state
 @param index The index of the action based on the order you added actions
 */
- (void)setActionHidden:(BOOL)hidden atIndex:(NSInteger)index;

/**
 Sets an action's disabled state
 
 @param disabled Sets the disabled state
 @param index The index of the action based on the order you added actions
 */
- (void)setActionDisabled:(BOOL)disabled atIndex:(NSInteger)index;

/**
 Let's the Flyout appear at the specified position
 
 @param position The position to let the Flyout appear at, based on touch locations and frame origins
 */
- (void)appearAtPosition:(CGPoint)position;

/**
 Hides the Flyout
 */
- (void)disappear;

@end
