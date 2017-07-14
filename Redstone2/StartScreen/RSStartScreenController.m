#import "../Redstone.h"

@implementation RSStartScreenController

static RSStartScreenController* sharedInstance;

+ (id)sharedInstance {
	return sharedInstance;
}

- (id)init {
	if (self = [super init]) {
		sharedInstance = self;
	}
	
	return self;
}

- (void)loadView {
	self.view = [[RSStartScreenScrollView alloc] initWithFrame:CGRectMake(4, 0, screenWidth-8, screenHeight)];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceFinishedLock) name:@"RedstoneDeviceHasFinishedLock" object:nil];
	
	[self loadTiles];
}

- (id)viewIntersectsWithAnotherView:(CGRect)rect {
	for (RSTile* tile in pinnedTiles) {
		if (CGRectIntersectsRect(tile.basePosition, rect)) {
			return tile;
		}
	}
	return nil;
}

- (void)deviceFinishedLock {
	[self setIsEditing:NO];
	
	[self stopLiveTiles];
}

#pragma mark Tile Management

- (void)loadTiles {
	pinnedTiles = [NSMutableArray new];
	pinnedLeafIdentifiers = [NSMutableArray new];
	
	NSArray* tileLayout = [[RSPreferences preferences] objectForKey:[NSString stringWithFormat:@"%ldColumnLayout", (long)[RSMetrics columns]]];
	CGFloat sizeForPosition = [RSMetrics tileDimensionsForSize:1].width + [RSMetrics tileBorderSpacing];
	
	for (int i=0; i<tileLayout.count; i++) {
		SBLeafIcon* icon = [[(SBIconController*)[objc_getClass("SBIconController") sharedInstance] model] leafIconForIdentifier:[tileLayout objectAtIndex:i][@"bundleIdentifier"]];
		
		if (icon && [icon applicationBundleID] && ![[icon applicationBundleID] isEqualToString:@""]) {
			CGSize tileSize = [RSMetrics tileDimensionsForSize:[[tileLayout objectAtIndex:i][@"size"] intValue]];
			CGRect tileFrame = CGRectMake(sizeForPosition * [[tileLayout objectAtIndex:i][@"column"] intValue],
										  sizeForPosition * [[tileLayout objectAtIndex:i][@"row"] intValue],
										  tileSize.width, tileSize.height);
			
			RSTile* tile = [[RSTile alloc] initWithFrame:tileFrame leafIdentifier:[icon applicationBundleID] size:[[tileLayout objectAtIndex:i][@"size"] intValue]];
			
			[self.view addSubview:tile];
			[pinnedTiles addObject:tile];
			[pinnedLeafIdentifiers addObject:[icon applicationBundleID]];
		}
	}
	
	[self updateStartContentSize];
}

- (void)saveTiles {
	NSMutableArray* tilesToSave = [NSMutableArray new];
	CGFloat sizeForPosition = [RSMetrics tileDimensionsForSize:1].width + [RSMetrics tileBorderSpacing];
	
	for (RSTile* tile in pinnedTiles) {
		NSMutableDictionary* tileInfo = [NSMutableDictionary new];
		
		int tilePositionX = tile.basePosition.origin.x / sizeForPosition;
		int tilePositionY = tile.basePosition.origin.y / sizeForPosition;
		
		[tileInfo setValue:[NSNumber numberWithInteger:tile.size] forKey:@"size"];
		[tileInfo setValue:[NSNumber numberWithInteger:tilePositionY] forKey:@"row"];
		[tileInfo setValue:[NSNumber numberWithInteger:tilePositionX] forKey:@"column"];
		[tileInfo setValue:[tile.icon applicationBundleID] forKey:@"bundleIdentifier"];

		[tilesToSave addObject:tileInfo];
	}
	
	[RSPreferences setObject:tilesToSave forKey:[NSString stringWithFormat:@"%iColumnLayout", [RSMetrics columns]]];
}

- (RSTile*)tileForLeafIdentifier:(NSString*)leafIdentifier {
	for (RSTile* tile in pinnedTiles) {
		if ([[tile.icon applicationBundleID] isEqualToString:leafIdentifier]) {
			return tile;
			break;
		}
	}
	
	return nil;
}

