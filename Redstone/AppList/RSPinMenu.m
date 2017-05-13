#import "../Redstone.h"

@implementation RSPinMenu

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		[self setBackgroundColor:[UIColor colorWithWhite:0.18 alpha:1.0]];
		[self.layer setBorderColor:[UIColor colorWithWhite:0.46 alpha:1.0].CGColor];
		[self.layer setBorderWidth:2.0];
		
		self->pinLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 14, self.frame.size.width-24, 66)];
		[self->pinLabel setText:@"PIN_TO_START"];
		[self->pinLabel setFont:[UIFont fontWithName:@"SegoeUI" size:18]];
		[self->pinLabel setTextColor:[UIColor whiteColor]];
		[self->pinLabel setUserInteractionEnabled:YES];
		[self addSubview:self->pinLabel];
		
		self->uninstallLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 80, self.frame.size.width-24, 66)];
		[self->uninstallLabel setText:@"UNINSTALL"];
		[self->uninstallLabel setFont:[UIFont fontWithName:@"SegoeUI" size:18]];
		[self->uninstallLabel setTextColor:[UIColor whiteColor]];
		[self->uninstallLabel setUserInteractionEnabled:NO];
		[self->uninstallLabel setAlpha:0.4];
		[self addSubview:self->uninstallLabel];
		
		UITapGestureRecognizer* pinGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pin)];
		[self->pinLabel addGestureRecognizer:pinGestureRecognizer];
	}
	
	return self;
}

- (void)setHandlingApp:(RSApp *)handlingApp {
	self->_handlingApp = handlingApp;
	
	if ([[[RSStartScreenController sharedInstance] pinnedLeafIdentifiers] containsObject:[[[handlingApp icon] application] bundleIdentifier]]) {
		[self->pinLabel setAlpha:0.4];
		[self->pinLabel setUserInteractionEnabled:NO];
	} else {
		[self->pinLabel setAlpha:1.0];
		[self->pinLabel setUserInteractionEnabled:YES];
	}
	
	[self->uninstallLabel setHidden:![[handlingApp icon] isUninstallSupported]];

}

- (void)pin {
	if (self.handlingApp) {
		[[RSStartScreenController sharedInstance] pinTileWithId:[[[self.handlingApp icon] application] bundleIdentifier]];
	}
}

@end
