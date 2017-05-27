#import "../Redstone.h"

@implementation RSLockScreenPasscodeEntryTextField

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		[self setDelegate:self];
		[self setBackgroundColor:[UIColor clearColor]];
		[self setFont:[UIFont fontWithName:@"SegoeUI" size:28]];
		[self setTextColor:[UIColor whiteColor]];
		[self setTextAlignment:NSTextAlignmentCenter];
		[self setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
		[self setSecureTextEntry:YES];
		[self setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:[RSAesthetics localizedStringForKey:@"PASSCODE_ENTER_PIN"] attributes:@{ NSForegroundColorAttributeName:[UIColor colorWithWhite:1.0 alpha:1.0], NSFontAttributeName:[UIFont fontWithName:@"SegoeUI" size:18] }]];
	}
	
	return self;
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
	return CGRectMake(0, 7.5, screenWidth, 40);
}

- (void)showInvalidPIN {
	[self setBackgroundColor:[RSAesthetics accentColor]];
	[self setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:[RSAesthetics localizedStringForKey:@"PASSCODE_INVALID_PIN"] attributes:@{ NSForegroundColorAttributeName:[UIColor colorWithWhite:1.0 alpha:1.0], NSFontAttributeName:[UIFont fontWithName:@"SegoeUI" size:18] }]];
	[self.superview setUserInteractionEnabled:NO];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self setBackgroundColor:[UIColor clearColor]];
		[self setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:[RSAesthetics localizedStringForKey:@"PASSCODE_ENTER_PIN"] attributes:@{ NSForegroundColorAttributeName:[UIColor colorWithWhite:1.0 alpha:1.0], NSFontAttributeName:[UIFont fontWithName:@"SegoeUI" size:18] }]];
		[self.superview setUserInteractionEnabled:YES];
	});
}

- (void)showInvalidMesa {
	[self setBackgroundColor:[RSAesthetics accentColor]];
	[self setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:[RSAesthetics localizedStringForKey:@"PASSCODE_INVALID_MESA"] attributes:@{ NSForegroundColorAttributeName:[UIColor colorWithWhite:1.0 alpha:1.0], NSFontAttributeName:[UIFont fontWithName:@"SegoeUI" size:18] }]];
	[self.superview setUserInteractionEnabled:NO];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self setBackgroundColor:[UIColor clearColor]];
		[self setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:[RSAesthetics localizedStringForKey:@"PASSCODE_ENTER_PIN"] attributes:@{ NSForegroundColorAttributeName:[UIColor colorWithWhite:1.0 alpha:1.0], NSFontAttributeName:[UIFont fontWithName:@"SegoeUI" size:18] }]];
		[self.superview setUserInteractionEnabled:YES];
	});
}

@end
