#import "../Redstone.h"

@implementation RSLockScreenPasscodeEntryController

- (id)init {
	self = [super init];
	
	if (self) {
		self.passcodeEntryView = [[RSLockScreenPasscodeEntryView alloc] initWithFrame:CGRectMake(0, screenHeight*2 - 382, screenWidth, 382)];
		
		passcodeTextField = [[RSLockScreenPasscodeEntryTextField alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 55)];
		[self.passcodeEntryView addSubview:passcodeTextField];
	}
	
	return self;
}

- (void)handlePasscodeTextChanged {
	[passcodeTextField setText:[self.currentKeypad passcode]];
}

- (void)handleSuccessfulAuthentication {
	RSLockScreenController* lockScreenController = [RSLockScreenController sharedInstance];
	if (lockScreenController.completionHandler != nil) {
		lockScreenController.completionHandler();
		
		lockScreenController.completionHandler = nil;
	}
}

- (void)handleFailedAuthentication {
	[self resetTextField];
	[passcodeTextField showInvalidPIN];
}

- (void)handleFailedMesaAuthentication {
	[self resetTextField];
	[passcodeTextField showInvalidMesa];
}

- (void)resetTextField {
	[passcodeTextField setText:nil];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	return NO;
}

@end
