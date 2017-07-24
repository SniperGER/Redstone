#import "../Redstone.h"

extern dispatch_queue_t __BBServerQueue;

@implementation RSTile

- (id)initWithFrame:(CGRect)frame leafIdentifier:(NSString*)leafIdentifier size:(int)size {
	if (self = [super initWithFrame:frame]) {
		self.size = size;
		self.icon = [[(SBIconController*)[objc_getClass("SBIconController") sharedInstance] model] leafIconForIdentifier:leafIdentifier];
		self.tileInfo = [[RSTileInfo alloc] initWithBundleIdentifier:leafIdentifier];
		self.originalCenter = self.center;
		
		[self setBackgroundColor:[RSAesthetics accentColorForTile:self.tileInfo]];
		
		tileWrapper = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		[tileWrapper setClipsToBounds:YES];
		[self addSubview:tileWrapper];
		
		tileContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		[tileWrapper addSubview:tileContainer];
		
		// Title Label
		[[self titleLabel] removeFromSuperview];
		tileLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, self.frame.size.height - 28, self.frame.size.width - 16, 20)];
		[tileLabel setFont:[UIFont fontWithName:@"SegoeUI" size:14]];
		[tileLabel setTextAlignment:NSTextAlignmentLeft];
		[tileLabel setTextColor:[RSAesthetics readableForegroundColorForBackgroundColor:self.backgroundColor]];
		[tileContainer addSubview:tileLabel];
		
		if (self.tileInfo.localizedDisplayName) {
			[tileLabel setText:self.tileInfo.localizedDisplayName];
		} else if (self.tileInfo.displayName) {
			[tileLabel setText:self.tileInfo.displayName];
		} else {
			[tileLabel setText:[self.icon displayName]];
		}
		
		if (self.size < 2 || self.tileInfo.tileHidesLabel || [[self.tileInfo.labelHiddenForSizes objectForKey:[[NSNumber numberWithInt:self.size] stringValue]] boolValue]) {
			[tileLabel setHidden:YES];
		} else {
			[tileLabel setHidden:NO];
		}
		
		// Tile Icon
		if (self.tileInfo.fullSizeArtwork) {
			tileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
			[tileImageView setImage:[RSAesthetics getImageForTileWithBundleIdentifier:[self.icon applicationBundleID] size:self.size colored:YES]];
			[tileContainer addSubview:tileImageView];
		} else {
			CGSize tileImageSize = [RSMetrics tileIconDimensionsForSize:size];
			tileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tileImageSize.width, tileImageSize.height)];
			[tileImageView setCenter:CGPointMake(frame.size.width/2, frame.size.height/2)];
			
			[tileImageView setImage:[RSAesthetics getImageForTileWithBundleIdentifier:[self.icon applicationBundleID] size:5 colored:self.tileInfo.hasColoredIcon]];
			[tileImageView setTintColor:[UIColor whiteColor]];
			[tileContainer addSubview:tileImageView];
		}
		
		// Badge
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
		
		// Live Tile
		if ([[[RSPreferences preferences] objectForKey:@"debugLiveTiles"] boolValue]) {
			NSBundle* liveTileBundle = [NSBundle bundleWithPath:[NSString stringWithFormat:@"%@/Live Tiles/%@.tile", RESOURCE_PATH, leafIdentifier]];
			if (liveTileBundle) {
				liveTile = [[[liveTileBundle principalClass] alloc] initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, frame.size.height) tile:self];
			} else if (self.tileInfo.displaysNotificationsOnTile) {
				liveTile = [[RSTileNotificationView alloc] initWithFrame:CGRectMake(0, frame.size.height , frame.size.width, frame.size.height) tile:self];
			}
			
			if (liveTile) {
				[liveTile setClipsToBounds:YES];
				[tileWrapper addSubview:liveTile];
				
				if (![[objc_getClass("SBUserAgent") sharedUserAgent] deviceIsLocked]) {
					[self startLiveTile];
				}
			}
		}
		
		// Gesture Recognizers
		longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressed:)];
		[longPressGestureRecognizer setMinimumPressDuration:0.5];
		[longPressGestureRecognizer setCancelsTouchesInView:NO];
		[longPressGestureRecognizer setDelaysTouchesBegan:NO];
		[self addGestureRecognizer:longPressGestureRecognizer];
		
		panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panMoved:)];
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
		
		// Editing Mode Buttons
		unpinButton = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
		[unpinButton setCenter:CGPointMake(frame.size.width, 0)];
		[unpinButton setBackgroundColor:[RSAesthetics colorsForCurrentTheme][@"InvertedBackgroundColor"]];
		[unpinButton.layer setCornerRadius:15];
		[unpinButton setHidden:YES];
		[self addSubview:unpinButton];
		
		UILabel* unpinLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
		[unpinLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:14]];
		[unpinLabel setTextColor:[RSAesthetics colorsForCurrentTheme][@"InvertedForegroundColor"]];
		[unpinLabel setText:@"\uE77A"];
		[unpinLabel setTextAlignment:NSTextAlignmentCenter];
		[unpinButton addSubview:unpinLabel];
		
		unpinGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(unpin)];
		[unpinButton addGestureRecognizer:unpinGestureRecognizer];
		
		scaleButton = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
		[scaleButton setCenter:CGPointMake(frame.size.width, frame.size.height)];
		[scaleButton setBackgroundColor:[RSAesthetics colorsForCurrentTheme][@"InvertedBackgroundColor"]];
		[scaleButton.layer setCornerRadius:15];
		[scaleButton setHidden:YES];
		[scaleButton setTransform:CGAffineTransformMakeRotation(deg2rad([self scaleButtonRotationForCurrentSize]))];
		[self addSubview:scaleButton];
		
		UILabel* scaleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
		[scaleLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:14]];
		[scaleLabel setTextColor:[RSAesthetics colorsForCurrentTheme][@"InvertedForegroundColor"]];
		[scaleLabel setText:@"\uE7EA"];
		[scaleLabel setTextAlignment:NSTextAlignmentCenter];
		[scaleButton addSubview:scaleLabel];
		
		scaleGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setNextSize)];
		[scaleButton addGestureRecognizer:scaleGestureRecognizer];
	}
	
	return self;
}

