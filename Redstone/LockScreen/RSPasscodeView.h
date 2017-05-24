#import <UIKit/UIKit.h>

@interface RSPasscodeView : UIView <UITextFieldDelegate> {
	UITextField* passcodeTextField;
}

- (void)resetPasscodeTextField;

@end
