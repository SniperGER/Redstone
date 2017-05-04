#import <UIKit/UIKit.h>

@class RSRootScrollView, RSStartScreenController;

@interface RSCore : NSObject {
	UIWindow* _window;
	
	RSRootScrollView* _rootScrollView;
	RSStartScreenController* _startScreenController;
}

@property (nonatomic, retain) RSRootScrollView* rootScrollView;
@property (nonatomic, retain) RSStartScreenController* startScreenController;

+ (id)sharedInstance;
+ (void)hideAllExcept:(id)objectToShow;
+ (void)showAllExcept:(id)objectToHide;

- (id)initWithWindow:(id)window;

@end
