/**
 @class RSHomeScreenController
 @author Sniper_GER
 @discussion Controls the Start Screen, App List and App Switcher components of Redstone
 */

#import <UIKit/UIKit.h>

@class RSStartScreenController, RSAppListController, RSHomeScreenScrollView;

@interface RSHomeScreenController : NSObject <UIScrollViewDelegate> {
	RSStartScreenController* startScreenController;
	RSAppListController* appListController;
	
	UIWindow* window;
	RSHomeScreenScrollView* scrollView;
}


/**
 Returns a global instance of \p RSHomeScreenController
 
 @return A global instance of \p RSHomeScreenController
 */
+ (id)sharedInstance;

@end
