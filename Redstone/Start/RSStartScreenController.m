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

- (id)viewIntersectsWithAnotherView:(CGRect)rect {
	for (RSTile* tile in pinnedTiles) {
		if (CGRectIntersectsRect(tile.frame, rect)) {
			return tile;
		}
	}
	return nil;
}

- (void)resetTileVisibility {
	for (RSTile* tile in pinnedTiles) {
		[tile setHidden:NO];
		[tile.layer setOpacity:1];
		[tile.layer removeAllAnimations];
	}
}

/* TILE MANAGEMENT */

- (void)loadTiles {
	pinnedTiles = [NSMutableArray new];
	pinnedLeafIdentifiers = [NSMutableArray new];
	
	NSArray* tileLayout = [[RSPreferences preferences] objectForKey:[NSString stringWithFormat:@"%iColumnLayout", [RSMetrics columns]]];
	CGFloat sizeForPosition = [RSMetrics tileDimensionsForSize:1].width + [RSMetrics tileBorderSpacing];
	
	for (int i=0; i<tileLayout.count; i++) {
		SBLeafIcon* icon = [[[objc_getClass("SBIconController") sharedInstance] model] leafIconForIdentifier:[tileLayout objectAtIndex:i][@"bundleIdentifier"]];
		if (icon && [icon applicationBundleID] != nil && ![[icon applicationBundleID] isEqualToString:@""]) {
			CGSize tileSize = [RSMetrics tileDimensionsForSize:[tileLayout[i][@"size"] intValue]];
			CGRect tileFrame = CGRectMake(sizeForPosition * [tileLayout[i][@"column"] intValue],
										  sizeForPosition * [tileLayout[i][@"row"] intValue],
										  tileSize.width,
										  tileSize.height);
			
			RSTile* tile = [[RSTile alloc] initWithFrame:tileFrame leafIdentifier:tileLayout[i][@"bundleIdentifier"] size:[tileLayout[i][@"size"] intValue]];
			[tile setTileX:[tileLayout[i][@"column"] intValue]];
			[tile setTileY:[tileLayout[i][@"row"] intValue]];
			
			[self.startScrollView addSubview:tile];
			[pinnedTiles addObject:tile];
			[pinnedLeafIdentifiers addObject:tileLayout[i][@"bundleIdentifier"]];
		}
	}
	
	[self updateStartContentSize];
}

- (void)saveTiles {
	NSMutableArray* tilesToSave = [NSMutableArray new];
	
	for (RSTile* tile in pinnedTiles) {
		NSMutableDictionary* tileInfo = [NSMutableDictionary new];
		
		[tileInfo setValue:[NSNumber numberWithInteger:tile.size] forKey:@"size"];
		[tileInfo setValue:[NSNumber numberWithInteger:tile.tileY] forKey:@"row"];
		[tileInfo setValue:[NSNumber numberWithInteger:tile.tileX] forKey:@"column"];
		[tileInfo setValue:[[tile.icon application] bundleIdentifier] forKey:@"bundleIdentifier"];
		
		[tilesToSave addObject:tileInfo];
	}
	
	[RSPreferences setValue:tilesToSave forKey:[NSString stringWithFormat:@"%iColumnLayout", [RSMetrics columns]]];
}

- (NSArray*)pinnedTiles {
	return pinnedTiles;
}

- (NSArray*)pinnedLeafIdentifiers {
	return pinnedLeafIdentifiers;
}

- (RSTile*)tileForLeafIdentifier:(NSString *)leafId {
	for (RSTile* tile in pinnedTiles) {
		if ([[[tile.icon application] bundleIdentifier] isEqualToString:leafId]) {
			return tile;
			break;
		}
	}
	
	return nil;
}

/* EDITING MODE */

