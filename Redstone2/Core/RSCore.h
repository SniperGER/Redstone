/**
 @class RSCore
 @author Sniper_GER
 @discussion The main class of Redstone controlling every component
 */

#import <UIKit/UIKit.h>

@class RSHomeScreenController, RSLockScreenController, RSNotificationController, RSSoundController;

@interface RSCore : NSObject {
	UIWindow* homeScreenWindow;
	
	RSHomeScreenController* homeScreenController;
	RSLockScreenController* lockScreenController;
	RSNotificationController* notificationController;
	RSSoundController* soundController;
}

/**
 Initializes Redstone's core component
 
 @param window SBUIController's window
 @return An instance of Redstone
 */
- (id)initWithWindow:(UIWindow*)window;

@end