float customRounding(float value) {
	const float roundingValue = 0.5;
	int mulitpler = floor(value / roundingValue);
	return mulitpler * roundingValue;
}

- (CGRect)basePosition {
	float width = customRounding(self.bounds.size.width);
	float height = customRounding(self.bounds.size.height);
	
	return CGRectMake(self.layer.position.x - (width/2),
					  self.layer.position.y - (height/2),
					  width,
					  height);
}

- (NSString*)displayName {
	return tileLabel.text;
}

- (void)removeFromSuperview {
	[self stopLiveTile];
	
	if ([liveTile respondsToSelector:@selector(prepareForRemoval)]) {
		[liveTile prepareForRemoval];
	}
	
	liveTile.tile = nil;
	liveTile = nil;
	[super removeFromSuperview];
}

#pragma mark Gesture Recognizers

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return YES;
}

- (void)tapped:(UITapGestureRecognizer*)gestureRecognizer {
	if ([[[RSHomeScreenController sharedInstance] startScreenController] isEditing]) {
		if ([[[RSHomeScreenController sharedInstance] startScreenController] selectedTile] == self) {
			[[[RSHomeScreenController sharedInstance] startScreenController] setIsEditing:NO];
			//[longPressGestureRecognizer setEnabled:YES];
		} else {
			[[[RSHomeScreenController sharedInstance] startScreenController] setSelectedTile:self];
		}
	} else {
		self.icon = [[(SBIconController*)[objc_getClass("SBIconController") sharedInstance] model] leafIconForIdentifier:[self.icon applicationBundleID]];
		
		[self setTransform:CGAffineTransformIdentity];
		[[[RSHomeScreenController sharedInstance] launchScreenController] setLaunchIdentifier:[self.icon applicationBundleID]];
		[[objc_getClass("SBIconController") sharedInstance] _launchIcon:self.icon];
	}
}

- (void)pressed:(UILongPressGestureRecognizer*)gestureRecognizer {
	panEnabled = NO;
	
	if (![[[RSHomeScreenController sharedInstance] startScreenController] isEditing]) {
		[tapGestureRecognizer setEnabled:NO];
		[tapGestureRecognizer setEnabled:YES];
		
		[[[RSHomeScreenController sharedInstance] startScreenController] setIsEditing:YES];
		[[[RSHomeScreenController sharedInstance] startScreenController] setSelectedTile:self];
		
		[longPressGestureRecognizer setEnabled:NO];
	}
}

