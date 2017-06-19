#import "../Redstone.h"

@implementation RSNotificationView

- (id)notificationForBulletin:(BBBulletin*)bulletin isStatic:(BOOL)isStatic {
	self = [super initWithFrame:CGRectMake(0, 0, screenWidth, 80)];
	
	if (self) {
		[self setBackgroundColor:[UIColor colorWithWhite:0.22 alpha:1.0]];
		
		int addToHeight = (!isStatic) ? 15 : 0;
		
		RSTileInfo* tileInfo = [[RSTileInfo alloc] initWithBundleIdentifier:[bulletin section]];
		application = [[objc_getClass("SBApplicationController") sharedInstance] applicationWithBundleIdentifier:[bulletin section]];
		
		toastIcon = [[UIImageView alloc] initWithImage:[RSAesthetics getImageForTileWithBundleIdentifier:[bulletin section] size:1 colored:(tileInfo.hasColoredIcon || tileInfo.fullSizeArtwork)]];
		[toastIcon setFrame:CGRectMake(12, 15 + addToHeight, 32, 32)];
		[toastIcon setTintColor:[UIColor whiteColor]];
		[toastIcon setBackgroundColor:[RSAesthetics accentColorForTile:[[[RSStartScreenController sharedInstance] tileForLeafIdentifier:[bulletin section]] tileInfo]]];
		[self addSubview:toastIcon];
		
		titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		[titleLabel setFont:[UIFont fontWithName:@"SegoeUI-Semibold" size:15]];
		[titleLabel setTextColor:[UIColor whiteColor]];
		
		if ([bulletin title] && ![[bulletin title] isEqualToString:@""]) {
			[titleLabel setText:[bulletin title]];
		} else {
			[titleLabel setText:[application displayName]];
		}
		[titleLabel sizeToFit];
		[titleLabel setFrame:CGRectMake(56, 15 + addToHeight, screenWidth - 68, 16)];
		[self addSubview:titleLabel];
		
		subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		if ([bulletin subtitle] && ![[bulletin subtitle] isEqualToString:@""]) {
			[subtitleLabel setFont:[UIFont fontWithName:@"SegoeUI-Semibold" size:15]];
			[subtitleLabel setTextColor:[UIColor whiteColor]];
			[subtitleLabel setText:[bulletin subtitle]];
			[subtitleLabel sizeToFit];
			[subtitleLabel setFrame:CGRectMake(56, 15 + addToHeight + titleLabel.frame.size.height, screenWidth - 68, 16)];
			[self addSubview:subtitleLabel];
		}
		
		messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth - 86, 32)];
		[messageLabel setFont:[UIFont fontWithName:@"SegoeUI" size:15]];
		[messageLabel setTextColor:[UIColor whiteColor]];
		[messageLabel setText:[bulletin message]];
		[messageLabel setNumberOfLines:2];
		[messageLabel setLineBreakMode:NSLineBreakByTruncatingTail];
		[messageLabel sizeToFit];
		
		[messageLabel setFrame:CGRectMake(56, 15 + subtitleLabel.frame.size.height + titleLabel.frame.size.height + addToHeight, screenWidth - 86, messageLabel.frame.size.height)];
		[self addSubview:messageLabel];
		
		CGFloat notificationHeight = MAX(82 + addToHeight, titleLabel.frame.size.height + subtitleLabel.frame.size.height + messageLabel.frame.size.height + 50 + addToHeight);
		[self setFrame:CGRectMake(0, 0, screenWidth, notificationHeight)];
		
		UIView* grabberView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-20, screenWidth, 20)];
		[grabberView setBackgroundColor:[RSAesthetics accentColor]];
		[self addSubview:grabberView];
		
		UILabel* grabberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 20)];
		[grabberLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:18]];
		[grabberLabel setText:@"\uE76F"];
		[grabberLabel setTextAlignment:NSTextAlignmentCenter];
		[grabberLabel setTextColor:[UIColor whiteColor]];
		[grabberView addSubview:grabberLabel];
		
		if (!isStatic) {
			hideTimer = [NSTimer scheduledTimerWithTimeInterval:5 repeats:NO block:^(NSTimer *timer) {
				[self hide];
				
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
					[self removeFromSuperview];
				});
			}];
			
			// TODO: Add tap gesture recognizer to open app behind notification
			UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
			[self addGestureRecognizer:tapGestureRecognizer];
		}
	}
	
	return self;
}

- (void)show {
	[self.layer removeAllAnimations];
	CAAnimation* transformIn = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"
																function:CubicEaseOut
															   fromValue:-self.frame.size.height
																 toValue:0];
	[transformIn setDuration:0.3];
	[transformIn setRemovedOnCompletion:NO];
	[transformIn setFillMode:kCAFillModeForwards];
	
	[self.layer addAnimation:transformIn forKey:@"transform"];
}

- (void)hide {
	[hideTimer invalidate];
	hideTimer = nil;
	
	[self.layer removeAllAnimations];
	
	CAAnimation* transformOut = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"
																 function:CubicEaseIn
																fromValue:0
																  toValue:-self.frame.size.height];
	[transformOut setDuration:0.3];
	[transformOut setRemovedOnCompletion:NO];
	[transformOut setFillMode:kCAFillModeForwards];
	
	[self.layer addAnimation:transformOut forKey:@"transform"];
}
															
- (void)tapped {
	if ([RSLockScreenController sharedInstance]) {
		[self hide];
		[[RSLockScreenController sharedInstance] attemptManualUnlockWithCompletionHandler:^{
			[[[RSCore sharedInstance] sharedSpringBoard] launchApplicationWithIdentifier:[application bundleIdentifier] suspended:NO];
		}];
	}
}

@end
