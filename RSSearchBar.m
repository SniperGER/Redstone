#import "RSSearchBar.h"

@implementation RSSearchBar

-(id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	self.delegate = self;

	self.font = [UIFont fontWithName:@"SegoeUI" size:17];
	self.returnKeyType = UIReturnKeySearch;
	NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"Search" attributes:@{ NSForegroundColorAttributeName:[UIColor colorWithWhite:0.5 alpha:1.0] }];
	self.attributedPlaceholder = str;

	[self.layer setBorderWidth:2.0];
	[self.layer setBorderColor:[UIColor colorWithWhite:0.5 alpha:1.0].CGColor];
	[self setBackgroundColor:[UIColor blackColor]];

	

	return self;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[self.layer setBorderColor:[RSAesthetics accentColor].CGColor];
	[self setBackgroundColor:[UIColor whiteColor]];
	[self setTextColor:[UIColor blackColor]];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[self.layer setBorderColor:[UIColor colorWithWhite:0.5 alpha:1.0].CGColor];
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