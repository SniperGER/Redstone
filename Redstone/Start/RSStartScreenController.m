#import "../Redstone.h"

@implementation RSStartScreenController

static RSStartScreenController* sharedInstance;

+ (id)sharedInstance {
	return sharedInstance;
}

- (id)init {
	self = [super init];
	
	if (self) {
		sharedInstance = self;
		self.startScrollView = [[RSStartScrollView alloc] initWithFrame:CGRectMake(4, 0, screenWidth-8, screenHeight)];
		[self loadTiles];
	}
	
	return self;
}

- (void)loadTiles {
	self->pinnedTiles = [NSMutableArray new];
	self->pinnedLeafIdentifiers = [NSMutableArray new];
	
	NSArray* tileLayout = [[RSPreferences preferences] objectForKey:[NSString stringWithFormat:@"%iColumnLayout", [RSMetrics columns]]];;
	
	for (int i=0; i<[tileLayout count]; i++) {
		if ([[[objc_getClass("SBIconController") sharedInstance] model] leafIconForIdentifier:[tileLayout objectAtIndex:i][@"bundleIdentifier"]]) {
			
			CGFloat sizeForPosition = [RSMetrics tileDimensionsForSize:1].width + [RSMetrics tileBorderSpacing];
			CGSize tileSize = [RSMetrics tileDimensionsForSize:[[tileLayout objectAtIndex:i][@"size"] intValue]];
			
			CGRect tileFrame = CGRectMake(sizeForPosition * [[tileLayout objectAtIndex:i][@"column"] intValue],
										   sizeForPosition * [[tileLayout objectAtIndex:i][@"row"] intValue],
										   tileSize.width,
										   tileSize.height);
			
			RSTile* tile = [[RSTile alloc] initWithFrame:tileFrame leafIdentifier:[tileLayout objectAtIndex:i][@"bundleIdentifier"] size:[[tileLayout objectAtIndex:i][@"size"] intValue]];
			[tile setTileX:[[tileLayout objectAtIndex:i][@"column"] intValue]];
			[tile setTileY:[[tileLayout objectAtIndex:i][@"row"] intValue]];
			
			[self.startScrollView addSubview:tile];
			
			[self->pinnedTiles addObject:tile];
			[self->pinnedLeafIdentifiers addObject:[tileLayout objectAtIndex:i][@"bundleIdentifier"]];
		}
	}
	
	[self updateStartContentSize];
}

- (void)saveTiles {
	NSMutableArray* tilesToSave = [NSMutableArray new];
	
	for (RSTile* tile in self->pinnedTiles) {
		NSMutableDictionary* tileInfo = [NSMutableDictionary new];
		
		[tileInfo setValue:[NSNumber numberWithInteger:tile.size] forKey:@"size"];
		[tileInfo setValue:[NSNumber numberWithInteger:tile.tileY] forKey:@"row"];
		[tileInfo setValue:[NSNumber numberWithInteger:tile.tileX] forKey:@"column"];
		[tileInfo setValue:[[tile.icon application] bundleIdentifier] forKey:@"bundleIdentifier"];
		
		[tilesToSave addObject:tileInfo];
	}
	
	[RSPreferences setValue:tilesToSave forKey:[NSString stringWithFormat:@"%iColumnLayout", [RSMetrics columns]]];
}

- (void)updateStartContentSize {
	RSTile* lastTile = [self->pinnedTiles objectAtIndex:0];
	
	for (RSTile* tile in self->pinnedTiles) {
		CGRect lastTileFrame = [lastTile positionWithoutTransform];
		CGRect currentTileFrame = [tile positionWithoutTransform];
		
		if (currentTileFrame.origin.y > lastTileFrame.origin.y || (currentTileFrame.origin.y == lastTileFrame.origin.y && currentTileFrame.size.height > lastTileFrame.size.height)) {
			lastTile = tile;
		}
	}

	CGSize contentSize = CGSizeMake(self.startScrollView.frame.size.width,
									[lastTile positionWithoutTransform].origin.y + [lastTile positionWithoutTransform].size.height);
	[self.startScrollView setContentSize:contentSize];
}