- (void)updateStartContentSize {
	if ([pinnedTiles count] <= 0) {
		[(UIScrollView*)self.view setContentSize:CGSizeMake(self.view.bounds.size.width, 0)];
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
	
	CGSize contentSize = CGSizeMake(self.view.frame.size.width,
									[lastTile basePosition].origin.y + [lastTile basePosition].size.height);
	
	[UIView animateWithDuration:.1 animations:^{
		[(UIScrollView*)self.view setContentSize:contentSize];
	} completion:nil];
}

- (void)pinTileWithIdentifier:(NSString*)leafIdentifier {
	if ([pinnedLeafIdentifiers containsObject:leafIdentifier]) {
		return;
	}
	
	if (![[(SBIconController*)[objc_getClass("SBIconController") sharedInstance] model] leafIconForIdentifier:leafIdentifier]) {
		return;
	}
	
	CGFloat sizeForPosition = [RSMetrics tileDimensionsForSize:1].width + [RSMetrics tileBorderSpacing];
	
	int maxTileX = 0, maxTileY = 0;
	for (RSTile* tile in pinnedTiles) {
		if (tile.basePosition.origin.y / sizeForPosition > maxTileY) {
			maxTileX = 0;
		}
		
		maxTileX = MAX(tile.basePosition.origin.x / sizeForPosition, maxTileX);
		maxTileY = MAX(tile.basePosition.origin.y / sizeForPosition, maxTileY);
	}
	
	CGSize tileSize = [RSMetrics tileDimensionsForSize:2];
	BOOL tileHasBeenPinned = NO;
	
	for (int i=0; i<3; i++) {
		for (int j=0; j<[RSMetrics columns]*2; j++) {
			CGRect tileFrame = CGRectMake(j * sizeForPosition,
										  (maxTileY + i) * sizeForPosition,
										  tileSize.width,
										  tileSize.height);
			
			if (![self viewIntersectsWithAnotherView:tileFrame] && (tileFrame.origin.x + tileFrame.size.width) <= self.view.bounds.size.width) {
				RSTile* tile = [[RSTile alloc] initWithFrame:tileFrame leafIdentifier:leafIdentifier size:2];
				[self.view addSubview:tile];
				
				[pinnedTiles addObject:tile];
				[pinnedLeafIdentifiers addObject:leafIdentifier];
				
				tileHasBeenPinned = YES;
				break;
			}
		}
		
		if (tileHasBeenPinned) {
			break;
		}
	}
	
	[self eliminateEmptyRows];
	[self saveTiles];
	[(UIScrollView*)self.view setContentOffset:CGPointMake(0, MAX([(UIScrollView*)self.view contentSize].height - self.view.bounds.size.height + 64, -24)) animated:YES];
}

- (void)unpinTile:(RSTile*)tile {
	if (![pinnedTiles containsObject:tile]) {
		return;
	}
	
	[pinnedTiles removeObject:tile];
	[pinnedLeafIdentifiers removeObject:tile.icon.applicationBundleID];
	
	[UIView animateWithDuration:.2 animations:^{
		[tile setEasingFunction:easeOutQuint forKeyPath:@"frame"];
		
		[tile setTransform:CGAffineTransformMakeScale(0.5, 0.5)];
		[tile.layer setOpacity:0.0];
	} completion:^(BOOL finished) {
		[tile removeEasingFunctionForKeyPath:@"frame"];
		[tile removeFromSuperview];
		
		[self saveTiles];
		[self eliminateEmptyRows];
	}];
}

- (void)setTilesVisible:(BOOL)visible {
	if (visible) {
		for (RSTile* tile in pinnedTiles) {
			[tile setHidden:NO];
			[tile.layer setOpacity:1];
			[tile.layer removeAllAnimations];
		}
	} else {
		for (RSTile* tile in pinnedTiles) {
			[tile setHidden:YES];
			[tile.layer setOpacity:0];
		}
	}
}

#pragma mark Editing Mode

- (void)setIsEditing:(BOOL)isEditing {
	if (!_isEditing && isEditing) {
		AudioServicesPlaySystemSound(1520);
	}
	
	_isEditing = isEditing;
	
	[[RSHomeScreenController sharedInstance] setScrollEnabled:!isEditing];
	[[(RSStartScreenScrollView*)self.view allAppsButton] setHidden:isEditing];
	
	if (isEditing) {
		[UIView animateWithDuration:.2 animations:^{
			[self.view setEasingFunction:easeOutQuint forKeyPath:@"frame"];
			
			[self.view setTransform:CGAffineTransformMakeScale(0.9, 0.9)];
		} completion:^(BOOL finished) {
			[self.view removeEasingFunctionForKeyPath:@"frame"];
		}];
	} else {
		[self setSelectedTile:nil];
		
		[UIView animateWithDuration:.2 animations:^{
			[self.view setEasingFunction:easeOutQuint forKeyPath:@"frame"];
			
			[self.view setTransform:CGAffineTransformIdentity];
		} completion:^(BOOL finished) {
			[self.view removeEasingFunctionForKeyPath:@"frame"];
		}];
		
		[self saveTiles];
	}
}

- (void)setSelectedTile:(RSTile*)selectedTile {
	_selectedTile = selectedTile;
	
	for (RSTile* tile in pinnedTiles) {
		[tile setTiltEnabled:!self.isEditing];
		
		[tile setIsSelectedTile:(tile == selectedTile)];
	}
}

- (void)snapTile:(RSTile *)tile withTouchPosition:(CGPoint)touchPosition {
	CGFloat step = [RSMetrics tileDimensionsForSize:1].width + [RSMetrics tileBorderSpacing];
	CGFloat maxPositionX = self.view.bounds.size.width - tile.bounds.size.width;
	CGFloat maxPositionY = [(UIScrollView*)[self view] contentSize].height + [RSMetrics tileBorderSpacing];
	
	CGPoint newCenter = CGPointMake(MIN(MAX(step * roundf(tile.basePosition.origin.x / step), 0), maxPositionX) + tile.basePosition.size.width/2,
									MIN(MAX(step * roundf(tile.basePosition.origin.y / step), 0), maxPositionY) + tile.basePosition.size.height/2);
	
	[tile setNextCenterUpdate:newCenter];
	[tile setNextFrameUpdate:CGRectMake(newCenter.x - tile.basePosition.size.width/2,
										newCenter.y - tile.basePosition.size.height/2,
										tile.basePosition.size.width,
										tile.basePosition.size.height)];
	
	//[self applyPendingFrameUpdates];
	[self moveAffectedTilesForTile:tile];
}

- (void)moveAffectedTilesForTile:(RSTile *)movedTile {
	// This algorithm is based on Daniel T.'s answer here:
	// http://stackoverflow.com/questions/43825803/get-all-uiviews-affected-by-moving-another-uiview-above-them/
	
	pinnedTiles = [self sortPinnedTiles];
	
	NSMutableArray* stack = [NSMutableArray new];
	BOOL didMoveTileIntoPosition = NO;
	
	[stack addObject:movedTile];
	
	while ([stack count] > 0) {
		RSTile* current = [stack objectAtIndex:0];
		[stack removeObject:current];
		
		for (RSTile* tile in pinnedTiles) {
			if (tile != movedTile && CGRectIntersectsRect(tile.basePosition, movedTile.nextFrameUpdate) && tile.basePosition.origin.y < movedTile.nextFrameUpdate.origin.y && !didMoveTileIntoPosition) {
				NSLog(@"[Redstone] A");
				CGFloat moveDistance = (CGRectGetMaxY(tile.basePosition) - CGRectGetMinY(movedTile.nextFrameUpdate)) + [RSMetrics tileBorderSpacing];
				
				CGPoint newCenter = CGPointMake(movedTile.nextCenterUpdate.x,
												movedTile.nextCenterUpdate.y + moveDistance);
				
				[movedTile setNextCenterUpdate:newCenter];
				[movedTile setNextFrameUpdate:CGRectMake(newCenter.x - movedTile.basePosition.size.width/2,
														 newCenter.y - movedTile.basePosition.size.height/2,
														 movedTile.basePosition.size.width,
														 movedTile.basePosition.size.height)];
				
				didMoveTileIntoPosition = YES;
			} else if (tile != current) {
				CGRect currentFrame, tileFrame;
				if (!CGRectEqualToRect(current.nextFrameUpdate, CGRectZero)) {
					currentFrame = current.nextFrameUpdate;
				} else {
					currentFrame = current.basePosition;
				}
				
				if (!CGRectEqualToRect(tile.nextFrameUpdate, CGRectZero)) {
					tileFrame = tile.nextFrameUpdate;
				} else {
					tileFrame = tile.basePosition;
				}
				
				if (CGRectIntersectsRect(currentFrame, tileFrame)) {
					NSLog(@"[Redstone] B");
					NSLog(@"[Redstone] %@", NSStringFromCGRect(CGRectIntersection(currentFrame, tileFrame)));
					
					[stack addObject:tile];
					
					CGFloat moveDistance = (CGRectGetMaxY(currentFrame) - CGRectGetMinY(tileFrame)) + [RSMetrics tileBorderSpacing];
					
					CGPoint newCenter = CGPointMake(CGRectGetMidX(tileFrame),
													CGRectGetMidY(tileFrame) + moveDistance);
					
					[tile setNextCenterUpdate:newCenter];
					[tile setNextFrameUpdate:CGRectMake(newCenter.x - tile.basePosition.size.width/2,
														newCenter.y - tile.basePosition.size.height/2,
														tile.basePosition.size.width,
														tile.basePosition.size.height)];
				}
			}
		}
	}
	
#if TARGET_OS_SIMULATOR
	//[self updateStartContentSize];
#else
	//[self applyPendingFrameUpdates];
	[self eliminateEmptyRows];
#endif
}

- (void)eliminateEmptyRows {
	pinnedTiles = [self sortPinnedTiles];
	
	CGFloat sizeForPosition = [RSMetrics tileDimensionsForSize:1].width + [RSMetrics tileBorderSpacing];
	
	for (RSTile* tile in pinnedTiles) {
		CGRect tileFrame;
		
		if (!CGRectEqualToRect(tile.nextFrameUpdate, CGRectZero)) {
			tileFrame = tile.nextFrameUpdate;
		} else {
			tileFrame = tile.basePosition;
		}
		
		int yPosition = tileFrame.origin.y / sizeForPosition;
		
		for (int i=0; i<yPosition; i++) {
			CGRect testFrame = CGRectMake(tileFrame.origin.x,
										  i * sizeForPosition,
										  tileFrame.size.width,
										  tileFrame.origin.y - (i * sizeForPosition));
			
			BOOL canSetFrame = YES;
			for (RSTile* view in pinnedTiles) {
				if (view != tile) {
					CGRect viewFrame;
					if (!CGRectEqualToRect(view.nextFrameUpdate, CGRectZero)) {
						viewFrame = view.nextFrameUpdate;
					} else {
						viewFrame = view.basePosition;
					}
					
					if (CGRectIntersectsRect(testFrame, viewFrame)) {
						canSetFrame = NO;
						break;
					}
				}
			}
			
			if (canSetFrame) {
				CGPoint newCenter = CGPointMake(CGRectGetMidX(tileFrame),
												CGRectGetMidY(tileFrame) - testFrame.size.height);
				
				[tile setNextCenterUpdate:newCenter];
				[tile setNextFrameUpdate:CGRectMake(newCenter.x - tile.basePosition.size.width/2,
													newCenter.y - tile.basePosition.size.height/2,
													tile.basePosition.size.width,
													tile.basePosition.size.height)];
				break;
			}
		}
	}
	
	[self applyPendingFrameUpdates];
}

- (void)applyPendingFrameUpdates {
	[UIView animateWithDuration:.3 animations:^{
		for (RSTile* tile in pinnedTiles) {
			if (!CGPointEqualToPoint(tile.nextCenterUpdate, CGPointZero)) {
				[tile setEasingFunction:easeOutQuint forKeyPath:@"frame"];
				[tile setCenter:tile.nextCenterUpdate];
			}
		}
	} completion:^(BOOL finished) {
		for (RSTile* tile in pinnedTiles) {
			[tile removeEasingFunctionForKeyPath:@"frame"];
			[tile setOriginalCenter:tile.center];
			
			[tile setNextCenterUpdate:CGPointZero];
			[tile setNextFrameUpdate:CGRectZero];
		}
	}];
	
	[self updateStartContentSize];
}

- (NSMutableArray*)sortPinnedTiles {
	pinnedLeafIdentifiers = [NSMutableArray new];
	
	NSArray* sortedTiles = [pinnedTiles sortedArrayUsingComparator:^NSComparisonResult(RSTile* tile1, RSTile* tile2) {
		CGRect firstTileFrame, secondTileFrame;
		
		if (!CGRectEqualToRect(tile1.nextFrameUpdate, CGRectZero)) {
			firstTileFrame = tile1.nextFrameUpdate;
		} else {
			firstTileFrame = tile1.basePosition;
		}
		
		if (!CGRectEqualToRect(tile2.nextFrameUpdate, CGRectZero)) {
			secondTileFrame = tile2.nextFrameUpdate;
		} else {
			secondTileFrame = tile2.basePosition;
		}
		
		if (firstTileFrame.origin.y == secondTileFrame.origin.y) {
			return [[NSNumber numberWithFloat:firstTileFrame.origin.x] compare:[NSNumber numberWithFloat:secondTileFrame.origin.x]];
		} else {
			return [[NSNumber numberWithFloat:firstTileFrame.origin.y] compare:[NSNumber numberWithFloat:secondTileFrame.origin.y]];
		}
	}];
	
	for (RSTile* tile in sortedTiles) {
		[pinnedLeafIdentifiers addObject:[tile.icon applicationBundleID]];
	}
	
	return [sortedTiles mutableCopy];
}

#pragma mark Animations

- (CGFloat)getMaxDelayForAnimation {
	int minX = INT_MAX, maxX = INT_MIN, minY = INT_MAX, maxY = INT_MIN;
	
	CGFloat sizeForPosition = [RSMetrics tileDimensionsForSize:1].width + [RSMetrics tileBorderSpacing];
	for (RSTile* tile in pinnedTiles) {
		minX = MIN(tile.basePosition.origin.x / sizeForPosition, minX);
		maxX = MAX(tile.basePosition.origin.x / sizeForPosition, maxX);
		
		minY = MIN(tile.basePosition.origin.y / sizeForPosition, minY);
		maxY = MAX(tile.basePosition.origin.y / sizeForPosition, maxY);
	}
	
	return ((maxY - minY) * 0.01) + (maxX * 0.01);
}

- (void)animateIn {
	// App to Home Screen
	[self.view setUserInteractionEnabled:NO];
	//[(UIScrollView*)self.view setContentOffset:CGPointMake(0, -24)];
	
	NSMutableArray* appsInView = [NSMutableArray new];
	NSMutableArray* appsNotInView = [NSMutableArray new];
	
	[self startLiveTiles];
	
	for (RSTile* tile in pinnedTiles) {
		if (CGRectIntersectsRect(self.view.bounds, tile.basePosition)) {
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
	
	CGFloat sizeForPosition = [RSMetrics tileDimensionsForSize:1].width + [RSMetrics tileBorderSpacing];
	
	int minX = INT_MAX, maxX = INT_MIN, minY = INT_MAX, maxY = INT_MIN;
	for (RSTile* tile in pinnedTiles) {
		minX = MIN(tile.basePosition.origin.x / sizeForPosition, minX);
		maxX = MAX(tile.basePosition.origin.x / sizeForPosition, maxX);
		
		minY = MIN(tile.basePosition.origin.y / sizeForPosition, minY);
		maxY = MAX(tile.basePosition.origin.y / sizeForPosition, maxY);
	}
	
	float maxDelay = ((maxY - minY) * 0.01) + (maxX * 0.01);
	
	for (RSTile* tile in appsInView) {
		[tile.layer setShouldRasterize:YES];
		[tile.layer setRasterizationScale:[[UIScreen mainScreen] scale]];
		[tile.layer setContentsScale:[[UIScreen mainScreen] scale]];
		
		CGFloat layerX = -(tile.basePosition.origin.x - CGRectGetMidX(self.view.bounds))/tile.basePosition.size.width;
		CGFloat layerY = -(tile.basePosition.origin.y - CGRectGetMidY(self.view.bounds))/tile.basePosition.size.height;
		
		int tileX = tile.basePosition.origin.x / sizeForPosition;
		int tileY = tile.basePosition.origin.y / sizeForPosition;
		CGFloat delay = (tileX * 0.01) + (tileY - minY) * 0.01;
		
		[tile setCenter:CGPointMake(CGRectGetMidX(self.view.bounds),
									CGRectGetMidY(self.view.bounds))];
		[tile.layer setAnchorPoint:CGPointMake(layerX, layerY)];
		
		[scale setBeginTime:CACurrentMediaTime() + delay];
		[opacity setBeginTime:CACurrentMediaTime() + delay];
		
		[tile.layer addAnimation:scale forKey:@"scale"];
		[tile.layer addAnimation:opacity forKey:@"opacity"];
	}
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(maxDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self.view setUserInteractionEnabled:YES];
		
		for (RSTile* tile in pinnedTiles) {
			[tile setTiltEnabled:YES];
			[tile setUserInteractionEnabled:YES];
		}
	});
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(maxDelay + 0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		
		for (RSTile* tile in pinnedTiles) {
			[tile.layer removeAllAnimations];
			[tile.layer setOpacity:1];
			[tile setAlpha:1.0];
			[tile setHidden:NO];
			[tile.layer setAnchorPoint:CGPointMake(0.5,0.5)];
			[tile setCenter:[tile originalCenter]];
		}
	});
}

