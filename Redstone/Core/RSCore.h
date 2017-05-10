#import <UIKit/UIKit.h>

@class RSRootScrollView, RSStartScreenController, RSLaunchScreenController;

@interface RSCore : NSObject {
	UIWindow* _window;
	
	RSRootScrollView* _rootScrollView;
	RSStartScreenController* _startScreenController;
	RSLaunchScreenController* _launchScreenController;
}

@property (nonatomic, retain) RSRootScrollView* rootScrollView;
@property (nonatomic, retain) RSStartScreenController* startScreenController;
@property (nonatomic, retain) RSLaunchScreenController* launchScreenController;

+ (id)sharedInstance;
+ (void)hideAllExcept:(id)objectToShow;
+ (void)showAllExcept:(id)objectToHide;

- (id)initWithWindow:(id)window;
- (void)frontDisplayDidChange:(UIApplication*)arg1;

@end
