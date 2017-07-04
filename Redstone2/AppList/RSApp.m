#import "../Redstone.h"

@implementation RSApp

- (id)initWithFrame:(CGRect)frame leafIdentifier:(NSString *)leafIdentifier {
	if (self = [super initWithFrame:frame]) {
		self.icon = [[(SBIconController*)[objc_getClass("SBIconController") sharedInstance] model] leafIconForIdentifier:leafIdentifier];
		self.tileInfo = [[RSTileInfo alloc] initWithBundleIdentifier:leafIdentifier];
		
		[self setHighlightEnabled:YES];
		
		UIView* tileBackground = [[UIView alloc] initWithFrame:CGRectMake(5, 2, 50, 50)];
		[tileBackground setBackgroundColor:[[RSAesthetics accentColorForTile:self.tileInfo] colorWithAlphaComponent:1.0]];
		[self addSubview:tileBackground];
		
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
		
		UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
		[self addGestureRecognizer:tapGestureRecognizer];
	}
	
	return self;
}

- (void)tapped:(UITapGestureRecognizer*)gestureRecognizer {
	[self setTransform:CGAffineTransformIdentity];
	[[RSLaunchScreenController sharedInstance] setLaunchIdentifier:[self.icon applicationBundleID]];
	[[objc_getClass("SBIconController") sharedInstance] _launchIcon:self.icon];
}

@end