- (void)moveAffectedTilesForTile:(RSTile*)movedTile {
	// This algorithm is based on Daniel T.'s answer here:
	// http://stackoverflow.com/questions/43825803/get-all-uiviews-affected-by-moving-another-uiview-above-them/
	
	NSMutableArray* stack = [NSMutableArray new];
	
	[stack addObject:movedTile];
	
	while ([stack count] > 0) {
		RSTile* current = [stack objectAtIndex:0];
		[stack removeObject:current];
		
		for (RSTile* tile in self->pinnedTiles) {
			if (tile != current && CGRectIntersectsRect([current positionWithoutTransform], [tile positionWithoutTransform])) {
				[stack addObject:tile];
				
				CGFloat moveDistance = (CGRectGetMaxY([current positionWithoutTransform]) - CGRectGetMinY([tile positionWithoutTransform])) + [RSMetrics tileBorderSpacing];
				CGRect newFrame = CGRectMake(tile.frame.origin.x,
											 tile.frame.origin.y + moveDistance,
											 tile.frame.size.width,
											 tile.frame.size.height);
				
				int tileX = newFrame.origin.x / ([RSMetrics tileDimensionsForSize:1].width + [RSMetrics tileBorderSpacing]);
				int tileY = newFrame.origin.y / ([RSMetrics tileDimensionsForSize:1].height + [RSMetrics tileBorderSpacing]);
				
				[tile setTileX:tileX];
				[tile setTileY:tileY];
				
				[UIView animateWithDuration:.3 animations:^{
					[tile setEasingFunction:easeOutQuint forKeyPath:@"frame"];
					[tile setFrame:newFrame];
				} completion:^(BOOL finished) {
					[tile removeEasingFunctionForKeyPath:@"frame"];
					[tile setOriginalCenter:tile.center];
				}];
				
			}
		}
	}
	
	[self saveTiles];
	[self updateStartContentSize];
}

