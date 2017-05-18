#import "../Redstone.h"

@implementation RSSearchBar

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		[self setDelegate:self];
		
		[self setFont:[UIFont fontWithName:@"SegoeUI" size:17]];
		[self setTextColor:[UIColor whiteColor]];
		[self setReturnKeyType:UIReturnKeySearch];
		//[self setPlaceholder:@"Search"];
		[self setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:[RSAesthetics localizedStringForKey:@"SEARCH"] attributes:@{ NSForegroundColorAttributeName:[UIColor colorWithWhite:0.6 alpha:1.0] }]];
		
		[self.layer setBorderWidth:3.0];
		[self.layer setBorderColor:[UIColor colorWithWhite:1.0 alpha:0.4].CGColor];
		[self setBackgroundColor:[UIColor blackColor]];
		[self setKeyboardAppearance:UIKeyboardAppearanceDark];
		[self setAutocorrectionType:UITextAutocorrectionTypeNo];
		[self setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		
		[self addTarget:self action:@selector(searchBarTextChanged) forControlEvents:UIControlEventEditingChanged];
	}
	
	return self;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	//[[RSAppListController sharedInstance] setIsSearching:YES];
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

- (CGRect)editingRectForBounds:(CGRect)bounds {
	return CGRectInset(bounds, 12, 6);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	
	[textField resignFirstResponder];
	return YES;
}

- (void)searchBarTextChanged {
	[[RSAppListController sharedInstance] showAppsFittingQuery:self.text];
}

@end
