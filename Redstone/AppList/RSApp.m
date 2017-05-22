#import "../Redstone.h"

@implementation RSApp

- (id)initWithFrame:(CGRect)frame leafIdentifier:(NSString*)leafId {
	self = [super initWithFrame:frame];
	
	if (self) {
		[self setHighlightEnabled:YES];
		self.icon = [[[objc_getClass("SBIconController") sharedInstance] model] leafIconForIdentifier:leafId];
		
		UIView* tileBackground = [[UIView alloc] initWithFrame:CGRectMake(5, 2, 50, 50)];
		[tileBackground setBackgroundColor:[[RSAesthetics accentColorForTile:leafId] colorWithAlphaComponent:1.0]];
		[self addSubview:tileBackground];
		
		if ([[self getTileInfo] objectForKey:@"FullBleedArtwork"] && [[[self getTileInfo] objectForKey:@"FullBleedArtwork"] boolValue]) {
			appImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
			[appImageView setImage:[RSAesthetics getImageForTileWithBundleIdentifier:[[self.icon application] bundleIdentifier] size:5]];
		} else {
			appImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 37.5, 37.5)];
			[appImageView setCenter:CGPointMake(25, 25)];
			[appImageView setImage:[RSAesthetics getImageForTileWithBundleIdentifier:[[self.icon application] bundleIdentifier]]];
			[appImageView setTintColor:[UIColor whiteColor]];
		}
		[tileBackground addSubview:appImageView];
		
		appLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 0, frame.size.width-70, 54)];
		[appLabel setText:[self.icon displayName]];
		[appLabel setFont:[UIFont fontWithName:@"SegoeUI-Semilight" size:20]];
		[appLabel setTextColor:[UIColor whiteColor]];
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

- (NSDictionary*)getTileInfo {
	NSDictionary* tileInfo = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Tiles/%@/tile.plist", RESOURCE_PATH, [[self.icon application] bundleIdentifier]]];
	
	if (!tileInfo) {
		return [NSDictionary new];
	}
	
	return tileInfo;
}

@end
