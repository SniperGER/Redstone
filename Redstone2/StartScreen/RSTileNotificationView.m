#import "../Redstone.h"

extern dispatch_queue_t __BBServerQueue;

@implementation RSTileNotificationView

- (id)initWithFrame:(CGRect)frame tile:(RSTile *)tile {
	if (self = [super initWithFrame:frame]) {
		self.tile = tile;
		sectionIdentifier = tile.icon.applicationBundleID;
		bulletinServer = [objc_getClass("BBServer") sharedBBServer];
		
		canAddBulletin = YES;
		canRemoveBulletin = YES;
		
		self.bulletins = [NSMutableArray new];
		dispatch_async(__BBServerQueue, ^{
			self.bulletins = [[[bulletinServer _allBulletinsForSectionID:sectionIdentifier] allObjects] mutableCopy];
			
			if (self.bulletins.count > 0) {
				[self addBulletin:[self.bulletins lastObject] delayIncomingBulletins:YES];
			}
		});
	}
	
	return self;
}

- (NSArray*)viewsForSize:(int)size {
	return nil;
}

- (BOOL)readyForDisplay {
	return (self.bulletins.count >= 1 && currentNotificationView != nil);
}

- (CGFloat)updateInterval {
	return 0;
}

- (void)update {
	return;
}

/*- (UIView*)viewWithBulletin:(BBBulletin*)bulletin {
	UIView* bulletinView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
	
	UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, self.frame.size.width-16, 20)];
	[titleLabel setFont:[UIFont fontWithName:@"SegoeUI" size:16]];
	[titleLabel setTextColor:[UIColor whiteColor]];
	
	if ([bulletin title] && ![[bulletin title] isEqualToString:@""]) {
		[titleLabel setText:[bulletin title]];
	} else {
		[titleLabel setText:[self.tile displayName]];
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
	
	if ([self.tile badgeCount] > 0) {
		[badgeLabel setText:[NSString stringWithFormat:@"%i", [self.tile badgeCount]]];
	} else {
		[badgeLabel setText:[NSString stringWithFormat:@"%i", (int)[self.bulletins count]]];
	}
	
	[badgeLabel sizeToFit];
	[badgeLabel setFrame:CGRectMake(self.frame.size.width - badgeLabel.frame.size.width - 8, self.frame.size.height - 28, badgeLabel.frame.size.width, 20)];
	[bulletinView addSubview:badgeLabel];
	currentNotificationBadge = badgeLabel;
	
	UIImageView* tileImage = [[UIImageView alloc] initWithFrame:CGRectMake(badgeLabel.frame.origin.x - 28, self.frame.size.height - 28, 20, 20)];
	
	if (self.tile.tileInfo.fullSizeArtwork) {} else {
		[tileImage setImage:[RSAesthetics getImageForTileWithBundleIdentifier:[bulletin section] size:5 colored:self.tile.tileInfo.hasColoredIcon]];
		[tileImage setTintColor:[UIColor whiteColor]];
	}
	
	[bulletinView addSubview:tileImage];
	
	UILabel* appTitle = [[UILabel alloc] initWithFrame:CGRectMake(8, self.frame.size.height-28, tileImage.frame.origin.x-16, 20)];
	[appTitle setFont:[UIFont fontWithName:@"SegoeUI" size:14]];
	[appTitle setTextColor:[UIColor whiteColor]];
	[appTitle setText:[self.tile displayName]];
	[bulletinView addSubview:appTitle];
	
	return bulletinView;
}*/

- (void)addBulletin:(BBBulletin *)bulletin delayIncomingBulletins:(BOOL)delayBulletins {
	BOOL isAboutToStartLiveTile = (currentNotificationView == nil);
	
	if (![self.bulletins containsObject:bulletin]) {
		[self.bulletins addObject:bulletin];
	}
	
	if (!canAddBulletin) {
		return;
	}
	
	dispatch_async(dispatch_get_main_queue(), ^{
		SBApplication* frontApp = [(SpringBoard*)[UIApplication sharedApplication] _accessibilityFrontMostApplication];
		
		nextNotificationView = [[RSBulletinView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) bulletin:bulletin tile:self.tile bulletinCount:(int)self.bulletins.count];
		
		if (isAboutToStartLiveTile) {
			[self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
			[self addSubview:nextNotificationView];
			
			currentNotificationView = nextNotificationView;
			nextNotificationView = nil;
			
			if  (self.tile.size < 2) {
				[self.tile setLiveTileHidden:YES];
				return;
			}
			
			if ([[objc_getClass("SBUserAgent") sharedUserAgent] deviceIsLocked] || frontApp != nil) {
				[self.tile setLiveTileHidden:NO];
				return;
			} else {
				[self.tile setLiveTileHidden:NO animated:YES];
			}
		} else {
			if ([[objc_getClass("SBUserAgent") sharedUserAgent] deviceIsLocked] || frontApp != nil) {
				[self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
				[self addSubview:nextNotificationView];
				
				currentNotificationView = nextNotificationView;
				nextNotificationView = nil;
				
				return;
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
		}
		
		if (delayBulletins) {
			canAddBulletin = NO;
			int currentBulletinCount = self.bulletins.count;
			
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				canAddBulletin = YES;
				
				if (self.bulletins.count != currentBulletinCount) {
					[self addBulletin:[self.bulletins lastObject] delayIncomingBulletins:YES];
				}
			});
		}
	});
}

- (void)removeBulletin:(BBBulletin *)bulletin {
	BOOL isAboutToStopLiveTile = (self.bulletins.count-1 <= 0);
	if ([self.bulletins containsObject:bulletin]) {
		[self.bulletins removeObject:bulletin];
	}
	
	dispatch_async(dispatch_get_main_queue(), ^{
		SBApplication* frontApp = [(SpringBoard*)[UIApplication sharedApplication] _accessibilityFrontMostApplication];
		
		if (isAboutToStopLiveTile) {
			currentNotificationView = nil;
			
			if ([[objc_getClass("SBUserAgent") sharedUserAgent] deviceIsLocked] || frontApp != nil) {
				[self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
				[self.tile setLiveTileHidden:YES];
				return;
			} else {
				[self.tile setLiveTileHidden:YES animated:YES];
			}
		} else {
			nextNotificationView = [[RSBulletinView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) bulletin:[self.bulletins lastObject] tile:self.tile bulletinCount:(int)self.bulletins.count];
			
			if ([[objc_getClass("SBUserAgent") sharedUserAgent] deviceIsLocked] || frontApp != nil) {
				[self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
				[self addSubview:nextNotificationView];
				
				currentNotificationView = nextNotificationView;
				nextNotificationView = nil;
				
				return;
			} else {
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
		}
	});
}

- (void)setBadge:(int)badgeCount {
	[currentNotificationView setBadge:badgeCount];
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	
	if (currentNotificationView) {
		[currentNotificationView removeFromSuperview];
		
		currentNotificationView = [[RSBulletinView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) bulletin:[self.bulletins lastObject] tile:self.tile bulletinCount:(int)self.bulletins.count];
		[self addSubview:currentNotificationView];
	}
}

@end
