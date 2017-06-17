#import "../Redstone.h"

@implementation RSTile

- (id)initWithFrame:(CGRect)frame leafIdentifier:(NSString*)leafId size:(int)tileSize {
	self = [super initWithFrame:frame];
	
	if (self) {
		self.size = tileSize;
		self.tileInfo = [[RSTileInfo alloc] initWithBundleIdentifier:leafId];
		self.icon = [[[objc_getClass("SBIconController") sharedInstance] model] leafIconForIdentifier:leafId];
		self.iconIdentifier = [[self.icon application] bundleIdentifier];
		self.originalCenter = self.center;
		
		[self.titleLabel removeFromSuperview];
		
		[self setBackgroundColor:[RSAesthetics accentColorForTile:self.tileInfo]];
		
		tileWrapper = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		[tileWrapper setClipsToBounds:YES];
		[self addSubview:tileWrapper];
		
		tileContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		[tileWrapper addSubview:tileContainer];
		
#pragma mark Tile Label
		tileLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		[tileLabel setFont:[UIFont fontWithName:@"SegoeUI" size:14]];
		[tileLabel setTextColor:[UIColor whiteColor]];
		
		if (self.tileInfo.localizedDisplayName) {
			[tileLabel setText:self.tileInfo.localizedDisplayName];
		} else if (self.tileInfo.displayName) {
			[tileLabel setText:self.tileInfo.displayName];
		} else {
			[tileLabel setText:[self.icon displayName]];
		}
		
		[tileLabel sizeToFit];
		[tileLabel setFrame:CGRectMake(8,
									   self.frame.size.height - tileLabel.frame.size.height - 8,
									   MIN(tileLabel.frame.size.width, self.frame.size.width - 16),
									   tileLabel.frame.size.height)];
		[tileContainer addSubview:tileLabel];
		
		if (self.size < 2 || self.tileInfo.tileHidesLabel || [[self.tileInfo.labelHiddenForSizes objectForKey:[[NSNumber numberWithInt:self.size] stringValue]] boolValue]) {
			[tileLabel setHidden:YES];
		} else {
			[tileLabel setHidden:NO];
		}
		
#pragma mark Tile Icon
		if (self.tileInfo.fullSizeArtwork) {
			tileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
			[tileImageView setImage:[RSAesthetics getImageForTileWithBundleIdentifier:[[self.icon application] bundleIdentifier] size:self.size colored:YES]];
			[tileContainer addSubview:tileImageView];
		} else {
			CGSize tileImageSize = [RSMetrics tileIconDimensionsForSize:tileSize];
			tileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tileImageSize.width, tileImageSize.height)];
			[tileImageView setCenter:CGPointMake(frame.size.width/2, frame.size.height/2)];
			
			[tileImageView setImage:[RSAesthetics getImageForTileWithBundleIdentifier:[[self.icon application] bundleIdentifier] size:5 colored:self.tileInfo.hasColoredIcon]];
			[tileImageView setTintColor:[UIColor whiteColor]];
			[tileContainer addSubview:tileImageView];
		}
		
#pragma mark Badge
		if (self.tileInfo.usesCornerBadge) {
			badgeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
			[badgeLabel setFont:[UIFont fontWithName:@"SegoeUI" size:14]];
			[badgeLabel setTextColor:[UIColor whiteColor]];
			[badgeLabel setHidden:YES];
		} else {
			badgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
			[badgeLabel setFont:[UIFont fontWithName:@"SegoeUI" size:36]];
			[badgeLabel setTextColor:[UIColor whiteColor]];
			[badgeLabel setTextAlignment:NSTextAlignmentCenter];
			[badgeLabel setHidden:YES];
		}
		[tileContainer addSubview:badgeLabel];
		
		if ([[self.icon application] badgeNumberOrString] != nil) {
			[self setBadge:[[[self.icon application] badgeNumberOrString] intValue]];
		}
		
