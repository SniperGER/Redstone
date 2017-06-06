#import "../Redstone.h"

@implementation RSTile

- (id)initWithFrame:(CGRect)frame leafIdentifier:(NSString*)leafId size:(int)tileSize {
	self = [super initWithFrame:frame];
	
	if (self) {
		self.size = tileSize;
		self.tileInfo = [[RSTileInfo alloc] initWithBundleIdentifier:leafId];
		self.icon = [[[objc_getClass("SBIconController") sharedInstance] model] leafIconForIdentifier:leafId];
		self.originalCenter = self.center;
		
		[self.titleLabel removeFromSuperview];
		
		tileWrapper = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		[tileWrapper setClipsToBounds:YES];
		[self addSubview:tileWrapper];
		
		tileContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		[tileWrapper addSubview:tileContainer];
		
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
									   tileLabel.frame.size.width,
									   tileLabel.frame.size.height)];
		[tileContainer addSubview:tileLabel];
		
		if (self.size < 2 || self.tileInfo.tileHidesLabel || [[self.tileInfo.labelHiddenForSizes objectForKey:[[NSNumber numberWithInt:self.size] stringValue]] boolValue]) {
			[tileLabel setHidden:YES];
		} else {
			[tileLabel setHidden:NO];
		}
		
		if (self.tileInfo.fullSizeArtwork) {
			tileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
			[tileImageView setImage:[RSAesthetics getImageForTileWithBundleIdentifier:[[self.icon application] bundleIdentifier] size:self.size colored:YES]];
			[tileContainer addSubview:tileImageView];
		} else {
			CGSize tileImageSize = [RSMetrics tileIconDimensionsForSize:tileSize];
			tileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tileImageSize.width, tileImageSize.height)];
			[tileImageView setCenter:CGPointMake(frame.size.width/2, frame.size.height/2)];
			
			if (self.tileInfo.hasColoredIcon) {
				[tileImageView setImage:[RSAesthetics getImageForTileWithBundleIdentifier:[[self.icon application] bundleIdentifier]]];
			} else {
				[tileImageView setImage:[RSAesthetics getImageForTileWithBundleIdentifier:[[self.icon application] bundleIdentifier]]];
				[tileImageView setTintColor:[UIColor whiteColor]];
			}
			[tileContainer addSubview:tileImageView];
		}
		
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
		[self addSubview:badgeLabel];
		
		[self setBackgroundColor:[RSAesthetics accentColorForTile:self.tileInfo]];
		
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
		
		if ([[self.icon application] badgeNumberOrString] != nil) {
			[self setBadge:[[[self.icon application] badgeNumberOrString] intValue]];
		}
		
		NSBundle* liveTileBundle = [NSBundle bundleWithPath:[NSString stringWithFormat:@"%@/Live Tiles/%@.tile", RESOURCE_PATH, leafId]];
		if (liveTileBundle) {
			liveTile = [[[liveTileBundle principalClass] alloc] initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, frame.size.height)];
			[liveTile setClipsToBounds:YES];
			[liveTile setTile:self];
			[tileWrapper addSubview:liveTile];
			
			if ([liveTile hasMultiplePages]) {
				[[liveTile subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
				
				NSArray* viewsForSize = [liveTile viewsForSize:self.size];
				for (int i=0; i<viewsForSize.count; i++) {
					[[viewsForSize objectAtIndex:i] setFrame:CGRectMake(0, (i > 0) ? self.bounds.size.height : 0, self.bounds.size.width, self.bounds.size.height)];
					[liveTile addSubview:[viewsForSize objectAtIndex:i]];
				}
			}
			
			if ([liveTile tileUpdateInterval] > 0) {
				//liveTileUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:[liveTile tileUpdateInterval] target:self selector:@selector(updateLiveTile) userInfo:nil repeats:YES];
			}
		}
	}
	
	return self;
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return YES;
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