- (void)panMoved:(UIPanGestureRecognizer*)gestureRecognizer {
	CGPoint touchLocation = [gestureRecognizer locationInView:self.superview];
	
	if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
		[[[RSHomeScreenController sharedInstance] startScreenController] setSelectedTile:self];
		
		CGPoint relativePosition = [self.superview convertPoint:self.center toView:self.superview];
		centerOffset = CGPointMake(relativePosition.x - touchLocation.x, relativePosition.y - touchLocation.y);
		
		[unpinButton setHidden:YES];
		[scaleButton setHidden:YES];
	}
	
	if (gestureRecognizer.state == UIGestureRecognizerStateChanged && panEnabled) {
		self.center = CGPointMake(touchLocation.x + centerOffset.x, touchLocation.y + centerOffset.y);
	}
	
	if (gestureRecognizer.state == UIGestureRecognizerStateEnded && panEnabled) {
		centerOffset = CGPointZero;
		
		[[[RSHomeScreenController sharedInstance] startScreenController] snapTile:self withTouchPosition:self.center];
		
		[unpinButton setHidden:NO];
		[scaleButton setHidden:NO];
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

#pragma mark Editing Mode

- (void)setIsSelectedTile:(BOOL)isSelectedTile {
	if ([[[RSHomeScreenController sharedInstance] startScreenController] isEditing]) {
		_isSelectedTile = isSelectedTile;
		
		[self.layer removeAllAnimations];
		
		if (isSelectedTile) {
			panEnabled = YES;
			
			[[(UIScrollView*)[[[RSHomeScreenController sharedInstance] startScreenController] view] panGestureRecognizer] setEnabled:NO];
			[[(UIScrollView*)[[[RSHomeScreenController sharedInstance] startScreenController] view] panGestureRecognizer] setEnabled:YES];
			
			
			[self.superview bringSubviewToFront:self];
			[self setAlpha:1.0];
			[self setTransform:CGAffineTransformMakeScale(1.05, 1.05)];
			
			[unpinButton setHidden:NO];
			[scaleButton setHidden:NO];
		} else {
			panEnabled = NO;
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
		panEnabled = NO;
		
		[unpinButton setHidden:YES];
		[scaleButton setHidden:YES];
	}
}

- (void)unpin {
	[[[RSHomeScreenController sharedInstance] startScreenController] unpinTile:self];
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
	CGFloat step = [RSMetrics tileDimensionsForSize:1].width + [RSMetrics tileBorderSpacing];
	
	CGFloat maxPositionX = [[[RSHomeScreenController sharedInstance] startScreenController] view].bounds.size.width - newTileSize.width;
	CGFloat maxPositionY = [(UIScrollView*)[[[RSHomeScreenController sharedInstance] startScreenController] view] contentSize].height + [RSMetrics tileBorderSpacing];
	
	CGRect newFrame = CGRectMake(MIN(MAX(step * roundf((self.basePosition.origin.x / step)), 0), maxPositionX),
								 MIN(MAX(step * roundf((self.basePosition.origin.y / step)), 0), maxPositionY),
								 newTileSize.width,
								 newTileSize.height);
	
	CGAffineTransform currentTransform = self.transform;
	
	[self setTransform:CGAffineTransformIdentity];
	[self setFrame:newFrame];
	[self setTransform:currentTransform];
	
	[tileWrapper setFrame:CGRectMake(0, 0, newFrame.size.width, newFrame.size.height)];
	
	if (liveTile) {
		[tileContainer setFrame:CGRectMake(0, tileContainer.frame.origin.y, self.bounds.size.width, self.bounds.size.height)];
		[liveTile setFrame:CGRectMake(0, liveTile.frame.origin.y, self.bounds.size.width, self.bounds.size.height)];
		
		if ([liveTile isKindOfClass:[RSTileNotificationView class]]) {
			[self setLiveTileHidden:(self.size < 2 || ![liveTile readyForDisplay])];
		} else {
			[self startLiveTile];
		}
	}
	
	if (self.size < 2 || self.tileInfo.tileHidesLabel || [[self.tileInfo.labelHiddenForSizes objectForKey:[[NSNumber numberWithInt:self.size] stringValue]] boolValue]) {
		[tileLabel setHidden:YES];
	} else {
		[tileLabel setHidden:NO];
		[tileLabel setFrame:CGRectMake(8,
									   newFrame.size.height - tileLabel.frame.size.height - 8,
									   tileLabel.frame.size.width,
									   tileLabel.frame.size.height)];
	}
	
	if (self.tileInfo.fullSizeArtwork) {
		[tileImageView setFrame:CGRectMake(0, 0, newFrame.size.width, newFrame.size.height)];
		[tileImageView setImage:[RSAesthetics getImageForTileWithBundleIdentifier:[self.icon applicationBundleID] size:self.size colored:YES]];
	} else {
		CGSize tileImageSize = [RSMetrics tileIconDimensionsForSize:self.size];
		[tileImageView setFrame:CGRectMake(0, 0, tileImageSize.width, tileImageSize.height)];
		[tileImageView setCenter:CGPointMake(newFrame.size.width/2, newFrame.size.height/2)];
		
		[tileImageView setImage:[RSAesthetics getImageForTileWithBundleIdentifier:[self.icon applicationBundleID] size:self.size colored:self.tileInfo.hasColoredIcon]];
		[tileImageView setTintColor:[UIColor whiteColor]];
	}
	
	[unpinButton setCenter:CGPointMake(newFrame.size.width, 0)];
	[scaleButton setCenter:CGPointMake(newFrame.size.width, newFrame.size.height)];
	
	[scaleButton setTransform:CGAffineTransformMakeRotation(deg2rad([self scaleButtonRotationForCurrentSize]))];
	
	[[[RSHomeScreenController sharedInstance] startScreenController] moveAffectedTilesForTile:self];
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

#pragma mark Live Tile

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
	
	if ([liveTile isKindOfClass:[RSTileNotificationView class]]) {
		[(RSTileNotificationView*)liveTile setBadge:badgeCount];
	}
}

- (int)badgeCount {
	return badgeValue;
}

- (void)startLiveTile {
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
	
	if ([liveTile respondsToSelector:@selector(hasStarted)]) {
		[liveTile hasStarted];
	}
	
	if ([liveTile readyForDisplay]) {
		if ([liveTile isKindOfClass:[RSTileNotificationView class]] && self.size < 2) {
			[self setLiveTileHidden:YES];
		} else {
			[self setLiveTileHidden:NO];
		}
	}
	
	if ([liveTile updateInterval] > 0) {
		liveTileUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:[liveTile updateInterval] target:liveTile selector:@selector(update) userInfo:nil repeats:YES];
		[[NSRunLoop mainRunLoop] addTimer:liveTileUpdateTimer forMode:NSRunLoopCommonModes];
	}
	
	NSArray* viewsForSize = [liveTile viewsForSize:self.size];
	if (viewsForSize != nil && viewsForSize.count > 0) {
		[[liveTile subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
		for (int i=0; i<viewsForSize.count; i++) {
			[[viewsForSize objectAtIndex:i] setFrame:CGRectMake(0, (i > 0) ? self.bounds.size.height : 0, self.bounds.size.width, self.bounds.size.height)];
			[liveTile addSubview:[viewsForSize objectAtIndex:i]];
		}
	}
	
	liveTilePageIndex = 0;
	if (viewsForSize.count > 1 || [liveTile respondsToSelector:@selector(triggerAnimation)]) {
		for (int i=0; i<viewsForSize.count; i++) {
			[[viewsForSize objectAtIndex:i] setFrame:CGRectMake(0, (i > 0) ? self.bounds.size.height : 0, self.bounds.size.width, self.bounds.size.height)];
		}
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((arc4random_uniform(4) * 0.5)  * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			liveTileAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:6.0 target:self selector:@selector(displayNextLiveTilePage) userInfo:nil repeats:YES];
			[[NSRunLoop mainRunLoop] addTimer:liveTileAnimationTimer forMode:NSRunLoopCommonModes];
		});
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
	
	if ([liveTile respondsToSelector:@selector(hasStopped)]) {
		[liveTile hasStopped];
	}
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
		[liveTile triggerAnimation];
		return;
	}
	
	NSArray* viewsForCurrentSize = [liveTile viewsForSize:self.size];
	UIView* currentPage = [viewsForCurrentSize objectAtIndex:liveTilePageIndex];
	UIView* nextPage = [viewsForCurrentSize objectAtIndex:(liveTilePageIndex+1 >= liveTile.subviews.count) ? 0 : liveTilePageIndex+1];
	
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
}

@end
