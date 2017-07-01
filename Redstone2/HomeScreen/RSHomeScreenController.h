/**
 @class RSHomeScreenController
 @author Sniper_GER
 @discussion Controls the Start Screen, App List and App Switcher components of Redstone
 */

#import <UIKit/UIKit.h>

@class RSStartScreenController, RSAppListController, RSLaunchScreenController, RSHomeScreenScrollView;

@interface RSHomeScreenController : NSObject <UIScrollViewDelegate> {
	RSStartScreenController* startScreenController;
	RSAppListController* appListController;
	RSLaunchScreenController* launchScreenController;
	
	UIWindow* window;
	UIImageView* wallpaperView;
	RSHomeScreenScrollView* scrollView;
}

/**
 Returns a global instance of \p RSHomeScreenController
 
 @return A global instance of \p RSHomeScreenController
 */
+ (id)sharedInstance;

- (void)setParallaxPosition;

/**
 Enables or disables the scrolling behavior of the Home Screen Controller scroll view

 @param scrollEnabled The desired scrolling state
 */
- (void)setScrollEnabled:(BOOL)scrollEnabled;

@end
