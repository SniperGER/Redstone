#import "../Redstone.h"

@implementation RSTileNotificationView

extern dispatch_queue_t __BBServerQueue;

- (id)initWithFrame:(CGRect)frame tile:(RSTile *)tile {
	self = [super initWithFrame:frame];
	
	if (self) {
		self.tile = tile;
		sectionIdentifier = tile.iconIdentifier;
		bulletinServer = [objc_getClass("BBServer") sharedBBServer];
		
		canAddBulletin = YES;
		canRemoveBulletin = YES;
		
		dispatch_async(__BBServerQueue, ^{
			bulletins = [[[bulletinServer _allBulletinsForSectionID:sectionIdentifier] allObjects] mutableCopy];
			
			if (bulletins.count > 0) {
				dispatch_async(dispatch_get_main_queue(), ^{
					currentNotificationView = [self viewWithBulletin:[bulletins lastObject]];
					[self addSubview:currentNotificationView];
					[self.tile setLiveTileHidden:NO animated:YES];
				});
			}
		});
	}
	
	return self;
}

- (NSArray*)viewsForSize:(int)size {
	return nil;
}

- (void)update {
	return;
}

- (CGFloat)updateInterval {
	return 0;
}

- (void)addBulletin:(BBBulletin *)bulletin delayIncomingBulletins:(BOOL)delay {
	BOOL isAboutToStartLiveTile = (bulletins.count < 1 && currentNotificationView == nil);
	if (![bulletins containsObject:bulletin]) {
		[bulletins addObject:bulletin];
	}
	
	if (!canAddBulletin) {
		return;
	}

	dispatch_async(dispatch_get_main_queue(), ^{
		nextNotificationView = [self viewWithBulletin:bulletin];
		
		if (isAboutToStartLiveTile) {
			[self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
			[self addSubview:nextNotificationView];
			[self.tile setLiveTileHidden:NO animated:YES];
			
			currentNotificationView = nextNotificationView;
			nextNotificationView = nil;
		} else {
			[self addSubview:nextNotificationView];
			[currentNotificationView setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
			[nextNotificationView setFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
			
			[UIView animateWithDuration:1.0 animations:^{
				[currentNotificationView setEasingFunction:easeOutQuint forKeyPath:@"frame"];
				[nextNotificationView setEasingFunction:easeOutQuint forKeyPath:@"frame"];
				
				[currentNotificationView setFrame:CGRectMake(0, -self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
				[nextNotificationView setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
			} completion:^(BOOL finished){
				[currentNotificationView removeEasingFunctionForKeyPath:@"frame"];
				[nextNotificationView removeEasingFunctionForKeyPath:@"frame"];
				
				[currentNotificationView removeFromSuperview];
				currentNotificationView = nextNotificationView;
				nextNotificationView = nil;
			}];
		}
		
		if (delay) {
			canAddBulletin = NO;
			int currentBulletinCount = bulletins.count;
			
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				canAddBulletin = YES;
				
				if (bulletins.count != currentBulletinCount) {
					[self addBulletin:[bulletins lastObject] delayIncomingBulletins:NO];
				}
			});
		}
	});
}

- (void)removeBulletin:(BBBulletin *)bulletin {
	BOOL isAboutToStopLiveTile = (bulletins.count-1 <= 0);
	if ([bulletins containsObject:bulletin]) {
		[bulletins removeObject:bulletin];
	}
	
	dispatch_async(dispatch_get_main_queue(), ^{
		if (isAboutToStopLiveTile) {
			currentNotificationView = nil;
			[self.tile setLiveTileHidden:YES animated:YES];
		} else {
			nextNotificationView = [self viewWithBulletin:bulletin];
			[self addSubview:nextNotificationView];
			
			[currentNotificationView setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
			[nextNotificationView setFrame:CGRectMake(0, -self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
			
			[UIView animateWithDuration:1.0 animations:^{
				[currentNotificationView setEasingFunction:easeOutQuint forKeyPath:@"frame"];
				[nextNotificationView setEasingFunction:easeOutQuint forKeyPath:@"frame"];
				
				[currentNotificationView setFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
				[nextNotificationView setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
			} completion:^(BOOL finished){
				[currentNotificationView removeEasingFunctionForKeyPath:@"frame"];
				[nextNotificationView removeEasingFunctionForKeyPath:@"frame"];
				
				[currentNotificationView removeFromSuperview];
				currentNotificationView = nextNotificationView;
				nextNotificationView = nil;
			}];
		}
	});
}

- (UIView*)viewWithBulletin:(BBBulletin*)bulletin {
	SBApplication* application = [[objc_getClass("SBApplicationController") sharedInstance] applicationWithBundleIdentifier:sectionIdentifier];
	
	UIView* bulletinView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
	
	UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, self.frame.size.width-16, 20)];
	[titleLabel setFont:[UIFont fontWithName:@"SegoeUI" size:16]];
	[titleLabel setTextColor:[UIColor whiteColor]];
	
	if ([bulletin title] && ![[bulletin title] isEqualToString:@""]) {
		[titleLabel setText:[bulletin title]];
	} else {
		[titleLabel setText:[application displayName]];
	}
	[bulletinView addSubview:titleLabel];
	
	UILabel* messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 28, self.frame.size.width-16, 40)];
	[messageLabel setFont:[UIFont fontWithName:@"SegoeUI" size:14]];
	[messageLabel setTextColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
	[messageLabel setText:[bulletin message]];
	[messageLabel setNumberOfLines:2];
	[messageLabel setLineBreakMode:NSLineBreakByTruncatingTail];
	[messageLabel sizeToFit];
	[bulletinView addSubview:messageLabel];
	
	UILabel* badgeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	[badgeLabel setFont:[UIFont fontWithName:@"SegoeUI" size:14]];
	[badgeLabel setTextColor:[UIColor whiteColor]];
	[badgeLabel setText:[NSString stringWithFormat:@"%i", (int)[bulletins count]]];
	[badgeLabel sizeToFit];
	[badgeLabel setFrame:CGRectMake(self.frame.size.width - badgeLabel.frame.size.width - 8, self.frame.size.height - 28, badgeLabel.frame.size.width, 20)];
	[bulletinView addSubview:badgeLabel];
	
	UIImageView* tileImage = [[UIImageView alloc] initWithFrame:CGRectMake(badgeLabel.frame.origin.x - 28, self.frame.size.height - 28, 20, 20)];
	
	if (self.tile.tileInfo.fullSizeArtwork) {} else {
		[tileImage setImage:[RSAesthetics getImageForTileWithBundleIdentifier:[bulletin section] size:5 colored:self.tile.tileInfo.hasColoredIcon]];
		[tileImage setTintColor:[UIColor whiteColor]];
	}
	
	[bulletinView addSubview:tileImage];
	
	UILabel* appTitle = [[UILabel alloc] initWithFrame:CGRectMake(8, self.frame.size.height-28, tileImage.frame.origin.x-16, 20)];
	[appTitle setFont:[UIFont fontWithName:@"SegoeUI" size:14]];
	[appTitle setTextColor:[UIColor whiteColor]];
	[appTitle setText:[application displayName]];
	[bulletinView addSubview:appTitle];
	
	return bulletinView;
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	
	if (currentNotificationView) {
		[currentNotificationView removeFromSuperview];
		
		currentNotificationView = [self viewWithBulletin:[bulletins lastObject]];
		[self addSubview:currentNotificationView];
	}
}

- (BOOL)readyForDisplay {
	return (bulletins.count >= 1 && currentNotificationView != nil);
}

@end