- (void)prepareForAppLaunch:(RSTile*)sender {
	[[[RSCore sharedInstance] rootScrollView] setUserInteractionEnabled:NO];
	[[RSLaunchScreenController sharedInstance] setLaunchScreenForLeafIdentifier:[[sender.icon application] bundleIdentifier]];
	
	NSMutableArray* appsInView = [NSMutableArray new];
	NSMutableArray* appsNotInView = [NSMutableArray new];
	
	for (RSTile* tile in self->pinnedTiles) {
		if (CGRectIntersectsRect(self.startScrollView.bounds, tile.frame)) {
			[appsInView addObject:tile];
		} else {
			[appsNotInView addObject:tile];
		}
	}
	
	for (RSTile* tile in appsNotInView) {
		[tile setHidden:YES];
	}
	
	CAAnimation* scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"
														  function:CubicEaseIn
														 fromValue:1.0
														   toValue:4.0];
	[scale setDuration:0.225];
	[scale setRemovedOnCompletion:NO];
	[scale setFillMode:kCAFillModeForwards];
	
	CAAnimation* opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
														  function:CubicEaseIn
														 fromValue:1.0
														   toValue:0.0];
	[opacity setDuration:0.2];
	[opacity setRemovedOnCompletion:NO];
	[opacity setFillMode:kCAFillModeForwards];
	
	int minX = INT_MAX, maxX = INT_MIN, minY = INT_MAX, maxY = INT_MIN;
	for (RSTile* tile in self->pinnedTiles) {
		CGFloat tileX = tile.frame.origin.x / ([RSMetrics tileDimensionsForSize:1].width + [RSMetrics tileBorderSpacing]);
		CGFloat tileY = tile.frame.origin.y / ([RSMetrics tileDimensionsForSize:1].height + [RSMetrics tileBorderSpacing]);
		
		minX = MIN(tileX, minX);
		maxX = MAX(tileX, maxX);
		
		minY = MIN(tileY, minY);
		maxY = MAX(tileY, maxY);
	}
	
	float maxDelay = ((maxY - minY) * 0.01) + (maxX * 0.01);
	
	for (RSTile* tile in appsInView) {
		[tile.layer setShouldRasterize:YES];
		[tile.layer setRasterizationScale:[[UIScreen mainScreen] scale]];
		[tile.layer setContentsScale:[[UIScreen mainScreen] scale]];
		
		CGPoint basePoint = [tile convertPoint:tile.bounds.origin toView:self.startScrollView];
		
		CGFloat layerX = -(basePoint.x - CGRectGetMidX(self.startScrollView.bounds))/tile.frame.size.width;
		CGFloat layerY = -(basePoint.y - CGRectGetMidY(self.startScrollView.bounds))/tile.frame.size.height;
		
		CGFloat tileX = tile.frame.origin.x / ([RSMetrics tileDimensionsForSize:1].width + [RSMetrics tileBorderSpacing]);
		CGFloat tileY = tile.frame.origin.y / ([RSMetrics tileDimensionsForSize:1].height + [RSMetrics tileBorderSpacing]);
		
		CGFloat delay = (tileX * 0.01) + (tileY - minY) * 0.01;
		
		[tile setCenter:CGPointMake(CGRectGetMidX(self.startScrollView.bounds),
									CGRectGetMidY(self.startScrollView.bounds))];
		[tile.layer setAnchorPoint:CGPointMake(layerX, layerY)];
		
		if (tile == sender) {
			[scale setBeginTime:CACurrentMediaTime() + delay + 0.1];
			[opacity setBeginTime:CACurrentMediaTime() + delay + 0.1];
		} else {
			[scale setBeginTime:CACurrentMediaTime() + delay];
			[opacity setBeginTime:CACurrentMediaTime() + delay];
		}
		
		[tile.layer addAnimation:scale forKey:@"scale"];
		[tile.layer addAnimation:opacity forKey:@"opacity"];
	}
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(maxDelay + 0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		for (RSTile* tile in self->pinnedTiles) {
			[tile.layer setOpacity:0];
		}
		
		[[RSLaunchScreenController sharedInstance] show];
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[[objc_getClass("SBIconController") sharedInstance] _launchIcon:sender.icon];
			[[[RSCore sharedInstance] rootScrollView] setUserInteractionEnabled:YES];
		});
	});
}

