#import "../Redstone.h"

@implementation RSNotificationView

- (id)initForBulletin:(BBBulletin*)bulletin {
	if (self = [super initWithFrame:CGRectMake(0, 0, screenWidth, 130)]) {
		[self setBackgroundColor:[UIColor colorWithWhite:0.22 alpha:1.0]];
		
		RSTileInfo* tileInfo = [[RSTileInfo alloc] initWithBundleIdentifier:[bulletin section]];
		application = [[objc_getClass("SBApplicationController") sharedInstance] applicationWithBundleIdentifier:[bulletin section]];
		
		toastIcon = [[UIImageView alloc] initWithImage:[RSAesthetics getImageForTileWithBundleIdentifier:[bulletin section] size:1 colored:(tileInfo.hasColoredIcon || tileInfo.fullSizeArtwork)]];
		[toastIcon setFrame:CGRectMake(12, 15, 32, 32)];
		[toastIcon setTintColor:[UIColor whiteColor]];
		[toastIcon setBackgroundColor:[RSAesthetics accentColorForTile:[[[RSStartScreenController sharedInstance] tileForLeafIdentifier:[bulletin section]] tileInfo]]];
		[self addSubview:toastIcon];
		
		titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(54, 10, self.frame.size.width - 66, 20)];
		[titleLabel setFont:[UIFont fontWithName:@"SegoeUI-Semibold" size:15]];
		[titleLabel setTextColor:[UIColor whiteColor]];
		if ([bulletin title] && ![[bulletin title] isEqualToString:@""]) {
			[titleLabel setText:[bulletin title]];
		} else {
			[titleLabel setText:[application displayName]];
		}
		[self addSubview:titleLabel];
		
		subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		if ([bulletin subtitle] && ![[bulletin subtitle] isEqualToString:@""]) {
			[subtitleLabel setFrame:CGRectMake(54, 30, self.frame.size.width - 66, 20)];
			[subtitleLabel setFont:[UIFont fontWithName:@"SegoeUI-Semibold" size:15]];
			[subtitleLabel setTextColor:[UIColor whiteColor]];
			[subtitleLabel setText:[bulletin subtitle]];
		}
		
		messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(54, titleLabel.frame.origin.y + titleLabel.frame.size.height + subtitleLabel.frame.size.height, self.frame.size.width - 66, 40)];
		[messageLabel setFont:[UIFont fontWithName:@"SegoeUI" size:15]];
		[messageLabel setTextColor:[UIColor whiteColor]];
		[messageLabel setText:[bulletin message]];
		[messageLabel setNumberOfLines:2];
		[messageLabel setLineBreakMode:NSLineBreakByTruncatingTail];
		[messageLabel sizeToFit];
		[self addSubview:messageLabel];
		
		CGFloat notificationTextHeight = 10 + titleLabel.frame.size.height + subtitleLabel.frame.size.height + messageLabel.frame.size.height + 10 + 20;
		CGFloat notificationImageHeight = 15 + 32 + 15 + 20;
		[self setFrame:CGRectMake(0, 0, screenWidth, MAX(notificationTextHeight, notificationImageHeight))];
		
		UIView* grabberView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-20, screenWidth, 20)];
		[grabberView setBackgroundColor:[RSAesthetics accentColor]];
		[self addSubview:grabberView];
		
		UILabel* grabberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 20)];
		[grabberLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:18]];
		[grabberLabel setText:@"\uE76F"];
		[grabberLabel setTextAlignment:NSTextAlignmentCenter];
		[grabberLabel setTextColor:[UIColor whiteColor]];
		[grabberView addSubview:grabberLabel];
		
		UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
		[self addGestureRecognizer:tapGestureRecognizer];
	}
	
	return self;
}

- (void)animateIn {
	[self setFrame:CGRectMake(0, -self.frame.size.height, self.frame.size.width, self.frame.size.height)];
	
	[UIView animateWithDuration:0.3 animations:^{
		[self setEasingFunction:easeOutCubic forKeyPath:@"frame"];
		
		[self setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
	} completion:^(BOOL finished){
		[self removeEasingFunctionForKeyPath:@"frame"];
	}];
}

- (void)animateOut {
	[UIView animateWithDuration:0.3 animations:^{
		[self setEasingFunction:easeInCubic forKeyPath:@"frame"];
		
		[self setFrame:CGRectMake(0, -self.frame.size.height, self.frame.size.width, self.frame.size.height)];
	} completion:^(BOOL finished){
		[self removeEasingFunctionForKeyPath:@"frame"];
		[self removeFromSuperview];
	}];
}

- (void)stopSlideOutTimer {
	if ([slideOutTimer isKindOfClass:[NSTimer class]]) {
		[slideOutTimer invalidate];
		slideOutTimer = nil;
	}
}

- (void)resetSlideOutTimer {
	[self stopSlideOutTimer];
	
	slideOutTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(animateOut) userInfo:nil repeats:NO];
}

- (void)tapped {
	[self stopSlideOutTimer];
	[self animateOut];
	
	if ([RSLockScreenController sharedInstance]) {
		[[RSLockScreenController sharedInstance] attemptManualUnlockWithCompletionHandler:^{
			[[[RSCore sharedInstance] sharedSpringBoard] launchApplicationWithIdentifier:[application bundleIdentifier] suspended:NO];
		}];
	} else {
		[[[RSCore sharedInstance] sharedSpringBoard] launchApplicationWithIdentifier:[application bundleIdentifier] suspended:NO];
	}
}

@end
