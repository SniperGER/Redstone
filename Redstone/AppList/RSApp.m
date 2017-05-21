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
			self->appImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
			[self->appImageView setImage:[RSAesthetics getImageForTileWithBundleIdentifier:[[self.icon application] bundleIdentifier] size:5]];
		} else {
			self->appImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 37.5, 37.5)];
			[self->appImageView setCenter:CGPointMake(25, 25)];
			[self->appImageView setImage:[RSAesthetics getImageForTileWithBundleIdentifier:[[self.icon application] bundleIdentifier]]];
			[self->appImageView setTintColor:[UIColor whiteColor]];
		}
		[tileBackground addSubview:self->appImageView];
		
		self->appLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 0, frame.size.width-70, 54)];
		[self->appLabel setText:[self.icon displayName]];
		[self->appLabel setFont:[UIFont fontWithName:@"SegoeUI-Semilight" size:20]];
		[self->appLabel setTextColor:[UIColor whiteColor]];
		[self addSubview:self->appLabel];
		
		self->tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
		[self->tapGestureRecognizer setCancelsTouchesInView:NO];
		[self->tapGestureRecognizer setDelegate:self];
		[self addGestureRecognizer:self->tapGestureRecognizer];
		
		self->longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressed:)];
		[self->longPressGestureRecognizer setCancelsTouchesInView:NO];
		[self->longPressGestureRecognizer setDelegate:self];
		[self addGestureRecognizer:self->longPressGestureRecognizer];
		
		[self->tapGestureRecognizer requireGestureRecognizerToFail:self->longPressGestureRecognizer];
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
