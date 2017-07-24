/**
 @class RSHomeScreenController
 @author Sniper_GER
 @discussion A class that controls Redstone's App Switcher component
 */

#import <UIKit/UIKit.h>

@class RSAppSwitcherContainerView, RSAppSwitcherScrollView;

@interface RSAppSwitcherController : NSObject {
	RSAppSwitcherContainerView* containerView;
	RSAppSwitcherScrollView* scrollView;
	
	UIImageView* homeScreenImageView;
}

@property (nonatomic, strong) UIWindow* window;

- (void)setHomeScreenView:(UIView*)view;

@end
