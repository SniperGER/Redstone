#import <UIKit/UIKit.h>

@interface SBApplicationController : NSObject

+ (id)sharedInstance;
- (void)uninstallApplication:(id)arg1;
- (id)applicationWithBundleIdentifier:(id)arg1;

@end
