#import "RSApp.h"
#import "RSAesthetics.h"
#import "RSAppListController.h"
#import "RSLaunchScreenController.h"

@implementation RSApp

-(id)initWithFrame:(CGRect)frame leafId:(NSString*)identifier {
	self = [super initWithFrame:frame];
	
	if (self) {
		_transformMultiplierX = 0.25;
		_hasHighlight = YES;
		_keepsHighlightOnLongPress = YES;
		
		self->appIcon = [[[objc_getClass("SBIconController") sharedInstance] model] leafIconForIdentifier:identifier];
		self->leafIdentifier = identifier;
		self->displayName = [self->appIcon displayName];

		self->appTileView = [[UIView alloc] initWithFrame:CGRectMake(2,2,50,50)];
		[self->appTileView setBackgroundColor:[RSAesthetics accentColor]];
		[self addSubview:self->appTileView];

		self->appName = [[UILabel alloc] initWithFrame:CGRectMake(64, 2, self.frame.size.width-54, 50)];
		[self->appName setText:[self displayName]];
		[self->appName setFont:[UIFont fontWithName:@"SegoeUI-Semilight" size:20]];
		[self->appName setTextColor:[UIColor whiteColor]];
		[self->appName setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.0]];

		[self addSubview:self->appName];

		UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
		[tap setCancelsTouchesInView:NO];
		[self addGestureRecognizer:tap];
		
		UILongPressGestureRecognizer* press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressed:)];
		[press setCancelsTouchesInView:NO];
		[self addGestureRecognizer:press];
	}
	
	return self;
}

#pragma clang diagnostic ignored "-Wnonnull"
-(void)tapped:(id)sender {
	[self setHighlighted:NO];
	[[RSAppListController sharedInstance] textFieldShouldReturn:nil];
	[[RSAppListController sharedInstance] prepareForAppLaunch:self];
	//[[RSLaunchScreenController sharedInstance] setLaunchScreenForLeafIdentifier:self->leafIdentifier];
	//[[objc_getClass("SBIconController") sharedInstance] _launchIcon:self->appIcon];
}
-(void)pressed:(UILongPressGestureRecognizer*)sender {
	if (sender.state == UIGestureRecognizerStateBegan) {
		[self untilt:YES];
		[[RSAppListController sharedInstance] showPinMenuForApp:self];
		AudioServicesPlaySystemSound(1520);
	}
}

-(NSString *)displayName {
	return self->displayName;
}
-(NSString *)leafIdentifier {
	return self->leafIdentifier;
}
-(SBIcon*)appIcon {
	return self->appIcon;
}

-(void)updateTileColor {
	[self->appTileView setBackgroundColor:[RSAesthetics accentColorForApp:self->leafIdentifier]];
}

@end