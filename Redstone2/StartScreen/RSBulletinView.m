#import "../Redstone.h"

@implementation RSBulletinView

- (id)initWithFrame:(CGRect)frame bulletin:(BBBulletin *)bulletin tile:(RSTile*)tile bulletinCount:(int)bulletinCount {
	if (self = [super initWithFrame:frame]) {
		[CATransaction begin];
		[CATransaction setDisableActions:YES];
		
		// Title Label
		titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, self.frame.size.width - 16, 20)];
		[titleLabel setFont:[UIFont fontWithName:@"SegoeUI" size:16]];
		[titleLabel setTextColor:[UIColor whiteColor]];
		
		if ([bulletin title] && ![[bulletin title] isEqualToString:@""]) {
			[titleLabel setText:[bulletin title]];
		} else {
			[titleLabel setText:[tile displayName]];
		}
		[self addSubview:titleLabel];
		
		// Subtitle Label
		subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		if ([bulletin subtitle] && ![[bulletin subtitle] isEqualToString:@""]) {
			[subtitleLabel setFrame:CGRectMake(8, 28, self.frame.size.width - 16, 20)];
			[subtitleLabel setFont:[UIFont fontWithName:@"SegoeUI" size:16]];
			[subtitleLabel setTextColor:[UIColor whiteColor]];
			[subtitleLabel setText:[bulletin subtitle]];
			[self addSubview:subtitleLabel];
		}
		
		// Message Label
		messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 28 + subtitleLabel.frame.size.height, self.frame.size.width - 16, 40)];
		[messageLabel setFont:[UIFont fontWithName:@"SegoeUI" size:14]];
		[messageLabel setTextColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
		[messageLabel setText:[bulletin message]];
		[messageLabel setNumberOfLines:2];
		[messageLabel setLineBreakMode:NSLineBreakByTruncatingTail];
		[messageLabel sizeToFit];
		[self addSubview:messageLabel];
		
		// Badge Label
		badgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 8, self.frame.size.height - 28, 0, 20)];
		[badgeLabel setFont:[UIFont fontWithName:@"SegoeUI" size:14]];
		[badgeLabel setTextColor:[UIColor whiteColor]];
	
		if ([tile badgeCount] > 0) {
			[badgeLabel setText:[NSString stringWithFormat:@"%i", [tile badgeCount]]];
		} else {
			[badgeLabel setText:[NSString stringWithFormat:@"%i", bulletinCount]];
		}
		[badgeLabel sizeToFit];
		[badgeLabel setFrame:CGRectMake(self.frame.size.width - badgeLabel.frame.size.width - 8, self.frame.size.height - 28, badgeLabel.frame.size.width, 20)];
		[self addSubview:badgeLabel];
		
		// Tile Image
		tileImage = [[UIImageView alloc] initWithFrame:CGRectMake(badgeLabel.frame.origin.x - 28, self.frame.size.height - 28, 20, 20)];
		
		if (tileInfo.fullSizeArtwork) {} else {
			[tileImage setImage:[RSAesthetics getImageForTileWithBundleIdentifier:[bulletin section] size:5 colored:tile.tileInfo.hasColoredIcon]];
			[tileImage setTintColor:[UIColor whiteColor]];
		}
		
		[self addSubview:tileImage];
		
		// App Title
		appTitle = [[UILabel alloc] initWithFrame:CGRectMake(8, self.frame.size.height-28, tileImage.frame.origin.x-16, 20)];
		[appTitle setFont:[UIFont fontWithName:@"SegoeUI" size:14]];
		[appTitle setTextColor:[UIColor whiteColor]];
		[appTitle setText:[tile displayName]];
		[self addSubview:appTitle];
		
		[CATransaction commit];
	}
	
	return self;
}

- (void)setBadge:(int)badgeCount {
	[badgeLabel setText:[NSString stringWithFormat:@"%i", badgeCount]];
	[badgeLabel sizeToFit];
	[badgeLabel setFrame:CGRectMake(self.frame.size.width - badgeLabel.frame.size.width - 8, self.frame.size.height - 28, badgeLabel.frame.size.width, 20)];
	
	[tileImage setFrame:CGRectMake(badgeLabel.frame.origin.x - 28, self.frame.size.height - 28, 20, 20)];
	
	[appTitle setFrame:CGRectMake(8, self.frame.size.height-28, tileImage.frame.origin.x-16, 20)];
}

@end
