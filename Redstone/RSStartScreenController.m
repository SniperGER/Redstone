#import "Redstone.h"

@implementation RSStartScreenController

- (id)init {
	self = [super init];
	
	if (self) {
		self.startScrollView = [[RSStartScrollView alloc] initWithFrame:CGRectMake(4, 0, screenWidth-8, screenHeight)];
		[self loadTiles];
	}
	
	return self;
}

- (void)loadTiles {
	self->pinnedTiles = [NSMutableArray new];
	NSArray* tileLayout = [NSArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/3ColumnDefaultLayout.plist", RESOURCE_PATH]];
	NSLog(@"[Redstone] %@/3ColumnDefaultLayout.plist", RESOURCE_PATH);
	
	for (int i=0; i<[tileLayout count]; i++) {
		if ([[[objc_getClass("SBIconController") sharedInstance] model] leafIconForIdentifier:[tileLayout objectAtIndex:i][@"bundleIdentifier"]]) {
			NSLog(@"[Redstone] %@", [tileLayout objectAtIndex:i][@"bundleIdentifier"]);
			
			CGFloat sizeForPosition = [RSMetrics tileDimensionsForSize:1].width + [RSMetrics tileBorderSpacing];
			CGSize tileSize = [RSMetrics tileDimensionsForSize:[[tileLayout objectAtIndex:i][@"size"] intValue]];
			
			CGRect tileFrame = CGRectMake(sizeForPosition * [[tileLayout objectAtIndex:i][@"column"] intValue],
										   sizeForPosition * [[tileLayout objectAtIndex:i][@"row"] intValue],
										   tileSize.width,
										   tileSize.height);
			
			RSTile* tile = [[RSTile alloc] initWithFrame:tileFrame leafIdentifier:[tileLayout objectAtIndex:i][@"bundleIdentifier"] size:[[tileLayout objectAtIndex:i][@"size"] intValue]];
			
			[self.startScrollView addSubview:tile];
			[self->pinnedTiles addObject:tile];
		}
	}
	
	[self updateStartContentSize];
}

- (void)updateStartContentSize {
	RSTile* lastTile = [self->pinnedTiles objectAtIndex:0];
	
	for (RSTile* tile in self->pinnedTiles) {
		if (tile.frame.origin.y > lastTile.frame.origin.y || (tile.frame.origin.y == lastTile.frame.origin.y && tile.frame.size.height > lastTile.frame.size.height)) {
			lastTile = tile;
		}
	}

	CGSize contentSize = CGSizeMake(self.startScrollView.frame.size.width,
									lastTile.frame.origin.y + lastTile.frame.size.height);
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
			if (tile != current && CGRectIntersectsRect(current.frame, tile.frame)) {
				[stack addObject:tile];
				
				CGFloat moveDistance = (CGRectGetMaxY(current.frame) - CGRectGetMinY(tile.frame)) + [RSMetrics tileBorderSpacing];
				
				[UIView animateWithDuration:.3 animations:^{
					[tile setEasingFunction:easeOutQuint forKeyPath:@"frame"];
					[tile setFrame:CGRectOffset(tile.frame, 0, moveDistance)];
				} completion:^(BOOL finished) {
					[tile removeEasingFunctionForKeyPath:@"frame"];
				}];
				
			}
		}
	}
}
@end