- (void)setIsEditing:(BOOL)isEditing {
	if (!_isEditing && isEditing) {
		AudioServicesPlaySystemSound(1520);
	}
	
	_isEditing = isEditing;
	
	[[[RSCore sharedInstance] rootScrollView] setScrollEnabled:!isEditing];
	[self.startScrollView.allAppsButton setHidden:isEditing];
	
	if (!isEditing) {
		[self setSelectedTile:nil];
		[UIView animateWithDuration:.2 animations:^{
			[self.startScrollView setEasingFunction:easeOutQuint forKeyPath:@"frame"];
			
			[self.startScrollView setTransform:CGAffineTransformIdentity];
		} completion:^(BOOL finished) {
			[self.startScrollView removeEasingFunctionForKeyPath:@"frame"];
		}];
		
		[self saveTiles];
	} else {
		[UIView animateWithDuration:.2 animations:^{
			[self.startScrollView setEasingFunction:easeOutQuint forKeyPath:@"frame"];
			
			[self.startScrollView setTransform:CGAffineTransformMakeScale(0.9, 0.9)];
		} completion:^(BOOL finished) {
			[self.startScrollView removeEasingFunctionForKeyPath:@"frame"];
		}];
	}
}

- (void)setSelectedTile:(RSTile*)selectedTile {
	_selectedTile = selectedTile;
	
	for (RSTile* tile in pinnedTiles) {
		[tile setTiltEnabled:!self.isEditing];
		
		if (tile == selectedTile) {
			[tile setIsSelectedTile:YES];
		} else {
			[tile setIsSelectedTile:NO];
		}
	}
}