#pragma mark Live Tiles
		NSBundle* liveTileBundle = [NSBundle bundleWithPath:[NSString stringWithFormat:@"%@/Live Tiles/%@.tile", RESOURCE_PATH, @"com.apple.weather"]];
		if (liveTileBundle && [leafId isEqualToString:@"com.apple.news"]) {
			liveTile = [[[liveTileBundle principalClass] alloc] initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, frame.size.height) tile:self];
		}
		
		if (liveTile) {
			[liveTile setClipsToBounds:YES];
			[liveTile setTile:self];
			[tileWrapper addSubview:liveTile];
			
			NSArray* viewsForSize = [liveTile viewsForSize:self.size];
			if (viewsForSize != nil && viewsForSize.count > 0) {
				for (int i=0; i<viewsForSize.count; i++) {
					[[viewsForSize objectAtIndex:i] setFrame:CGRectMake(0, (i > 0) ? self.bounds.size.height : 0, self.bounds.size.width, self.bounds.size.height)];
					[liveTile addSubview:[viewsForSize objectAtIndex:i]];
				}
			}
			
			if (![[objc_getClass("SBUserAgent") sharedUserAgent] deviceIsLocked]) {
				[self startLiveTile];
			}
		}
		
#pragma mark Gesture Recognizers
		longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressed:)];
		[longPressGestureRecognizer setMinimumPressDuration:0.5];
		[longPressGestureRecognizer setCancelsTouchesInView:NO];
		[longPressGestureRecognizer setDelaysTouchesBegan:NO];
		[self addGestureRecognizer:longPressGestureRecognizer];
		
		panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveViewWithGestureRecognizer:)];
		[panGestureRecognizer setDelegate:self];
		[panGestureRecognizer setCancelsTouchesInView:NO];
		[panGestureRecognizer setDelaysTouchesBegan:NO];
		[self addGestureRecognizer:panGestureRecognizer];
		
		tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
		[tapGestureRecognizer setCancelsTouchesInView:NO];
		[tapGestureRecognizer setDelaysTouchesBegan:NO];
		[tapGestureRecognizer requireGestureRecognizerToFail:panGestureRecognizer];
		[tapGestureRecognizer requireGestureRecognizerToFail:longPressGestureRecognizer];
		[self addGestureRecognizer:tapGestureRecognizer];
		
#pragma mark Editing Mode Buttons
		unpinButton = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
		[unpinButton setCenter:CGPointMake(frame.size.width, 0)];
		[unpinButton setBackgroundColor:[UIColor whiteColor]];
		[unpinButton.layer setCornerRadius:15];
		[unpinButton setHidden:YES];
		[self addSubview:unpinButton];
		
		UILabel* unpinLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
		[unpinLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:14]];
		[unpinLabel setText:@"\uE77A"];
		[unpinLabel setTextAlignment:NSTextAlignmentCenter];
		[unpinButton addSubview:unpinLabel];
		
		unpinGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(unpin:)];
		[unpinButton addGestureRecognizer:unpinGestureRecognizer];
		
		scaleButton = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
		[scaleButton setCenter:CGPointMake(frame.size.width, frame.size.height)];
		[scaleButton setBackgroundColor:[UIColor whiteColor]];
		[scaleButton.layer setCornerRadius:15];
		[scaleButton setHidden:YES];
		[scaleButton setTransform:CGAffineTransformMakeRotation(deg2rad([self scaleButtonRotationForCurrentSize]))];
		[self addSubview:scaleButton];
		
		UILabel* scaleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
		[scaleLabel setText:@"\uE7EA"];
		[scaleLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:14]];
		[scaleLabel setTextAlignment:NSTextAlignmentCenter];
		[scaleButton addSubview:scaleLabel];
		
		scaleGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setNextSize)];
		[scaleButton addGestureRecognizer:scaleGestureRecognizer];
		
		//		debugBulletins = [NSMutableArray new];
		//		dispatch_async(__BBServerQueue, ^{
		//			 BBServer* server = [NSClassFromString(@"BBServer") sharedBBServer];
		//
		//			for (BBBulletin *bulletin in [server _allBulletinsForSectionID:[[self.icon application] bundleIdentifier]]) {
		//				[debugBulletins addObject:bulletin];
		//			}
		//		});
	}
	
	return self;
}

- (CGRect)basePosition {
	return CGRectMake(self.layer.position.x - (self.bounds.size.width/2),
					  self.layer.position.y - (self.bounds.size.height/2),
					  self.bounds.size.width,
					  self.bounds.size.height);
}

