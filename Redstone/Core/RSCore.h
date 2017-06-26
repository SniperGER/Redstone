#import <UIKit/UIKit.h>

@class RSLockScreenController, RSRootScrollView, RSStartScreenController, RSLaunchScreenController, RSPreferences, RSAppListController, RSNotificationController, RSSoundController, RSNotificationView, SBUIPasscodeLockViewWithKeypad, SpringBoard;

@interface RSCore : NSObject {
	RSPreferences* preferences;
	
	RSNotificationView* currentNotification;
	NSTimer* hideNotificationTimer;
}

@property (nonatomic, strong) UIWindow* window;
@property (nonatomic, strong) RSLockScreenController* lockScreenController;
@property (nonatomic, strong) RSRootScrollView* rootScrollView;
@property (nonatomic, strong) RSStartScreenController* startScreenController;
@property (nonatomic, strong) RSLaunchScreenController* launchScreenController;
@property (nonatomic, strong) RSAppListController* appListController;
@property (nonatomic, strong) RSNotificationController* notificationController;
@property (nonatomic, strong) RSSoundController* soundController;
@property (nonatomic, strong) UIWindow* notificationWindow;
@property (nonatomic, strong) SpringBoard* sharedSpringBoard;

@property (nonatomic, strong) SBUIPasscodeLockViewWithKeypad* lockKeypad;

+ (id)sharedInstance;
+ (void)hideAllExcept:(id)objectToShow;
+ (void)showAllExcept:(id)objectToHide;

- (id)initWithWindow:(id)window;
- (void)frontDisplayDidChange:(UIApplication*)arg1;
- (BOOL)handleMenuButtonEvent;

- (UIImageView*)wallpaperView;
- (void)updateWallpaper;
- (id)currentApplication;

@end
