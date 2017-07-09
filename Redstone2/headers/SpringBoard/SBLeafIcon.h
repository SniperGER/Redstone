#import <UIKit/UIKit.h>

@interface SBLeafIcon : NSObject

- (NSString*)applicationBundleID;
- (NSString*)displayName;
- (NSString*)realDisplayName;
- (id)application;
- (BOOL)isUninstallSupported;
- (id)getUnmaskedIconImage:(int)arg1;
- (void)setUninstalled;
- (void)completeUninstall;
- (id)uninstallAlertTitle;
- (id)uninstallAlertBody;
- (id)uninstallAlertConfirmTitle;
- (id)uninstallAlertCancelTitle;

@end