- (void)animateOut {
	// Home Screen to App
	[self.view setUserInteractionEnabled:NO];
	RSTile* sender = [self tileForLeafIdentifier:[[RSLaunchScreenController sharedInstance] launchIdentifier]];
	
	NSMutableArray* appsInView = [NSMutableArray new];
	NSMutableArray* appsNotInView = [NSMutableArray new];
	
	for (RSTile* tile in pinnedTiles) {
		[tile setTiltEnabled:NO];
		[tile.layer removeAllAnimations];
		[tile setTransform:CGAffineTransformIdentity];
		
		if (CGRectIntersectsRect(self.view.bounds, tile.basePosition)) {
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
	
	CGFloat sizeForPosition = [RSMetrics tileDimensionsForSize:1].width + [RSMetrics tileBorderSpacing];
	
	int minX = INT_MAX, maxX = INT_MIN, minY = INT_MAX, maxY = INT_MIN;
	for (RSTile* tile in pinnedTiles) {
		minX = MIN(tile.basePosition.origin.x / sizeForPosition, minX);
		maxX = MAX(tile.basePosition.origin.x / sizeForPosition, maxX);
		
		minY = MIN(tile.basePosition.origin.y / sizeForPosition, minY);
		maxY = MAX(tile.basePosition.origin.y / sizeForPosition, maxY);
	}
	
	float maxDelay = ((maxY - minY) * 0.01) + (maxX * 0.01);
	
	for (RSTile* tile in appsInView) {
		[tile.layer setShouldRasterize:YES];
		[tile.layer setRasterizationScale:[[UIScreen mainScreen] scale]];
		[tile.layer setContentsScale:[[UIScreen mainScreen] scale]];
		
		CGFloat layerX = -(tile.basePosition.origin.x - CGRectGetMidX(self.
																	  view.bounds))/tile.basePosition.size.width;
		CGFloat layerY = -(tile.basePosition.origin.y - CGRectGetMidY(self.view.bounds))/tile.basePosition.size.height;
		
		int tileX = tile.basePosition.origin.x / sizeForPosition;
		int tileY = tile.basePosition.origin.y / sizeForPosition;
		CGFloat delay = (tileX * 0.01) + (tileY - minY) * 0.01;
		
		[tile setCenter:CGPointMake(CGRectGetMidX(self.view.bounds),
									CGRectGetMidY(self.view.bounds))];
		[tile.layer setAnchorPoint:CGPointMake(layerX, layerY)];
		
		if (tile == sender) {
			[self.view sendSubviewToBack:tile];
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
		[self.view setUserInteractionEnabled:YES];
		
		for (RSTile* tile in pinnedTiles) {
			[tile.layer setOpacity:0];
			[tile.layer removeAllAnimations];
			[tile.layer setAnchorPoint:CGPointMake(0.5,0.5)];
			[tile setCenter:[tile originalCenter]];
		}
		
		[self stopLiveTiles];
	});
}

#pragma mark Live Tiles

- (void)startLiveTiles {
	for (RSTile* tile in pinnedTiles) {
		[tile startLiveTile];
	}
}

- (void)stopLiveTiles {
	for (RSTile* tile in pinnedTiles) {
		[tile stopLiveTile];
	}
}

@end
