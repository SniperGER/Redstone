#import "../Redstone.h"

@implementation RSLockScreenPasscodeEntryController

- (id)init {
	self = [super init];
	
	if (self) {
		self.passcodeEntryView = [[RSLockScreenPasscodeEntryView alloc] initWithFrame:CGRectMake(0, screenHeight*2 - 382, screenWidth, 382)];
		
		passcodeTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 55)];
		[passcodeTextField setDelegate:self];
		[passcodeTextField setFont:[UIFont fontWithName:@"SegoeUI" size:28]];
		[passcodeTextField setTextColor:[UIColor whiteColor]];
		[passcodeTextField setTextAlignment:NSTextAlignmentCenter];
		[passcodeTextField setSecureTextEntry:YES];
		[passcodeTextField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:[RSAesthetics localizedStringForKey:@"PASSCODE_ENTER_PIN"] attributes:@{ NSForegroundColorAttributeName:[UIColor colorWithWhite:1.0 alpha:1.0], NSFontAttributeName:[UIFont fontWithName:@"SegoeUI" size:18] }]];
		[self.passcodeEntryView addSubview:passcodeTextField];
	}
	
	return self;
}

- (void)handlePasscodeTextChanged {
	[passcodeTextField setText:[self.currentKeypad passcode]];
}

- (void)resetTextField {
	[passcodeTextField setText:nil];
}

@end
