#import "../Redstone.h"

@implementation RSPinMenu

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		[self setBackgroundColor:[UIColor colorWithWhite:0.18 alpha:1.0]];
		[self.layer setBorderColor:[UIColor colorWithWhite:0.46 alpha:1.0].CGColor];
		[self.layer setBorderWidth:2.0];
		[self setClipsToBounds:YES];
		
		pinButton = [[RSTiltView alloc] initWithFrame:CGRectMake(0, 14, self.frame.size.width, 66)];
		[pinButton setHighlightEnabled:YES];
		UILabel* pinLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, self.frame.size.width - 24, 66)];
		[pinLabel setText:[RSAesthetics localizedStringForKey:@"PIN_TO_START"]];
		[pinLabel setFont:[UIFont fontWithName:@"SegoeUI" size:18]];
		[pinLabel setTextColor:[UIColor whiteColor]];
		[pinButton addSubview:pinLabel];
		[self addSubview:pinButton];
		
		uninstallButton = [[RSTiltView alloc] initWithFrame:CGRectMake(0, 80, self.frame.size.width, 66)];
		[uninstallButton setHighlightEnabled:YES];
		UILabel* uninstallLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, self.frame.size.width - 24, 66)];
		[uninstallLabel setText:[RSAesthetics localizedStringForKey:@"UNINSTALL"]];
		[uninstallLabel setFont:[UIFont fontWithName:@"SegoeUI" size:18]];
		[uninstallLabel setTextColor:[UIColor whiteColor]];
		[uninstallButton addSubview:uninstallLabel];
		[self addSubview:uninstallButton];
		
		UITapGestureRecognizer* pinGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pin)];
		[pinButton addGestureRecognizer:pinGestureRecognizer];
		
		UITapGestureRecognizer* uninstallGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(uninstall)];
		[uninstallButton addGestureRecognizer:uninstallGestureRecognizer];
	}
	
	return self;
}

- (void)setHandlingApp:(RSApp *)handlingApp {
	_handlingApp = handlingApp;
	
	if ([[[RSStartScreenController sharedInstance] pinnedLeafIdentifiers] containsObject:[[[handlingApp icon] application] bundleIdentifier]]) {
		[pinButton setAlpha:0.4];
		[pinButton setUserInteractionEnabled:NO];
	} else {
		[pinButton setAlpha:1.0];
		[pinButton setUserInteractionEnabled:YES];
	}
	
	[uninstallButton setHidden:![[handlingApp icon] isUninstallSupported]];

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
