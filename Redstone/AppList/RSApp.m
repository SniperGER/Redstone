#import "../Redstone.h"

@implementation RSApp

- (id)initWithFrame:(CGRect)frame leafIdentifier:(NSString*)leafId {
	self = [super initWithFrame:frame];
	
	if (self) {
		[self setHighlightEnabled:YES];
		self.icon = [[[objc_getClass("SBIconController") sharedInstance] model] leafIconForIdentifier:leafId];
		self.iconIdentifier = [[self.icon application] bundleIdentifier];
		self.tileInfo = [[RSTileInfo alloc] initWithBundleIdentifier:leafId];
		
		UIView* tileBackground = [[UIView alloc] initWithFrame:CGRectMake(5, 2, 50, 50)];
		[tileBackground setBackgroundColor:[[RSAesthetics accentColorForTile:self.tileInfo] colorWithAlphaComponent:1.0]];
		[self addSubview:tileBackground];
		
		if (self.tileInfo.fullSizeArtwork) {
			appImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
			[appImageView setImage:[RSAesthetics getImageForTileWithBundleIdentifier:[[self.icon application] bundleIdentifier] size:5 colored:YES]];
		} else {
			appImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 37.5, 37.5)];
			[appImageView setCenter:CGPointMake(25, 25)];
			[appImageView setImage:[RSAesthetics getImageForTileWithBundleIdentifier:[[self.icon application] bundleIdentifier] size:5 colored:self.tileInfo.hasColoredIcon]];
			[appImageView setTintColor:[UIColor whiteColor]];
		}
		[tileBackground addSubview:appImageView];
		
		appLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 0, frame.size.width-70, 54)];
		[appLabel setFont:[UIFont fontWithName:@"SegoeUI-Semilight" size:20]];
		[appLabel setTextColor:[UIColor whiteColor]];
		
		if (self.tileInfo.localizedDisplayName) {
			[appLabel setText:self.tileInfo.localizedDisplayName];
		} else if (self.tileInfo.displayName) {
			[appLabel setText:self.tileInfo.displayName];
		} else {
			[appLabel setText:[self.icon displayName]];
		}
		
		[self addSubview:appLabel];
		
		tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
		[tapGestureRecognizer setCancelsTouchesInView:NO];
		[tapGestureRecognizer setDelegate:self];
		[self addGestureRecognizer:tapGestureRecognizer];
		
		longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressed:)];
		[longPressGestureRecognizer setCancelsTouchesInView:NO];
		[longPressGestureRecognizer setDelegate:self];
		[self addGestureRecognizer:longPressGestureRecognizer];
		
		[tapGestureRecognizer requireGestureRecognizerToFail:longPressGestureRecognizer];
	}
	
	return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	return YES;
}

- (void)tapped:(UITapGestureRecognizer*)gestureRecognizer {
	if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
		[self untilt];
		[[RSAppListController sharedInstance] prepareForAppLaunch:self];
	}
}

- (void)pressed:(UILongPressGestureRecognizer*)gestureRecognizer {
	if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
		[self untilt];
		[[RSAppListController sharedInstance] showPinMenuForApp:self];
	}
}

@end
