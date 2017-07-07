/**
 @class RSLaunchScreenController
 @author Sniper_GER
 @discussion Controls Redstone's Launch Screen window
 */

#import <UIKit/UIKit.h>

@interface RSLaunchScreenController : NSObject {
	//UIWindow* window;
	UIImageView* launchImageView;
	
	UIImageView* applicationSnapshot;
	
	NSTimer* rootTimeout;
}

@property (nonatomic, strong) UIWindow* window;
@property (nonatomic, strong) NSString* launchIdentifier;
@property (nonatomic, assign, readonly) BOOL isLaunchingApp;

/**
 Returns a global instance of \p RSLaunchScreenController
 
 @return A global instance of \p RSLaunchScreenController
 */
+ (id)sharedInstance;

/**
 Fires the Launch Screen animation from the Start Screen to an app
 */
- (void)animateIn;

/**
 Fades out Launch Screen after an app has been loaded
 */
- (void)animateOut;

/**
 Fires the Launch Screen animation from an app to the Start Screen
 */
- (void)animateCurrentApplicationSnapshot;

@end