- (void)setIsSelectedTile:(BOOL)isSelectedTile {
	if ([[RSStartScreenController sharedInstance] isEditing]) {
		_isSelectedTile = isSelectedTile;
		
		[panGestureRecognizer setEnabled:YES];
		[self.layer removeAllAnimations];
		
		if (isSelectedTile) {
			shouldAllowPan = YES;
			[[[[RSStartScreenController sharedInstance] startScrollView] panGestureRecognizer] setEnabled:NO];
			[[[[RSStartScreenController sharedInstance] startScrollView] panGestureRecognizer] setEnabled:YES];
			
			[self.superview bringSubviewToFront:self];
			[self setAlpha:1.0];
			[self setTransform:CGAffineTransformMakeScale(1.05, 1.05)];
			
			[unpinButton setHidden:NO];
			[scaleButton setHidden:NO];
		} else {
			shouldAllowPan = NO;
			[unpinButton setHidden:YES];
			[scaleButton setHidden:YES];
			
			[UIView animateWithDuration:.2 animations:^{
				[self setEasingFunction:easeOutQuint forKeyPath:@"frame"];
				
				[self setAlpha:0.8];
				[self setTransform:CGAffineTransformMakeScale(0.85, 0.85)];
			} completion:^(BOOL finished) {
				[self removeEasingFunctionForKeyPath:@"frame"];
			}];
			
		}
	} else {
		_isSelectedTile = NO;
		[self.layer removeAllAnimations];
		
		[UIView animateWithDuration:.2 animations:^{
			[self setEasingFunction:easeOutQuint forKeyPath:@"frame"];
			
			[self setAlpha:1.0];
			[self setTransform:CGAffineTransformIdentity];
		} completion:^(BOOL finished) {
			[self removeEasingFunctionForKeyPath:@"frame"];
		}];
		
		[longPressGestureRecognizer setEnabled:YES];
		shouldAllowPan = NO;
		
		[unpinButton setHidden:YES];
		[scaleButton setHidden:YES];
	}
}

- (void)unpin:(UITapGestureRecognizer*)recognizer {
	[[RSStartScreenController sharedInstance] unpinTile:self];
}

