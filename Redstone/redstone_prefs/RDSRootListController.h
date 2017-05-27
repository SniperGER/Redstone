#import <Preferences/PSListController.h>

@interface RDSRootListController : PSListController {
	UIWindow* settingsView;
}


- (void)killSpringBoard;
- (void)resetHomeScreenLayout;

@end