- (void)tapped:(UITapGestureRecognizer*)_tapGestureRecognizer {
	if ([[RSStartScreenController sharedInstance] isEditing]) {
		if ([[RSStartScreenController sharedInstance] selectedTile] == self) {
			[[RSStartScreenController sharedInstance] setIsEditing:NO];
			[longPressGestureRecognizer setEnabled:YES];
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
	
	if (self.tileInfo.fullSizeArtwork) {
		[tileImageView setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
		[tileImageView setImage:[RSAesthetics getImageForTileWithBundleIdentifier:[[self.icon application] bundleIdentifier] size:self.size colored:YES]];
	} else {
		CGSize tileImageSize = [RSMetrics tileIconDimensionsForSize:self.size];
		[tileImageView setFrame:CGRectMake(0, 0, tileImageSize.width, tileImageSize.height)];
		[tileImageView setCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)];
		
		if (self.tileInfo.hasColoredIcon) {
			[tileImageView setImage:[RSAesthetics getImageForTileWithBundleIdentifier:[[self.icon application] bundleIdentifier]]];
		} else {
			[tileImageView setImage:[[RSAesthetics getImageForTileWithBundleIdentifier:[[self.icon application] bundleIdentifier]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
			[tileImageView setTintColor:[UIColor whiteColor]];
		}
	}
	
	if (self.size < 2 || self.tileInfo.tileHidesLabel || [[self.tileInfo.labelHiddenForSizes objectForKey:[[NSNumber numberWithInt:self.size] stringValue]] boolValue] || liveTile != nil) {
		[tileLabel setHidden:YES];
	} else {
		[tileLabel setHidden:NO];
		[tileLabel setFrame:CGRectMake(8,
									   self.frame.size.height - tileLabel.frame.size.height - 8,
									   tileLabel.frame.size.width,
									   tileLabel.frame.size.height)];
	}
	
	if (liveTile) {
		[tileWrapper setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
		[liveTile setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
		
		liveTilePageIndex = 0;
		
		[[liveTile subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
		[liveTileAnimationTimer invalidate];
		liveTileAnimationTimer = nil;
		
		NSArray* viewsForSize = [liveTile viewsForSize:self.size];
		for (int i=0; i<viewsForSize.count; i++) {
			[[viewsForSize objectAtIndex:i] setFrame:CGRectMake(0, (i > 0) ? self.bounds.size.height : 0, self.bounds.size.width, self.bounds.size.height)];
			[liveTile addSubview:[viewsForSize objectAtIndex:i]];
		}
		
		if (viewsForSize.count > 1 && ![liveTile keepsLiveTilePage]) {
			liveTileAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(showNextLiveTilePage) userInfo:nil repeats:YES];
		}
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
		default:
			return 0.0;
			break;
			
	}
}

- (CGRect)positionWithoutTransform {	
	return CGRectMake(self.layer.position.x - (self.bounds.size.width/2),
					  self.layer.position.y - (self.bounds.size.height/2),
					  self.bounds.size.width,
					  self.bounds.size.height);
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

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
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

- (void)setBadge:(int)badgeCount {
	//badgeCount = MIN(badgeCount, 99);
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
	
	/*CGSize tileImageSize = [RSMetrics tileIconDimensionsForSize:self.size];
	
	if (!badgeCount || badgeCount == 0) {
			} else {
		if (self.size < 2) {
			[badgeLabel setFont:[UIFont fontWithName:@"SegoeUI" size:24]];
		} else {
			[badgeLabel setFont:[UIFont fontWithName:@"SegoeUI" size:36]];
		}

		[badgeLabel setText:[NSString stringWithFormat:@"%d", badgeCount]];
		[badgeLabel sizeToFit];
		
		CGSize combinedSize = CGSizeMake(tileImageSize.width + badgeLabel.frame.size.width + 5, tileImageSize.height);
		
		[tileImageView setCenter:CGPointMake(self.bounds.size.width/2 - (combinedSize.width - tileImageView.frame.size.width)/2, self.bounds.size.height/2)];
		[badgeLabel setCenter:CGPointMake(self.bounds.size.width/2 + (combinedSize.width - badgeLabel.frame.size.width)/2, self.bounds.size.height/2)];
		
		[badgeLabel setHidden:NO];
	}*/
}

- (void)setLiveTileIsReady {
	if (liveTile == nil) {
		return;
	}
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(rand()%3+1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		if (liveTile.subviews.count > 1 && ![liveTile keepsLiveTilePage]) {
			liveTileAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:6.0 target:self selector:@selector(showNextLiveTilePage) userInfo:nil repeats:YES];
		}
		
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
			
			[tileContainer setFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
		}];
	});
}

- (void)startLiveTile {
	if (liveTileAnimationTimer) {
		[liveTileAnimationTimer invalidate];
		liveTileAnimationTimer = nil;
	}
	
	if (liveTileUpdateTimer) {
		[liveTileUpdateTimer invalidate];
		liveTileUpdateTimer = nil;
	}
	
	if ([liveTile tileUpdateInterval] > 0) {
		liveTileUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:[liveTile tileUpdateInterval] target:self selector:@selector(updateLiveTile) userInfo:nil repeats:YES];
	}
	
	[liveTile prepareForUpdate];
	
	if ([liveTile isReadyForShow]) {
		[self setLiveTileIsReady];
	}
}

- (void)stopLiveTile {
	if (liveTile == nil) {
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
	
	[tileContainer setFrame:CGRectMake(0, -self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
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

- (void)updateLiveTile {
	if (![[objc_getClass("SBUserAgent") sharedUserAgent] deviceIsLocked] && ![[RSCore sharedInstance] currentApplication]) {
		[liveTile prepareForUpdate];
	} else {
		[self stopLiveTile];
	}
}

- (void)showNextLiveTilePage {
	if (!liveTile || [liveTile subviews].count < 1 || ![liveTile isReadyForShow]) {
		return;
	}
	if ([[objc_getClass("SBUserAgent") sharedUserAgent] deviceIsLocked]) {
		[self stopLiveTile];
		return;
	}
	
	UIView* currentPage = [[liveTile subviews] objectAtIndex:liveTilePageIndex];
	UIView* nextPage = [[liveTile subviews] objectAtIndex:(liveTilePageIndex+1 >= liveTile.subviews.count) ? 0 : liveTilePageIndex+1];
	
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

@end
