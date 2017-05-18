#import "../Redstone.h"

@implementation RSApp

- (id)initWithFrame:(CGRect)frame leafIdentifier:(NSString*)leafId {
	self = [super initWithFrame:frame];
	
	if (self) {
		self.icon = [[[objc_getClass("SBIconController") sharedInstance] model] leafIconForIdentifier:leafId];
		
		UIView* tileBackground = [[UIView alloc] initWithFrame:CGRectMake(5, 2, 50, 50)];
		[tileBackground setBackgroundColor:[RSAesthetics accentColorForTile:leafId]];
		[self addSubview:tileBackground];
		
		self->appImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 37.5, 37.5)];
		[self->appImageView setCenter:CGPointMake(25, 25)];
		[self->appImageView setImage:[RSAesthetics getImageForTileWithBundleIdentifier:[[self.icon application] bundleIdentifier]]];
		[self->appImageView setTintColor:[UIColor whiteColor]];
		[tileBackground addSubview:self->appImageView];
		
		self->appLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 0, frame.size.width-70, 54)];
		[self->appLabel setText:[self.icon displayName]];
		[self->appLabel setFont:[UIFont fontWithName:@"SegoeUI-Semilight" size:20]];
		[self->appLabel setTextColor:[UIColor whiteColor]];
		[self addSubview:self->appLabel];
		
		self->tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
		[self addGestureRecognizer:self->tapGestureRecognizer];
		
		self->longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressed:)];
		[self addGestureRecognizer:self->longPressGestureRecognizer];
		
		[self->tapGestureRecognizer requireGestureRecognizerToFail:self->longPressGestureRecognizer];
	}
	
	return self;
}

- (void)tapped:(UITapGestureRecognizer*)gestureRecognizer {
	[[RSAppListController sharedInstance] prepareForAppLaunch:self];
}

- (void)pressed:(UILongPressGestureRecognizer*)gestureRecognizer {
	if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
		[[RSAppListController sharedInstance] showPinMenuForApp:self];
	}
}

@end