- (void)returnToHomescreen {
	[[[RSCore sharedInstance] rootScrollView] setUserInteractionEnabled:NO];
	[self.startScrollView setContentOffset:CGPointMake(0, -24)];
	
	NSMutableArray* appsInView = [NSMutableArray new];
	NSMutableArray* appsNotInView = [NSMutableArray new];
	
	for (RSTile* tile in self->pinnedTiles) {
		[tile.layer removeAllAnimations];
		if (CGRectIntersectsRect(self.startScrollView.bounds, tile.frame)) {
			[appsInView addObject:tile];
			
			[tile.layer setOpacity:0];
			[tile setHidden:NO];
		} else {
			[appsNotInView addObject:tile];
		}
	}
	
	for (RSTile* tile in appsNotInView) {
		[tile setHidden:YES];
	}
	
	CAAnimation* scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"
														  function:CubicEaseOut
														 fromValue:0.8
														   toValue:1.0];
	[scale setDuration:0.4];
	[scale setRemovedOnCompletion:NO];
	[scale setFillMode:kCAFillModeForwards];
	
	CAAnimation* opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
															function:CubicEaseIn
														   fromValue:0.0
															 toValue:1.0];
	[opacity setDuration:0.3];
	[opacity setRemovedOnCompletion:NO];
	[opacity setFillMode:kCAFillModeForwards];
	
	int minX = INT_MAX, maxX = INT_MIN, minY = INT_MAX, maxY = INT_MIN;
	for (RSTile* tile in self->pinnedTiles) {
		CGFloat tileX = tile.frame.origin.x / ([RSMetrics tileDimensionsForSize:1].width + [RSMetrics tileBorderSpacing]);
		CGFloat tileY = tile.frame.origin.y / ([RSMetrics tileDimensionsForSize:1].height + [RSMetrics tileBorderSpacing]);
		
		minX = MIN(tileX, minX);
		maxX = MAX(tileX, maxX);
		
		minY = MIN(tileY, minY);
		maxY = MAX(tileY, maxY);
	}
	
	float maxDelay = ((maxY - minY) * 0.01) + (maxX * 0.01);
	
	for (RSTile* tile in self->pinnedTiles) {
		[tile.layer setShouldRasterize:YES];
		[tile.layer setRasterizationScale:[[UIScreen mainScreen] scale]];
		[tile.layer setContentsScale:[[UIScreen mainScreen] scale]];
		
		CGPoint basePoint = [tile convertPoint:tile.bounds.origin toView:self.startScrollView];
		
		CGFloat layerX = -(basePoint.x - CGRectGetMidX(self.startScrollView.bounds))/tile.frame.size.width;
		CGFloat layerY = -(basePoint.y - CGRectGetMidY(self.startScrollView.bounds))/tile.frame.size.height;
		
		CGFloat tileX = tile.frame.origin.x / ([RSMetrics tileDimensionsForSize:1].width + [RSMetrics tileBorderSpacing]);
		CGFloat tileY = tile.frame.origin.y / ([RSMetrics tileDimensionsForSize:1].height + [RSMetrics tileBorderSpacing]);
		
		CGFloat delay = ((maxX - tileX) * 0.01) + ((maxY - tileY) - minY) * 0.01;
		
		[tile setCenter:CGPointMake(CGRectGetMidX(self.startScrollView.bounds),
									CGRectGetMidY(self.startScrollView.bounds))];
		[tile.layer setAnchorPoint:CGPointMake(layerX, layerY)];

		[scale setBeginTime:CACurrentMediaTime() + delay];
		[opacity setBeginTime:CACurrentMediaTime() + delay];
		
		[tile.layer addAnimation:scale forKey:@"scale"];
		[tile.layer addAnimation:opacity forKey:@"opacity"];
	}
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(maxDelay + 0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		for (RSTile* tile in self->pinnedTiles) {
			[tile.layer removeAllAnimations];
			[tile.layer setOpacity:1];
			[tile setAlpha:1.0];
			[tile setHidden:NO];
			[tile.layer setAnchorPoint:CGPointMake(0.5,0.5)];
			[tile setCenter:[tile originalCenter]];
		}
		
		[[[RSCore sharedInstance] rootScrollView] setUserInteractionEnabled:YES];
	});
}

- (void)setIsEditing:(BOOL)isEditing {
	if (!self->_isEditing && isEditing) {
		AudioServicesPlaySystemSound(1520);
	}
	
	self->_isEditing = isEditing;
	
	[[[RSCore sharedInstance] rootScrollView] setScrollEnabled:!isEditing];
	
	if (!isEditing) {
		[self setSelectedTile:nil];
	}
}

- (void)setSelectedTile:(RSTile*)selectedTile {
	self->_selectedTile = selectedTile;
	
	for (RSTile* tile in self->pinnedTiles) {
		if (tile == selectedTile) {
			[tile setIsSelectedTile:YES];
		} else {
			[tile setIsSelectedTile:NO];
		}
	}
}

