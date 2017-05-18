#import "../Redstone.h"

@implementation RSPinMenu

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		[self setBackgroundColor:[UIColor colorWithWhite:0.18 alpha:1.0]];
		[self.layer setBorderColor:[UIColor colorWithWhite:0.46 alpha:1.0].CGColor];
		[self.layer setBorderWidth:2.0];
		
		self->pinButton = [[RSTiltView alloc] initWithFrame:CGRectMake(0, 14, self.frame.size.width, 66)];
		[self->pinButton setHighlightEnabled:YES];
		UILabel* pinLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, self.frame.size.width - 24, 66)];
		[pinLabel setText:[RSAesthetics localizedStringForKey:@"PIN_TO_START"]];
		[pinLabel setFont:[UIFont fontWithName:@"SegoeUI" size:18]];
		[pinLabel setTextColor:[UIColor whiteColor]];
		[self->pinButton addSubview:pinLabel];
		[self addSubview:self->pinButton];
		
		self->uninstallButton = [[RSTiltView alloc] initWithFrame:CGRectMake(0, 80, self.frame.size.width, 66)];
		[self->uninstallButton setHighlightEnabled:YES];
		UILabel* uninstallLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, self.frame.size.width - 24, 66)];
		[uninstallLabel setText:[RSAesthetics localizedStringForKey:@"UNINSTALL"]];
		[uninstallLabel setFont:[UIFont fontWithName:@"SegoeUI" size:18]];
		[uninstallLabel setTextColor:[UIColor whiteColor]];
		[self->uninstallButton addSubview:uninstallLabel];
		[self addSubview:self->uninstallButton];
		
		UITapGestureRecognizer* pinGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pin)];
		[self->pinButton addGestureRecognizer:pinGestureRecognizer];
		
		UITapGestureRecognizer* uninstallGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(uninstall)];
		[self->uninstallButton addGestureRecognizer:uninstallGestureRecognizer];
	}
	
	return self;
}

- (void)setHandlingApp:(RSApp *)handlingApp {
	self->_handlingApp = handlingApp;
	
	if ([[[RSStartScreenController sharedInstance] pinnedLeafIdentifiers] containsObject:[[[handlingApp icon] application] bundleIdentifier]]) {
		[self->pinButton setAlpha:0.4];
		[self->pinButton setUserInteractionEnabled:NO];
	} else {
		[self->pinButton setAlpha:1.0];
		[self->pinButton setUserInteractionEnabled:YES];
	}
	
	[self->uninstallButton setHidden:![[handlingApp icon] isUninstallSupported]];

}

- (void)pin {
	if (self.handlingApp) {
		[[RSStartScreenController sharedInstance] pinTileWithId:[[[self.handlingApp icon] application] bundleIdentifier]];
	}
}

- (void)uninstall {
	RSModalAlert* alert = [[RSModalAlert alloc] modalAlertWithTitle:[[self.handlingApp icon] uninstallAlertTitle] message:[[self.handlingApp icon] uninstallAlertBody]];
	[alert addActionWithTitle:[[self.handlingApp icon] uninstallAlertConfirmTitle] handler:^{
		[alert hide];
		[[RSAppListController sharedInstance] uninstallApplication:self.handlingApp];
		[[RSAppListController sharedInstance] hidePinMenu];
	}];
	[alert addActionWithTitle:[[self.handlingApp icon] uninstallAlertCancelTitle] handler:^{
		[alert hide];
		[[RSAppListController sharedInstance] hidePinMenu];
	}];
	[alert show];
}
@end
