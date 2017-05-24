#import "../Redstone.h"

@implementation RSPasscodeView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		passcodeTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 55)];
		[passcodeTextField setDelegate:self];
		[passcodeTextField setFont:[UIFont fontWithName:@"SegoeUI" size:28]];
		[passcodeTextField setTextColor:[UIColor whiteColor]];
		[passcodeTextField setTextAlignment:NSTextAlignmentCenter];
		[passcodeTextField setSecureTextEntry:YES];
		[passcodeTextField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:[RSAesthetics localizedStringForKey:@"PASSCODE_ENTER_PIN"] attributes:@{ NSForegroundColorAttributeName:[UIColor colorWithWhite:1.0 alpha:1.0], NSFontAttributeName:[UIFont fontWithName:@"SegoeUI" size:18] }]];
		[self addSubview:passcodeTextField];
		
		CGSize buttonSize = CGSizeMake([RSMetrics tileDimensionsForSize:2].width, [RSMetrics tileDimensionsForSize:1].height);
		NSString* passcodeLabels = @"123456789>0<";
		for (int i=0; i<4; i++) {
			for (int j=0; j<3; j++) {
				int index = ((i * 3) + (j + 1)) - 1;
				
				if (![[passcodeLabels substringWithRange:NSMakeRange(index, 1)] isEqualToString:@" "]) {
					/*UIView* button = [[UIView alloc] initWithFrame:CGRectMake(4 + (buttonSize.width+[RSMetrics tileBorderSpacing])*j,
																			  55 + (buttonSize.height+[RSMetrics tileBorderSpacing])*i,
																			  buttonSize.width, buttonSize.height)];
					[button setBackgroundColor:[RSAesthetics accentColor]];
					[self addSubview:button];*/
					
					RSPasscodeButton* button = [[RSPasscodeButton alloc] initWithFrame:CGRectMake(4 + (buttonSize.width+[RSMetrics tileBorderSpacing])*j,
																								  55 + (buttonSize.height+[RSMetrics tileBorderSpacing])*i,
																								  buttonSize.width, buttonSize.height)];
					UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(passcodeButtonTapped:)];
					[tap setDelaysTouchesBegan:NO];
					[tap setCancelsTouchesInView:NO];
					[button addGestureRecognizer:tap];
					
					[self addSubview:button];
					
					if ([[passcodeLabels substringWithRange:NSMakeRange(index, 1)] isEqualToString:@">"]) {
						[button setIsReturnButton:YES];
					} else if ([[passcodeLabels substringWithRange:NSMakeRange(index, 1)] isEqualToString:@"<"]) {
						[button setIsBackspaceButton:YES];
					} else {
						[button setButtonLabel:[passcodeLabels substringWithRange:NSMakeRange(index, 1)]];
					}
				}
			}
		}
	}
	
	return self;
}

- (void)passcodeButtonTapped:(UITapGestureRecognizer*)recognizer {
	if ([(RSPasscodeButton*)recognizer.view isReturnButton]) {
		[[objc_getClass("SBLockScreenManager") sharedInstance] _attemptUnlockWithPasscode:passcodeTextField.text finishUIUnlock:YES];
	} else if ([(RSPasscodeButton*)recognizer.view isBackspaceButton]) {
		[passcodeTextField setText:[NSString stringWithFormat:@"%@", [passcodeTextField.text substringWithRange:NSMakeRange(0, MIN(MAX(0, passcodeTextField.text.length-1), passcodeTextField.text.length))]]];
	} else {
		[passcodeTextField setText:[NSString stringWithFormat:@"%@%@", passcodeTextField.text, [(RSPasscodeButton*)recognizer.view buttonLabel]]];
	}
	
	[recognizer.view setBackgroundColor:[UIColor clearColor]];
}

- (void)resetPasscodeTextField {
	[passcodeTextField setText:nil];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	return NO;
}

@end
