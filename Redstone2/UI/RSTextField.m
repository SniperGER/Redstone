#import "../Redstone.h"

@implementation RSTextField

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self setDelegate:self];
		
		[self setBackgroundColor:[RSAesthetics colorsForCurrentTheme][@"TextFieldBackgroundColor"]];
		[self setFont:[UIFont fontWithName:@"SegoeUI" size:17]];
		[self setTextColor:[RSAesthetics colorsForCurrentTheme][@"ForegroundColor"]];
		
		[self.layer setBorderWidth:2];
		[self.layer setBorderColor:[[RSAesthetics colorsForCurrentTheme][@"BorderColor"] CGColor]];
		
		clearButton = [[RSTiltView alloc] initWithFrame:CGRectMake(self.frame.size.width - 40, 0, 40, self.frame.size.height)];
		[clearButton.titleLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:14]];
		[clearButton.titleLabel setText:@"\uE71E"];
		[clearButton.titleLabel setTextColor:[[RSAesthetics colorsForCurrentTheme][@"TextFieldPlaceholderColor"] colorWithAlphaComponent:0.4]];
		[clearButton addTarget:self action:@selector(clearTextField:)];
		[clearButton setTiltEnabled:NO];
		[clearButton setHighlightEnabled:YES];
		[clearButton setColoredHighlight:YES];
		[self setRightViewMode:UITextFieldViewModeAlways];
		[self setRightView:clearButton];
		
		[self setReturnKeyType:UIReturnKeySearch];
		[self setKeyboardAppearance:UIKeyboardAppearanceDark];
		[self setAutocorrectionType:UITextAutocorrectionTypeNo];
		[self setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		
		[self addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
	}
	
	return self;
}

- (void)clearTextField:(UITapGestureRecognizer*)gestureRecognizer {
	[self becomeFirstResponder];
	[self setText:@""];
	[self sendActionsForControlEvents:UIControlEventEditingChanged];
}

- (void)setPlaceholder:(NSString *)placeholder {
	[self setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:placeholder attributes:@{ NSForegroundColorAttributeName:[RSAesthetics colorsForCurrentTheme][@"TextFieldPlaceholderColor"] }]];
}

- (void)textFieldDidChange:(UITextField*)textField {
	if ([self.text isEqualToString:@""] || self.text == nil) {
		[clearButton.titleLabel setText:@"\uE71E"];
	} else {
		[clearButton.titleLabel setText:@"\uE894"];
	}
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[self.layer setBorderColor:[RSAesthetics accentColor].CGColor];
	[self setBackgroundColor:[UIColor whiteColor]];
	[self setTextColor:[UIColor blackColor]];
	
	[clearButton.titleLabel setTextColor:[RSAesthetics colorsForCurrentTheme][@"TextFieldPlaceholderColor"]];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[self.layer setBorderColor:[[RSAesthetics colorsForCurrentTheme][@"BorderColor"] CGColor]];
	[self setBackgroundColor:[RSAesthetics colorsForCurrentTheme][@"TextFieldBackgroundColor"]];
	[self setTextColor:[RSAesthetics colorsForCurrentTheme][@"ForegroundColor"]];
	
	[clearButton.titleLabel setTextColor:[[RSAesthetics colorsForCurrentTheme][@"TextFieldPlaceholderColor"] colorWithAlphaComponent:0.4]];
}

- (CGRect)textRectForBounds:(CGRect)bounds {
	return CGRectInset(bounds, 12, 6);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
	return CGRectInset(bounds, 12, 6);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	
	[textField resignFirstResponder];
	return YES;
}

@end
