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
	
	[self loadTiles];
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

#pragma mark Editing Mode

- (void)setIsEditing:(BOOL)isEditing {
	if (!_isEditing && isEditing) {
		AudioServicesPlaySystemSound(1520);
	}
	
	_isEditing = isEditing;
	[[RSHomeScreenController sharedInstance] setScrollEnabled:!isEditing];
	
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
	
	[UIView animateWithDuration:.3 animations:^{
		[tile setEasingFunction:easeOutQuint forKeyPath:@"frame"];
		[tile setCenter:newCenter];
		[tile setOriginalCenter:tile.center];
	} completion:^(BOOL finished) {
		[tile removeEasingFunctionForKeyPath:@"frame"];
	}];
	
	[self moveAffectedTilesForTile:tile];
}

- (void)moveAffectedTilesForTile:(RSTile *)movedTile {
	// This algorithm is based on Daniel T.'s answer here:
	// http://stackoverflow.com/questions/43825803/get-all-uiviews-affected-by-moving-another-uiview-above-them/
	
	NSMutableArray* stack = [NSMutableArray new];
	//CGFloat step = [RSMetrics tileDimensionsForSize:1].width + [RSMetrics tileBorderSpacing];
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
					[movedTile setOriginalCenter:movedTile.center];
				}];
				
				didMoveTileIntoPosition = YES;
			} else if (tile != current && CGRectIntersectsRect(current.basePosition, tile.basePosition)) {
				[stack addObject:tile];
				
				CGFloat moveDistance = (CGRectGetMaxY(current.basePosition) - CGRectGetMinY(tile.basePosition)) + [RSMetrics tileBorderSpacing];
				CGRect newFrame = CGRectMake(tile.frame.origin.x,
											 tile.frame.origin.y + moveDistance,
											 tile.frame.size.width,
											 tile.frame.size.height);
				
				[tile.layer removeAllAnimations];
				
				if (tile == self.selectedTile) {
					[tile setFrame:newFrame];
				} else {
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
	}
	
#if TARGET_OS_SIMULATOR
	[self updateStartContentSize];
#else
	[self eliminateEmptyRows];
#endif
}

- (void)eliminateEmptyRows {
	NSArray* sortedViews = [pinnedTiles sortedArrayUsingComparator:^NSComparisonResult(RSTile* tile1, RSTile* tile2) {
		if (tile1.basePosition.origin.y == tile2.basePosition.origin.y) {
			return [[NSNumber numberWithFloat:tile1.basePosition.origin.x] compare:[NSNumber numberWithFloat:tile2.basePosition.origin.x]];
		} else {
			return [[NSNumber numberWithFloat:tile1.basePosition.origin.y] compare:[NSNumber numberWithFloat:tile2.basePosition.origin.y]];
		}
	}];
	
	CGFloat sizeForPosition = [RSMetrics tileDimensionsForSize:1].width + [RSMetrics tileBorderSpacing];
	
	[UIView animateWithDuration:.3 animations:^{
		for (RSTile* tile in sortedViews) {
			int yPosition = tile.basePosition.origin.y / sizeForPosition;
			for (int i=0; i<yPosition; i++) {
				CGRect testFrame = CGRectMake(tile.basePosition.origin.x,
											  i * sizeForPosition,
											  tile.basePosition.size.width,
											  tile.basePosition.origin.y - (i * sizeForPosition));
				
				BOOL canSetFrame = YES;
				for (RSTile* view in sortedViews) {
					if (view != tile) {
						if (CGRectIntersectsRect(testFrame, [view basePosition])) {
							canSetFrame = NO;
							break;
						}
					}
				}
				
				if (canSetFrame) {
					CGRect newFrame = CGRectMake(tile.frame.origin.x,
												 tile.frame.origin.y - testFrame.size.height,
												 tile.frame.size.width,
												 tile.frame.size.height);
					
					
					[tile.layer removeAllAnimations];
					[tile setEasingFunction:easeOutQuint forKeyPath:@"frame"];
					[tile setFrame:newFrame];
					break;
				}
			}
		}
	} completion:^(BOOL finished) {
		for (RSTile* tile in sortedViews) {
			[tile removeEasingFunctionForKeyPath:@"frame"];
			[tile setOriginalCenter:tile.center];
		}
		
		[self updateStartContentSize];
	}];
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
	[(UIScrollView*)self.view setContentOffset:CGPointMake(0, -24)];
	
	NSMutableArray* appsInView = [NSMutableArray new];
	NSMutableArray* appsNotInView = [NSMutableArray new];
	
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
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(maxDelay + 0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self.view setUserInteractionEnabled:YES];
		for (RSTile* tile in pinnedTiles) {
			[tile setTiltEnabled:YES];
			[tile setUserInteractionEnabled:YES];
			[tile.layer removeAllAnimations];
			[tile.layer setOpacity:1];
			[tile setAlpha:1.0];
			[tile setHidden:NO];
			[tile.layer setAnchorPoint:CGPointMake(0.5,0.5)];
			[tile setCenter:[tile originalCenter]];
			
			//[tile startLiveTile];
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
	});
}

@end
