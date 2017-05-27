#import <UIKit/UIKit.h>

@class SBUIPasscodeLockViewWithKeypad, RSLockScreenPasscodeEntryTextField, RSLockScreenPasscodeEntryView;

@interface RSLockScreenPasscodeEntryController : NSObject <UITextFieldDelegate> {
	RSLockScreenPasscodeEntryTextField* passcodeTextField;
}

@property (nonatomic, retain) SBUIPasscodeLockViewWithKeypad* currentKeypad;
@property (nonatomic, retain) RSLockScreenPasscodeEntryView* passcodeEntryView;

- (void)handlePasscodeTextChanged;
- (void)handleFailedAuthentication;
- (void)handleFailedMesaAuthentication;
- (void)resetTextField;

@end
