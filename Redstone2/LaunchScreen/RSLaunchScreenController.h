/**
 @class RSLaunchScreenController
 @author Sniper_GER
 @discussion Controls Redstone's Launch Screen window
 */

#import <UIKit/UIKit.h>

@interface RSLaunchScreenController : NSObject {
	UIWindow* window;
	UIImageView* launchImageView;
	
	UIImageView* applicationSnapshot;
}

@property (nonatomic, strong) NSString* launchIdentifier;
@property (nonatomic, assign, readonly) BOOL isLaunchingApp;

+ (id)sharedInstance;

- (void)animateIn;

- (void)animateOut;

- (void)animateCurrentApplicationSnapshot;

@end
