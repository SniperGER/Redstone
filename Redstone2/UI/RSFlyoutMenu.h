/**
 @class RSFlyoutMenu
 @author Sniper_GER
 @discussion Provides a flyout menu that contains actions
 */

#import <UIKit/UIKit.h>

@interface RSFlyoutMenu : UIView {
	NSMutableArray* actions;
}

- (void)addActionWithTitle:(NSString*)title target:(id)target action:(SEL)action;

@end