- (void)pinTileWithId:(NSString *)leafId {
	if ([pinnedLeafIdentifiers containsObject:leafId]) {
		return;
	}
	
	if ([pinnedTiles count] <= 0) {
		[[[RSCore sharedInstance] rootScrollView] setScrollEnabled:YES];
	}
	
	int maxTileX = 0, maxTileY = 0;
	
	for (RSTile* tile in pinnedTiles) {
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
		
		
		if (![self viewIntersectsWithAnotherView:tileFrame] && (tileFrame.origin.x + tileFrame.size.width) <= self.startScrollView.frame.size.width) {
			RSTile* tile = [[RSTile alloc] initWithFrame:tileFrame leafIdentifier:leafId size:2];
			[tile setTileX:i];
			[tile setTileY:maxTileY];
			
			[self.startScrollView addSubview:tile];
			
			[pinnedTiles addObject:tile];
			[pinnedLeafIdentifiers addObject:leafId];
			
			tileHasBeenPinned = YES;
			break;
		}
	}
	
	if (!tileHasBeenPinned) {
		for (int i=0; i<6; i++) {
			CGRect tileFrame = CGRectMake(i * sizeForPosition,
										  (maxTileY + 1) * sizeForPosition,
										  tileSize.width,
										  tileSize.height);
			
			if (![self viewIntersectsWithAnotherView:tileFrame] && (tileFrame.origin.x + tileFrame.size.width) <= self.startScrollView.frame.size.width) {
				RSTile* tile = [[RSTile alloc] initWithFrame:tileFrame leafIdentifier:leafId size:2];
				[tile setTileX:i];
				[tile setTileY:maxTileY+1];
				
				[self.startScrollView addSubview:tile];
				
				[pinnedTiles addObject:tile];
				[pinnedLeafIdentifiers addObject:leafId];
				
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
		[tile setTileY:maxTileY + 2];
		
		[self.startScrollView addSubview:tile];
		
		[pinnedTiles addObject:tile];
		[pinnedLeafIdentifiers addObject:leafId];
	}
	
	[self saveTiles];
	[self updateStartContentSize];
	
	[[RSAppListController sharedInstance] hidePinMenu];
	[[[RSCore sharedInstance] rootScrollView] setContentOffset:CGPointMake(0, 0) animated:YES];
	[self.startScrollView setContentOffset:CGPointMake(0, MAX([[RSStartScreenController sharedInstance] startScrollView].contentSize.height - [[RSStartScreenController sharedInstance] startScrollView].bounds.size.height + 64, -24)) animated:YES];
}

- (void)unpinTile:(RSTile *)tile {
	[pinnedTiles removeObject:tile];
	[pinnedLeafIdentifiers removeObject:[[tile.icon application] bundleIdentifier]];
	
	[UIView animateWithDuration:.2 animations:^{
		[tile setEasingFunction:easeOutQuint forKeyPath:@"frame"];
		
		[tile setTransform:CGAffineTransformMakeScale(0.5, 0.5)];
		[tile.layer setOpacity:0.0];
	} completion:^(BOOL finished) {
		[tile removeEasingFunctionForKeyPath:@"frame"];
		[tile removeFromSuperview];
		
		[self saveTiles];
		[self updateStartContentSize];
		
		if ([pinnedTiles count] <= 0) {
			[self setIsEditing:NO];
			[[[RSCore sharedInstance] rootScrollView] setScrollEnabled:NO];
			[[[RSCore sharedInstance] rootScrollView] setContentOffset:CGPointMake(screenWidth, 0) animated:YES];
		}
	}];
}

- (void)snapTile:(RSTile *)tile withTouchPosition:(CGPoint)position {
	CGFloat step = [RSMetrics tileDimensionsForSize:1].width + [RSMetrics tileBorderSpacing];
	CGFloat maxPositionX = self.startScrollView.bounds.size.width - tile.bounds.size.width;
	CGFloat maxPositionY = self.startScrollView.contentSize.height + [RSMetrics tileBorderSpacing];
	
	CGPoint newCenter = CGPointMake(MIN(MAX(step * roundf(tile.basePosition.origin.x / step), 0), maxPositionX) + tile.basePosition.size.width/2,
									MIN(MAX(step * roundf(tile.basePosition.origin.y / step), 0), maxPositionY) + tile.basePosition.size.height/2);
	[UIView animateWithDuration:.3 animations:^{
		[tile setEasingFunction:easeOutQuint forKeyPath:@"frame"];
		[tile setCenter:newCenter];
	} completion:^(BOOL finished) {
		[tile removeEasingFunctionForKeyPath:@"frame"];
		[tile setOriginalCenter:tile.center];
		
		int tileX = tile.basePosition.origin.x / step;
		int tileY = tile.basePosition.origin.y / step;
		
		[tile setTileX:tileX];
		[tile setTileY:tileY];
	}];
	
	[self moveAffectedTilesForTile:tile];
}

- (void)moveAffectedTilesForTile:(RSTile *)movedTile {
	// This algorithm is based on Daniel T.'s answer here:
	// http://stackoverflow.com/questions/43825803/get-all-uiviews-affected-by-moving-another-uiview-above-them/
	
	NSMutableArray* stack = [NSMutableArray new];
	CGFloat step = [RSMetrics tileDimensionsForSize:1].width + [RSMetrics tileBorderSpacing];
	BOOL didMoveTileIntoPosition = NO;
	
	[stack addObject:movedTile];
	
	while ([stack count] > 0) {
		RSTile* current = [stack objectAtIndex:0];
		[stack removeObject:current];
		
		for (RSTile* tile in pinnedTiles) {
			if (tile != movedTile && CGRectIntersectsRect(tile.basePosition, movedTile.basePosition) && tile.basePosition.origin.y < movedTile.basePosition.origin.y && !didMoveTileIntoPosition) {
				CGFloat moveDistance = (CGRectGetMaxY(tile.basePosition)- CGRectGetMinY(movedTile.basePosition)) + [RSMetrics tileBorderSpacing];
				CGRect newFrame = CGRectMake(movedTile.frame.origin.x,
											 movedTile.frame.origin.y + moveDistance,
											 movedTile.frame.size.width,
											 movedTile.frame.size.height);
				
				[movedTile.layer removeAllAnimations];
				[UIView animateWithDuration:.3 animations:^{
					[movedTile setEasingFunction:easeOutQuint forKeyPath:@"frame"];
					[movedTile setFrame:newFrame];
				} completion:^(BOOL finished) {
					[movedTile removeEasingFunctionForKeyPath:@"frame"];
				}];
				
				didMoveTileIntoPosition = YES;
			} else if (tile != current && CGRectIntersectsRect(current.basePosition, tile.basePosition)) {
				[stack addObject:tile];
				
				CGFloat moveDistance = (CGRectGetMaxY(current.basePosition) - CGRectGetMinY(tile.basePosition)) + [RSMetrics tileBorderSpacing];
				CGRect newFrame = CGRectMake(tile.frame.origin.x,
											 tile.frame.origin.y + moveDistance,
											 tile.frame.size.width,
											 tile.frame.size.height);
				
				[UIView animateWithDuration:.3 animations:^{
					[tile setEasingFunction:easeOutQuint forKeyPath:@"frame"];
					[tile setFrame:newFrame];
				} completion:^(BOOL finished) {
					[tile removeEasingFunctionForKeyPath:@"frame"];
					[tile setOriginalCenter:tile.center];
					
					int tileX = tile.basePosition.origin.x / step;
					int tileY = tile.basePosition.origin.y / step;
					
					[tile setTileX:tileX];
					[tile setTileY:tileY];
				}];
				
			}
		}
	}
	
	[self eliminateEmptyRows];
}

- (void)eliminateEmptyRows {
	[self updateStartContentSize];
}

- (void)updateStartContentSize {
	if ([pinnedTiles count] <= 0) {
		[self.startScrollView setContentSize:CGSizeMake(self.startScrollView.bounds.size.width, 0)];
		return;
	}
	
	RSTile* lastTile = [pinnedTiles objectAtIndex:0];
	
	for (RSTile* tile in pinnedTiles) {
		CGRect lastTileFrame = [lastTile basePosition];
		CGRect currentTileFrame = [tile basePosition];
		
		if (currentTileFrame.origin.y > lastTileFrame.origin.y || (currentTileFrame.origin.y == lastTileFrame.origin.y && currentTileFrame.size.height > lastTileFrame.size.height)) {
			lastTile = tile;
		}
	}
	
	CGSize contentSize = CGSizeMake(self.startScrollView.frame.size.width,
									[lastTile basePosition].origin.y + [lastTile basePosition].size.height);
	
	[UIView animateWithDuration:.1 animations:^{
		[self.startScrollView setContentSize:contentSize];
	} completion:nil];
}

/* ANIMATION */

- (void)prepareForAppLaunch:(RSTile *)sender {
	[[[RSCore sharedInstance] rootScrollView] setUserInteractionEnabled:NO];
	[[RSLaunchScreenController sharedInstance] setLaunchScreenForLeafIdentifier:[[sender.icon application] bundleIdentifier] tileInfo:sender.tileInfo];
	
	NSMutableArray* appsInView = [NSMutableArray new];
	NSMutableArray* appsNotInView = [NSMutableArray new];
	
	for (RSTile* tile in pinnedTiles) {
		if (CGRectIntersectsRect(self.startScrollView.bounds, tile.basePosition)) {
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
	for (RSTile* tile in pinnedTiles) {
		minX = MIN(tile.tileX, minX);
		maxX = MAX(tile.tileX, maxX);
		
		minY = MIN(tile.tileY, minY);
		maxY = MAX(tile.tileY, maxY);
	}
	
	float maxDelay = ((maxY - minY) * 0.01) + (maxX * 0.01);
	
	for (RSTile* tile in appsInView) {
		[tile.layer setShouldRasterize:YES];
		[tile.layer setRasterizationScale:[[UIScreen mainScreen] scale]];
		[tile.layer setContentsScale:[[UIScreen mainScreen] scale]];
		
		CGFloat layerX = -(tile.basePosition.origin.x - CGRectGetMidX(self.startScrollView.bounds))/tile.basePosition.size.width;
		CGFloat layerY = -(tile.basePosition.origin.y - CGRectGetMidY(self.startScrollView.bounds))/tile.basePosition.size.height;
		CGFloat delay = (tile.tileX * 0.01) + (tile.tileY - minY) * 0.01;
		
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
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(maxDelay + 0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		for (RSTile* tile in pinnedTiles) {
			[tile.layer setOpacity:0];
			[tile.layer removeAllAnimations];
			[tile.layer setAnchorPoint:CGPointMake(0.5,0.5)];
			[tile setCenter:[tile originalCenter]];
			
			[tile stopLiveTile];
		}
		
		[[RSLaunchScreenController sharedInstance] show];
		[[objc_getClass("SBIconController") sharedInstance] _launchIcon:sender.icon];
		[[[RSCore sharedInstance] rootScrollView] setUserInteractionEnabled:YES];
	});
}

- (void)returnToHomescreen {
	if ([pinnedTiles count] <= 0) {
		[[RSAppListController sharedInstance] returnToHomescreen];
		return;
	}
	
	[[[RSCore sharedInstance] rootScrollView] setUserInteractionEnabled:NO];
	[self.startScrollView setContentOffset:CGPointMake(0, -24)];
	
	NSMutableArray* appsInView = [NSMutableArray new];
	NSMutableArray* appsNotInView = [NSMutableArray new];
	
	for (RSTile* tile in pinnedTiles) {
		[tile stopLiveTile];
		if (CGRectIntersectsRect(self.startScrollView.bounds, tile.basePosition)) {
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
	for (RSTile* tile in pinnedTiles) {
		minX = MIN(tile.tileX, minX);
		maxX = MAX(tile.tileX, maxX);
		
		minY = MIN(tile.tileY, minY);
		maxY = MAX(tile.tileY, maxY);
	}
	
	float maxDelay = ((maxY - minY) * 0.01) + (maxX * 0.01);
	
	for (RSTile* tile in appsInView) {
		[tile.layer setShouldRasterize:YES];
		[tile.layer setRasterizationScale:[[UIScreen mainScreen] scale]];
		[tile.layer setContentsScale:[[UIScreen mainScreen] scale]];
		
		CGFloat layerX = -(tile.basePosition.origin.x - CGRectGetMidX(self.startScrollView.bounds))/tile.basePosition.size.width;
		CGFloat layerY = -(tile.basePosition.origin.y - CGRectGetMidY(self.startScrollView.bounds))/tile.basePosition.size.height;
		CGFloat delay = (tile.tileX * 0.01) + (tile.tileY - minY) * 0.01;
		
		[tile setCenter:CGPointMake(CGRectGetMidX(self.startScrollView.bounds),
									CGRectGetMidY(self.startScrollView.bounds))];
		[tile.layer setAnchorPoint:CGPointMake(layerX, layerY)];
		
		[scale setBeginTime:CACurrentMediaTime() + delay];
		[opacity setBeginTime:CACurrentMediaTime() + delay];
		
		[tile.layer addAnimation:scale forKey:@"scale"];
		[tile.layer addAnimation:opacity forKey:@"opacity"];
	}
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(maxDelay + 0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		for (RSTile* tile in pinnedTiles) {
			[tile.layer removeAllAnimations];
			[tile.layer setOpacity:1];
			[tile setAlpha:1.0];
			[tile setHidden:NO];
			[tile.layer setAnchorPoint:CGPointMake(0.5,0.5)];
			[tile setCenter:[tile originalCenter]];
			
			[tile startLiveTile];
		}
		
		[[[RSCore sharedInstance] rootScrollView] setUserInteractionEnabled:YES];
	});
}

- (void)deviceFinishedLock {
	for (RSTile* tile in pinnedTiles) {
		[tile stopLiveTile];
	}
}

@end