- (void)pinTileWithId:(NSString *)leafId {
	if ([self->pinnedLeafIdentifiers containsObject:leafId]) {
		return;
	}
	
	int maxTileX = 0, maxTileY = 0;
	
	for (RSTile* tile in self->pinnedTiles) {
		if (tile.tileY > maxTileY) {
			maxTileX = 0;
		}
		maxTileY = MAX(maxTileY, tile.tileY);
		maxTileX = MAX(maxTileX, tile.tileX);
	}
	
	CGFloat sizeForPosition = [RSMetrics tileDimensionsForSize:1].width + [RSMetrics tileBorderSpacing];
	CGSize tileSize = [RSMetrics tileDimensionsForSize:2];
	BOOL tileHasBeenPinned = NO;
	
	for (int i=0; i<6; i++) {
		CGRect tileFrame = CGRectMake(i * sizeForPosition,
									  maxTileY * sizeForPosition,
									  tileSize.width,
									  tileSize.height);
		
		if (![self viewIntersectsWithAnotherView:tileFrame] && (tileFrame.origin.x + tileFrame.size.width) < self.startScrollView.frame.size.width) {
			RSTile* tile = [[RSTile alloc] initWithFrame:tileFrame leafIdentifier:leafId size:2];
			[tile setTileX:i];
			[tile setTileY:maxTileY];
			
			[self.startScrollView addSubview:tile];
			
			[self->pinnedTiles addObject:tile];
			[self->pinnedLeafIdentifiers addObject:leafId];
			
			tileHasBeenPinned = YES;
			break;
		}
	}
	
	if (!tileHasBeenPinned) {
		for (int i=0; i<6; i++) {
			CGRect tileFrame = CGRectMake(i * sizeForPosition,
										  (maxTileY + 2) * sizeForPosition,
										  tileSize.width,
										  tileSize.height);
			
			if (![self viewIntersectsWithAnotherView:tileFrame] && (tileFrame.origin.x + tileFrame.size.width) < self.startScrollView.frame.size.width) {
				RSTile* tile = [[RSTile alloc] initWithFrame:tileFrame leafIdentifier:leafId size:2];
				[tile setTileX:i];
				[tile setTileY:maxTileY];
				
				[self.startScrollView addSubview:tile];
				
				[self->pinnedTiles addObject:tile];
				[self->pinnedLeafIdentifiers addObject:leafId];
				
				tileHasBeenPinned = YES;
				break;
			}
		}
	}
	
	if (!tileHasBeenPinned) {
		CGRect tileFrame = CGRectMake(0,
									  (maxTileY + 2) * sizeForPosition,
									  tileSize.width,
									  tileSize.height);

		RSTile* tile = [[RSTile alloc] initWithFrame:tileFrame leafIdentifier:leafId size:2];
		[tile setTileX:0];
		[tile setTileY:maxTileY];
		
		[self.startScrollView addSubview:tile];
		
		[self->pinnedTiles addObject:tile];
		[self->pinnedLeafIdentifiers addObject:leafId];
	}
	
	[self saveTiles];
	[self updateStartContentSize];
}


- (void)unpinTile:(RSTile *)tile {
	[self->pinnedTiles removeObject:tile];
	[self->pinnedLeafIdentifiers removeObject:[[tile.icon application] bundleIdentifier]];
	
	[UIView animateWithDuration:.2 animations:^{
		[tile setEasingFunction:easeOutQuint forKeyPath:@"frame"];
		
		[tile setTransform:CGAffineTransformMakeScale(0.5, 0.5)];
		[tile.layer setOpacity:0.0];
	} completion:^(BOOL finished) {
		[tile removeEasingFunctionForKeyPath:@"frame"];
		[tile removeFromSuperview];
		
		[self saveTiles];
		[self updateStartContentSize];
	}];
}

- (id)viewIntersectsWithAnotherView:(CGRect)rect {
	for (RSTile* tile in self->pinnedTiles) {
		if (CGRectIntersectsRect(tile.frame, rect)) {
			return tile;
		}
	}
	return nil;
}

- (void)resetTileVisibility {
	for (RSTile* tile in self->pinnedTiles) {
		[tile setHidden:NO];
		[tile.layer setOpacity:1];
		[tile.layer removeAllAnimations];
	}
}

- (NSArray*)pinnedTiles {
	return self->pinnedTiles;
}

- (NSArray*)pinnedLeafIdentifiers {
	return self->pinnedLeafIdentifiers;
}

@end
