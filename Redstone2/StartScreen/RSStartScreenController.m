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
	[(UIScrollView*)self.view setContentSize:CGSizeMake(self.view.frame.size.width, 1000)];
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
}

- (void)saveTiles {
	
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
					}];
				}
			}
		}
	}
	
	[self eliminateEmptyRows];
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
		}
	}];
}

@end