- (void)setNextSize {
	switch (self.size) {
		case 1:
			self.size = 3;
			break;
		case 2:
			self.size = 1;
			break;
		case 3:
			self.size = 2;
			break;
		default: break;
	}
	
	CGSize newTileSize = [RSMetrics tileDimensionsForSize:self.size];
	
	float step = [RSMetrics tileDimensionsForSize:1].width + [RSMetrics tileBorderSpacing];
	
	CGFloat maxPositionX = [[RSStartScreenController sharedInstance] startScrollView].bounds.size.width - newTileSize.width;
	CGFloat maxPositionY =  [[RSStartScreenController sharedInstance] startScrollView].contentSize.height + [RSMetrics tileBorderSpacing];
	
	[self setTransform:CGAffineTransformIdentity];
	
	CGRect newTilePosition = CGRectMake(MIN(MAX(step * roundf((self.frame.origin.x / step)), 0), maxPositionX),
										MIN(MAX(step * roundf((self.frame.origin.y / step)), 0), maxPositionY),
										newTileSize.width,
										newTileSize.height);
	
	
	[self setFrame:newTilePosition];
	self.originalCenter = self.center;
	
	[tileWrapper setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
	/*if (liveTile) {
		[tileContainer setFrame:CGRectMake(0, tileContainer.frame.origin.y, self.bounds.size.width, self.bounds.size.height)];
		[liveTile setFrame:CGRectMake(0, liveTile.frame.origin.y, self.bounds.size.width, self.bounds.size.height)];
		
		if (![liveTile isKindOfClass:[RSTileNotificationView class]]) {
			liveTilePageIndex = 0;
			
			if (liveTileAnimationTimer) {
				[liveTileAnimationTimer invalidate];
				liveTileAnimationTimer = nil;
			}
			
			if ([liveTile hasMultiplePages] || [liveTile allowsRemovalOfSubviews]) {
				[[liveTile subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
			}
			
			NSArray* viewsForSize = [liveTile viewsForSize:self.size];
			for (int i=0; i<viewsForSize.count; i++) {
				[[viewsForSize objectAtIndex:i] setFrame:CGRectMake(0, (i > 0) ? self.bounds.size.height : 0, self.bounds.size.width, self.bounds.size.height)];
				[liveTile addSubview:[viewsForSize objectAtIndex:i]];
			}
			
			if ((viewsForSize.count > 1 && [liveTile hasMultiplePages]) || [liveTile respondsToSelector:@selector(triggerAnimation)]) {
				liveTileAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(showNextLiveTilePage) userInfo:nil repeats:YES];
			}
		} else {
			if (self.size < 3 || ![liveTile readyForDisplay]) {
				[tileContainer setHidden:NO];
				[tileContainer setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
				[liveTile setFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
			} else {
				[tileContainer setHidden:YES];
				[tileContainer setFrame:CGRectMake(0, -self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
				[liveTile setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
			}
		}
	}*/
	
	if (liveTile) {
		[tileContainer setFrame:CGRectMake(0, tileContainer.frame.origin.y, self.bounds.size.width, self.bounds.size.height)];
		[liveTile setFrame:CGRectMake(0, liveTile.frame.origin.y, self.bounds.size.width, self.bounds.size.height)];
		
		if (liveTileAnimationTimer) {
			[liveTileAnimationTimer invalidate];
			liveTileAnimationTimer = nil;
		}
		
		NSArray* viewsForSize = [liveTile viewsForSize:self.size];
		if (viewsForSize != nil && viewsForSize.count > 0) {
			[[liveTile subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
			for (int i=0; i<viewsForSize.count; i++) {
				[[viewsForSize objectAtIndex:i] setFrame:CGRectMake(0, (i > 0) ? self.bounds.size.height : 0, self.bounds.size.width, self.bounds.size.height)];
				[liveTile addSubview:[viewsForSize objectAtIndex:i]];
			}
		
			liveTilePageIndex = 0;
			
			if (viewsForSize.count > 1) {
				liveTileAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:6.0 target:self selector:@selector(displayNextLiveTilePage) userInfo:nil repeats:YES];
			}
		}
	}
	
	if (self.size < 2 || self.tileInfo.tileHidesLabel || [[self.tileInfo.labelHiddenForSizes objectForKey:[[NSNumber numberWithInt:self.size] stringValue]] boolValue]) {
		[tileLabel setHidden:YES];
	} else {
		[tileLabel setHidden:NO];
		[tileLabel setFrame:CGRectMake(8,
									   self.frame.size.height - tileLabel.frame.size.height - 8,
									   tileLabel.frame.size.width,
									   tileLabel.frame.size.height)];
	}
	
	if (self.tileInfo.fullSizeArtwork) {
		[tileImageView setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
		[tileImageView setImage:[RSAesthetics getImageForTileWithBundleIdentifier:[[self.icon application] bundleIdentifier] size:self.size colored:YES]];
	} else {
		CGSize tileImageSize = [RSMetrics tileIconDimensionsForSize:self.size];
		[tileImageView setFrame:CGRectMake(0, 0, tileImageSize.width, tileImageSize.height)];
		[tileImageView setCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)];
		
		[tileImageView setImage:[RSAesthetics getImageForTileWithBundleIdentifier:[[self.icon application] bundleIdentifier] size:self.size colored:self.tileInfo.hasColoredIcon]];
		[tileImageView setTintColor:[UIColor whiteColor]];
	}
	
	[unpinButton setCenter:CGPointMake(self.frame.size.width, 0)];
	[scaleButton setCenter:CGPointMake(self.frame.size.width, self.frame.size.height)];
	
	[scaleButton setTransform:CGAffineTransformMakeRotation(deg2rad([self scaleButtonRotationForCurrentSize]))];
	[self setTransform:CGAffineTransformMakeScale(1.05, 1.05)];
	
	[self setBadge:badgeValue];
	
	[[RSStartScreenController sharedInstance] moveAffectedTilesForTile:self];
}

- (CGFloat)scaleButtonRotationForCurrentSize {
	switch (self.size) {
		case 1:
			return -135.0;
			break;
		case 2:
			return 45.0;
			break;
		case 3:
			return 0.0;
			break;
		case 4:
			return 90.0;
		default:
			return 0.0;
			break;
			
	}
}

- (void)setBadge:(int)badgeCount {
	badgeValue = badgeCount;
	
	if (!badgeCount || badgeCount == 0) {
		[badgeLabel setText:nil];
		[badgeLabel setHidden:YES];
		[tileImageView setCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)];
		return;
	}
	
	if (self.tileInfo.usesCornerBadge || [[self.tileInfo.cornerBadgeForSizes objectForKey:[[NSNumber numberWithInt:self.size] stringValue]] boolValue]) {
		if (badgeCount > 99) {
			[badgeLabel setText:@"99+"];
		} else {
			[badgeLabel setText:[NSString stringWithFormat:@"%d", badgeCount]];
		}
		[badgeLabel setFont:[UIFont fontWithName:@"SegoeUI" size:14]];
		[badgeLabel sizeToFit];
		[badgeLabel setFrame:CGRectMake(self.bounds.size.width - badgeLabel.frame.size.width - 8,
										self.bounds.size.height - badgeLabel.frame.size.height - 8,
										badgeLabel.frame.size.width,
										badgeLabel.frame.size.height)];
		[badgeLabel setHidden:NO];
	} else {
		if (self.size < 2) {
			[badgeLabel setFont:[UIFont fontWithName:@"SegoeUI" size:24]];
		} else {
			[badgeLabel setFont:[UIFont fontWithName:@"SegoeUI" size:36]];
		}
		
		[badgeLabel setText:[NSString stringWithFormat:@"%d", MIN(badgeCount, 99)]];
		[badgeLabel sizeToFit];
		
		CGSize tileImageSize = [RSMetrics tileIconDimensionsForSize:self.size];
		CGSize combinedSize = CGSizeMake(tileImageSize.width + badgeLabel.frame.size.width + 5, tileImageSize.height);
		
		[tileImageView setCenter:CGPointMake(self.bounds.size.width/2 - (combinedSize.width - tileImageView.frame.size.width)/2, self.bounds.size.height/2)];
		[badgeLabel setCenter:CGPointMake(self.bounds.size.width/2 + (combinedSize.width - badgeLabel.frame.size.width)/2, self.bounds.size.height/2)];
		
		[badgeLabel setHidden:NO];
	}
}

// LIVE TILE METHODS

- (void)startLiveTile {
	if (!liveTile) {
		return;
	}
	
	[liveTile update];
	
	if ([liveTile readyForDisplay]) {
		[self setLiveTileHidden:NO];
	}
	
	if ([liveTile updateInterval] > 0) {
		liveTileUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:[liveTile updateInterval] target:liveTile selector:@selector(update) userInfo:nil repeats:YES];
	}
	
	NSArray* viewsForSize = [liveTile viewsForSize:self.size];
	if (viewsForSize && viewsForSize.count > 1) {
		for (int i=0; i<viewsForSize.count; i++) {
			[[viewsForSize objectAtIndex:i] setFrame:CGRectMake(0, (i > 0) ? self.bounds.size.height : 0, self.bounds.size.width, self.bounds.size.height)];
		}
		
		liveTilePageIndex = 0;
		liveTileAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:6.0 target:self selector:@selector(displayNextLiveTilePage) userInfo:nil repeats:YES];
	}
}

