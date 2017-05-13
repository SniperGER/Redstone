#import <UIKit/UIKit.h>

@class RSRootScrollView, RSStartScreenController, RSLaunchScreenController, RSPreferences, RSAppListController;

@interface RSCore : NSObject {
	UIWindow* _window;
	
	RSPreferences* preferences;
	
	RSRootScrollView* _rootScrollView;
	RSStartScreenController* _startScreenController;
	RSLaunchScreenController* _launchScreenController;
	RSAppListController* _appListController;
}

@property (nonatomic, retain) UIWindow* window;
@property (nonatomic, retain) RSRootScrollView* rootScrollView;
@property (nonatomic, retain) RSStartScreenController* startScreenController;
@property (nonatomic, retain) RSLaunchScreenController* launchScreenController;
@property (nonatomic, retain) RSAppListController* appListController;

+ (id)sharedInstance;
+ (void)hideAllExcept:(id)objectToShow;
+ (void)showAllExcept:(id)objectToHide;

- (id)initWithWindow:(id)window;
- (void)frontDisplayDidChange:(UIApplication*)arg1;
- (BOOL)handleMenuButtonEvent;

- (UIImageView*)wallpaperView;
- (id)currentApplication;

@end
