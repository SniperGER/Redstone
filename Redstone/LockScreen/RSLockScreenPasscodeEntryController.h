#import <UIKit/UIKit.h>

@class SBUIPasscodeLockViewWithKeypad, RSLockScreenPasscodeEntryView;

@interface RSLockScreenPasscodeEntryController : NSObject <UITextFieldDelegate> {
	UITextField* passcodeTextField;
}

@property (nonatomic, retain) SBUIPasscodeLockViewWithKeypad* currentKeypad;
@property (nonatomic, retain) RSLockScreenPasscodeEntryView* passcodeEntryView;

- (void)handlePasscodeTextChanged;
- (void)resetTextField;

@end