- (void)stopLiveTile {
	if (!liveTile) {
		return;
	}
	
	if (liveTileUpdateTimer) {
		[liveTileUpdateTimer invalidate];
		liveTileUpdateTimer = nil;
	}
	
	if (liveTileAnimationTimer) {
		[liveTileAnimationTimer invalidate];
		liveTileAnimationTimer = nil;
	}
	
	[self setLiveTileHidden:YES];
}

- (void)setLiveTileHidden:(BOOL)hidden {
	if (!liveTile) {
		return;
	}
	
	if (!hidden) {
		[tileContainer setFrame:CGRectMake(0, -self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
		[liveTile setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
		[tileContainer setHidden:YES];
	} else {
		[tileContainer setHidden:NO];
		[tileContainer setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
		[liveTile setFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
	}
}

- (void)setLiveTileHidden:(BOOL)hidden animated:(BOOL)animated {
	if (!liveTile) {
		return;
	}
	
	if (!animated) {
		[self setLiveTileHidden:hidden];
	} else {
		if (!hidden) {
			[tileContainer setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
			[liveTile setFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
			
			[UIView animateWithDuration:1.0 animations:^{
				[tileContainer setEasingFunction:easeOutQuint forKeyPath:@"frame"];
				[liveTile setEasingFunction:easeOutQuint forKeyPath:@"frame"];
				
				[tileContainer setFrame:CGRectMake(0, -self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
				[liveTile setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
			} completion:^(BOOL finished){
				[tileContainer removeEasingFunctionForKeyPath:@"frame"];
				[liveTile removeEasingFunctionForKeyPath:@"frame"];
				
				[tileContainer setHidden:YES];
			}];
		} else {
			[tileContainer setHidden:NO];
			[tileContainer setFrame:CGRectMake(0, -self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
			[liveTile setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
			
			[UIView animateWithDuration:1.0 animations:^{
				[tileContainer setEasingFunction:easeOutQuint forKeyPath:@"frame"];
				[liveTile setEasingFunction:easeOutQuint forKeyPath:@"frame"];
				
				[tileContainer setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
				[liveTile setFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
			} completion:^(BOOL finished){
				[tileContainer removeEasingFunctionForKeyPath:@"frame"];
				[liveTile removeEasingFunctionForKeyPath:@"frame"];
			}];
		}
	}
}

- (void)displayNextLiveTilePage {
	if ([[objc_getClass("SBUserAgent") sharedUserAgent] deviceIsLocked]) {
		[self stopLiveTile];
		return;
	}
	
	if ([liveTile respondsToSelector:@selector(triggerAnimation)]) {
		//[liveTile triggerAnimation];
		return;
	}
	
	UIView* currentPage = [[liveTile viewsForSize:self.size] objectAtIndex:liveTilePageIndex];
	UIView* nextPage = [[liveTile viewsForSize:self.size] objectAtIndex:(liveTilePageIndex+1 >= liveTile.subviews.count) ? 0 : liveTilePageIndex+1];
	
	[currentPage setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
	[nextPage setFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
	
	[UIView animateWithDuration:1.0 animations:^{
		[currentPage setEasingFunction:easeOutQuint forKeyPath:@"frame"];
		[nextPage setEasingFunction:easeOutQuint forKeyPath:@"frame"];
		
		[currentPage setFrame:CGRectMake(0, -self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
		[nextPage setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
	} completion:^(BOOL finished){
		[currentPage removeEasingFunctionForKeyPath:@"frame"];
		[nextPage removeEasingFunctionForKeyPath:@"frame"];
		
		[currentPage setFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
	}];
	
	liveTilePageIndex++;
	if (liveTilePageIndex >= liveTile.subviews.count) {
		liveTilePageIndex = 0;
	}
}

/*- (void)startLiveTile {
	if (liveTile == nil || [liveTile isKindOfClass:[RSTileNotificationView class]]) {
		return;
	}
	
	if (liveTileAnimationTimer) {
		[liveTileAnimationTimer invalidate];
		liveTileAnimationTimer = nil;
	}
	
	if (liveTileUpdateTimer) {
		[liveTileUpdateTimer invalidate];
		liveTileUpdateTimer = nil;
	}
	
	if ([liveTile hasMultiplePages] || [liveTile allowsRemovalOfSubviews]) {
		[[liveTile subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
	}
	
	NSArray* viewsForSize = [liveTile viewsForSize:self.size];
	for (int i=0; i<viewsForSize.count; i++) {
		[[viewsForSize objectAtIndex:i] setFrame:CGRectMake(0, (i > 0) ? self.bounds.size.height : 0, self.bounds.size.width, self.bounds.size.height)];
		[liveTile addSubview:[viewsForSize objectAtIndex:i]];
	}
	
	[liveTile prepareForUpdate];
	
	if (![liveTile hasAsyncLoading] && !liveTile.started) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(arc4random_uniform(3) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[self transitionLiveTileToStarted:YES];
		});
		[self setLiveTileStarted:YES];
	}
	[liveTile setStarted:YES];
}

- (void)stopLiveTile {
	if (liveTile == nil || [liveTile isKindOfClass:[RSTileNotificationView class]]) {
		return;
	}
	
	if (liveTileAnimationTimer) {
		[liveTileAnimationTimer invalidate];
		liveTileAnimationTimer = nil;
	}
	
	if (liveTileUpdateTimer) {
		[liveTileUpdateTimer invalidate];
		liveTileUpdateTimer = nil;
	}
	
	liveTilePageIndex = 0;
	[liveTile requestStop];
	
	if ([liveTile hasMultiplePages] || [liveTile respondsToSelector:@selector(triggerAnimation)]) {
		[liveTile setStarted:NO];
		
		[tileContainer setHidden:NO];
		[tileContainer setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
		[liveTile setFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
		
		if ([liveTile hasMultiplePages]) {
			for (int i=0; i<liveTile.subviews.count; i++) {
				[[liveTile.subviews objectAtIndex:i] setFrame:CGRectMake(0, (i > 0) ? self.bounds.size.height : 0, self.bounds.size.width, self.bounds.size.height)];
			}
		}
		[self setLiveTileStarted:NO];
	}
}

- (void)updateLiveTile {
	if (![[objc_getClass("SBUserAgent") sharedUserAgent] deviceIsLocked] && ![[RSCore sharedInstance] currentApplication]) {
		[liveTile prepareForUpdate];
	} else {
		[self stopLiveTile];
	}
}

- (void)setLiveTileStarted:(BOOL)ready {
	if ([liveTile isKindOfClass:[RSTileNotificationView class]] && self.size < 3) {
		[tileContainer setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
		[liveTile setFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
		return;
	}
	
	if (ready) {
		[tileContainer setFrame:CGRectMake(0, -self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
		[liveTile setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
		[tileContainer setHidden:YES];
		
		if (![liveTile isKindOfClass:[RSTileNotificationView class]] && ([liveTile hasMultiplePages] || [liveTile respondsToSelector:@selector(triggerAnimation)])) {
			if (liveTileAnimationTimer) {
				[liveTileAnimationTimer invalidate];
				liveTileAnimationTimer = nil;
			}
			
			liveTileAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:6.0 target:self selector:@selector(showNextLiveTilePage) userInfo:nil repeats:YES];
		}
	} else {
		[tileContainer setHidden:NO];
		[tileContainer setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
		[liveTile setFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
		
		if ([liveTile hasMultiplePages]) {
			for (int i=0; i<liveTile.subviews.count; i++) {
				[[liveTile.subviews objectAtIndex:i] setFrame:CGRectMake(0, (i > 0) ? self.bounds.size.height : 0, self.bounds.size.width, self.bounds.size.height)];
			}
		}
	}
}

- (void)transitionLiveTileToStarted:(BOOL)ready {
	if ([liveTile isKindOfClass:[RSTileNotificationView class]] && self.size < 3) {
		[tileContainer setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
		[liveTile setFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
		return;
	}
	
	if (ready) {
		[tileContainer setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
		[liveTile setFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
		
		[UIView animateWithDuration:1.0 animations:^{
			[tileContainer setEasingFunction:easeOutQuint forKeyPath:@"frame"];
			[liveTile setEasingFunction:easeOutQuint forKeyPath:@"frame"];
			
			[tileContainer setFrame:CGRectMake(0, -self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
			[liveTile setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
		} completion:^(BOOL finished){
			[tileContainer removeEasingFunctionForKeyPath:@"frame"];
			[liveTile removeEasingFunctionForKeyPath:@"frame"];
			
			[tileContainer setHidden:YES];
		}];
		
		if (![liveTile isKindOfClass:[RSTileNotificationView class]] && ([liveTile hasMultiplePages] || [liveTile respondsToSelector:@selector(triggerAnimation)])) {
			if (liveTileAnimationTimer) {
				[liveTileAnimationTimer invalidate];
				liveTileAnimationTimer = nil;
			}
			
			liveTileAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:6.0 target:self selector:@selector(showNextLiveTilePage) userInfo:nil repeats:YES];
		}
	} else {
		[tileContainer setHidden:NO];
		[tileContainer setFrame:CGRectMake(0, -self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
		[liveTile setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
		
		[UIView animateWithDuration:1.0 animations:^{
			[tileContainer setEasingFunction:easeOutQuint forKeyPath:@"frame"];
			[liveTile setEasingFunction:easeOutQuint forKeyPath:@"frame"];
			
			[tileContainer setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
			[liveTile setFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
		} completion:^(BOOL finished){
			[tileContainer removeEasingFunctionForKeyPath:@"frame"];
			[liveTile removeEasingFunctionForKeyPath:@"frame"];
		}];
	}
}

- (void)showNextLiveTilePage {
	if (!liveTile || [liveTile subviews].count < 1) {
		return;
	}
	
	if ([[objc_getClass("SBUserAgent") sharedUserAgent] deviceIsLocked]) {
		[self stopLiveTile];
		return;
	}
	
	if (![liveTile readyForDisplay] && liveTile.started) {
		[tileContainer setHidden:NO];
		
		[UIView animateWithDuration:1.0 animations:^{
			[tileContainer setEasingFunction:easeOutQuint forKeyPath:@"frame"];
			[liveTile setEasingFunction:easeOutQuint forKeyPath:@"frame"];
			
			[tileContainer setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
			[liveTile setFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
		} completion:^(BOOL finished){
			[tileContainer removeEasingFunctionForKeyPath:@"frame"];
			[liveTile removeEasingFunctionForKeyPath:@"frame"];
		}];
		
		[liveTile setStarted:NO];
		
		return;
	} else if ([liveTile readyForDisplay] && !liveTile.started) {
		[liveTile setStarted:YES];
		[self transitionLiveTileToStarted:YES];
		
		return;
	}
	
	if ([liveTile respondsToSelector:@selector(triggerAnimation)]) {
		[liveTile triggerAnimation];
		return;
	}
	
	UIView* currentPage = [[liveTile subviews] objectAtIndex:liveTilePageIndex];
	UIView* nextPage = [[liveTile subviews] objectAtIndex:(liveTilePageIndex+1 >= liveTile.subviews.count) ? 0 : liveTilePageIndex+1];
	
	[currentPage setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
	[nextPage setFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
	
	[UIView animateWithDuration:1.0 animations:^{
		[currentPage setEasingFunction:easeOutQuint forKeyPath:@"frame"];
		[nextPage setEasingFunction:easeOutQuint forKeyPath:@"frame"];
		
		[currentPage setFrame:CGRectMake(0, -self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
		[nextPage setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
	} completion:^(BOOL finished){
		[currentPage removeEasingFunctionForKeyPath:@"frame"];
		[nextPage removeEasingFunctionForKeyPath:@"frame"];
		
		[currentPage setFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
	}];
	
	liveTilePageIndex++;
	if (liveTilePageIndex >= liveTile.subviews.count) {
		liveTilePageIndex = 0;
	}
}

- (void)addBulletin:(BBBulletin*)bulletin {
	if (![liveTile isKindOfClass:NSClassFromString(@"RSTileNotificationView")]) {
		return;
	}
	
	[(RSTileNotificationView*)liveTile addBulletin:bulletin delayIncomingBulletins:YES];
}
- (void)removeBulletin:(BBBulletin*)bulletin {
	if (![liveTile isKindOfClass:NSClassFromString(@"RSTileNotificationView")]) {
		return;
	}
	[(RSTileNotificationView*)liveTile removeBulletin:bulletin];
}*/

// GESTURE RECOGNIZER METHODS

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return YES;
}

- (void)tapped:(UITapGestureRecognizer*)_tapGestureRecognizer {
	if ([[RSStartScreenController sharedInstance] isEditing]) {
		if ([[RSStartScreenController sharedInstance] selectedTile] == self) {
			[[RSStartScreenController sharedInstance] setIsEditing:NO];
			//[longPressGestureRecognizer setEnabled:YES];
		} else {
			[[RSStartScreenController sharedInstance] setSelectedTile:self];
		}
	} else {
		[self untilt];
		[[RSStartScreenController sharedInstance] prepareForAppLaunch:self];
	}
}

- (void)pressed:(UILongPressGestureRecognizer*)_longPressGestureRecognizer {
	shouldAllowPan = NO;
	
	if (![[RSStartScreenController sharedInstance] isEditing]) {
		[tapGestureRecognizer setEnabled:NO];
		[tapGestureRecognizer setEnabled:YES];
		
		[[RSStartScreenController sharedInstance] setIsEditing:YES];
		[[RSStartScreenController sharedInstance] setSelectedTile:self];
		
		[longPressGestureRecognizer setEnabled:NO];
	}
}

- (void)moveViewWithGestureRecognizer:(UIPanGestureRecognizer *)_panGestureRecognizer {
	CGPoint touchLocation = [_panGestureRecognizer locationInView:self.superview];
	
	if (_panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
		[[RSStartScreenController sharedInstance] setSelectedTile:self];
		
		CGPoint relativePosition = [self.superview convertPoint:self.center toView:self.superview];
		centerOffset = CGPointMake(relativePosition.x - touchLocation.x, relativePosition.y - touchLocation.y);
	}
	
	if (_panGestureRecognizer.state == UIGestureRecognizerStateChanged && shouldAllowPan) {
		self.center = CGPointMake(touchLocation.x + centerOffset.x, touchLocation.y + centerOffset.y);
	}
	
	if (_panGestureRecognizer.state == UIGestureRecognizerStateEnded && shouldAllowPan) {
		centerOffset = CGPointZero;
		
		[[RSStartScreenController sharedInstance] snapTile:self withTouchPosition:self.center];
	}
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	if (self.isSelectedTile) {
		if (CGRectContainsPoint(unpinButton.frame, point)) {
			
			[tapGestureRecognizer setEnabled:NO];
			[panGestureRecognizer setEnabled:NO];
			return unpinButton;
		} else if (CGRectContainsPoint(scaleButton.frame, point)) {
			
			[tapGestureRecognizer setEnabled:NO];
			[panGestureRecognizer setEnabled:NO];
			return scaleButton;
		}
	}
	
	[tapGestureRecognizer setEnabled:YES];
	[panGestureRecognizer setEnabled:YES];
	
	return [super hitTest:point withEvent:event];
}

@end
