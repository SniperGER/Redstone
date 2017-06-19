#import <UIKit/UIKit.h>

@class SBUIPasscodeLockViewWithKeypad, RSLockScreenPasscodeEntryTextField, RSLockScreenPasscodeEntryView;

@interface RSLockScreenPasscodeEntryController : NSObject <UITextFieldDelegate> {
	RSLockScreenPasscodeEntryTextField* passcodeTextField;
}

@property (nonatomic, strong) SBUIPasscodeLockViewWithKeypad* currentKeypad;
@property (nonatomic, strong) RSLockScreenPasscodeEntryView* passcodeEntryView;

- (void)handlePasscodeTextChanged;
- (void)handleSuccessfulAuthentication;
- (void)handleFailedAuthentication;
- (void)handleFailedMesaAuthentication;
- (void)resetTextField;

@end
