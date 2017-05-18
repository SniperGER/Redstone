#import <UIKit/UIKit.h>

@class RSApp, RSTiltView;

@interface RSPinMenu : UIView {
	RSTiltView* pinButton;
	RSTiltView* uninstallButton;
}

@property (nonatomic, retain) RSApp* handlingApp;

@end
