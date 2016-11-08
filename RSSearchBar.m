#import "RSSearchBar.h"
#import "RSAesthetics.h"
#import "RSAppListController.h"

@implementation RSSearchBar

-(id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	self.delegate = self;

	self.font = [UIFont fontWithName:@"SegoeUI" size:17];
	self.textColor = [UIColor whiteColor];
	self.returnKeyType = UIReturnKeySearch;
	NSAttributedString *str = [[NSAttributedString alloc] initWithString:[RSAesthetics localizedStringForKey:@"SEARCH"] attributes:@{ NSForegroundColorAttributeName:[UIColor colorWithWhite:0.5 alpha:1.0] }];
	self.attributedPlaceholder = str;

	[self.layer setBorderWidth:3.0];
	[self.layer setBorderColor:[UIColor colorWithWhite:1.0 alpha:0.4].CGColor];
	[self setBackgroundColor:[UIColor blackColor]];
	self.keyboardAppearance = UIKeyboardAppearanceDark;
	

	return self;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[[RSAppListController sharedInstance] setIsSearching:YES];
	[self.layer setBorderColor:[RSAesthetics accentColor].CGColor];
	[self setBackgroundColor:[UIColor whiteColor]];
	[self setTextColor:[UIColor blackColor]];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	//[[RSAppListController sharedInstance] setIsSearching:NO];
	[self.layer setBorderColor:[UIColor colorWithWhite:1.0 alpha:0.4].CGColor];
	[self setBackgroundColor:[UIColor blackColor]];
	[self setTextColor:[UIColor whiteColor]];
}

- (CGRect)textRectForBounds:(CGRect)bounds {
     return CGRectInset(bounds, 12, 6);
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
     return CGRectInset(bounds, 12, 6);
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{

    [textField resignFirstResponder];
    return YES;
}

@end