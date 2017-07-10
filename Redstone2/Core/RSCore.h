/**
 @class RSCore
 @author Sniper_GER
 @discussion The main class of Redstone controlling every component
 */

#import <UIKit/UIKit.h>

@class RSHomeScreenController, RSLockScreenController, RSNotificationController, RSSoundController, SBApplication;

@interface RSCore : NSObject {
	UIWindow* homeScreenWindow;
	
	RSHomeScreenController* homeScreenController;
	RSLockScreenController* lockScreenController;
	RSNotificationController* notificationController;
	RSSoundController* soundController;
}

/**
 Returns the global RSCore instance because a static instance just isn't enough

 @return A global instance of \p RSCore
 */
+ (id)sharedInstance;

/**
 Initializes Redstone's core component
 
 @param window SBUIController's window
 @return An instance of Redstone
 */
- (id)initWithWindow:(UIWindow*)window;

/**
 Handles a change frontmost application
 @param application The currently frontmost application
 */
- (void)frontDisplayDidChange:(id)application;

/**
 Overrides the default iOS Home button press event to reset various things in Redstone

 @return A boolean value that specifies if the default event can be fired
 */
- (BOOL)handleMenuButtonEvent;

@end
