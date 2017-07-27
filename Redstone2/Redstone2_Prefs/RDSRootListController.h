#import <Preferences/PSListController.h>

@interface RDSRootListController : PSListController {
	UIWindow* settingsView;
}

- (void)donate;

- (void)killSpringBoard;
- (void)resetHomeScreenLayout;

@end
