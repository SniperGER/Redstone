#import <UIKit/UIKit.h>

@class RSLockScreenController, RSRootScrollView, RSStartScreenController, RSLaunchScreenController, RSPreferences, RSAppListController, RSNotificationView, SBUIPasscodeLockViewWithKeypad;

@interface RSCore : NSObject {
	RSPreferences* preferences;
	
	RSNotificationView* currentNotification;
	NSTimer* hideNotificationTimer;
}

@property (nonatomic, retain) UIWindow* window;
@property (nonatomic, retain) RSLockScreenController* lockScreenController;
@property (nonatomic, retain) RSRootScrollView* rootScrollView;
@property (nonatomic, retain) RSStartScreenController* startScreenController;
@property (nonatomic, retain) RSLaunchScreenController* launchScreenController;
@property (nonatomic, retain) RSAppListController* appListController;
@property (nonatomic, retain) UIWindow* notificationWindow;

@property (nonatomic, retain) SBUIPasscodeLockViewWithKeypad* lockKeypad;

+ (id)sharedInstance;
+ (void)hideAllExcept:(id)objectToShow;
+ (void)showAllExcept:(id)objectToHide;

- (id)initWithWindow:(id)window;
- (void)frontDisplayDidChange:(UIApplication*)arg1;
- (BOOL)handleMenuButtonEvent;

- (UIImageView*)wallpaperView;
- (id)currentApplication;

@end
