#import <UIKit/UIKit.h>

@class RSApp;

@interface RSPinMenu : UIView {
	UILabel* pinLabel;
	UILabel* uninstallLabel;
}

@property (nonatomic, retain) RSApp* handlingApp;

@end
