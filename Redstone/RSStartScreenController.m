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
	
	CGSize smallSize = [RSMetrics tileDimensionsForSize:1];
	RSTile* tile1 = [[RSTile alloc] initWithFrame:CGRectMake(274, 137, smallSize.width, smallSize.height)];
	[self.startScrollView addSubview:tile1];
	[self->pinnedTiles addObject:tile1];
	
	CGSize mediumSize = [RSMetrics tileDimensionsForSize:2];
	RSTile* tile2 = [[RSTile alloc] initWithFrame:CGRectMake(0, 0, mediumSize.width, mediumSize.height)];
	[self.startScrollView addSubview:tile2];
	[self->pinnedTiles addObject:tile2];
	
	CGSize wideSize = [RSMetrics tileDimensionsForSize:3];
	RSTile* tile3 = [[RSTile alloc] initWithFrame:CGRectMake(137, 0, wideSize.width, wideSize.height)];
	[self.startScrollView addSubview:tile3];
	[self->pinnedTiles addObject:tile3];
	
	CGSize largeSize = [RSMetrics tileDimensionsForSize:4];
	RSTile* tile4 = [[RSTile alloc] initWithFrame:CGRectMake(0, 137, largeSize.width, largeSize.width)];
	[self.startScrollView addSubview:tile4];
	[self->pinnedTiles addObject:tile4];
}

- (void)moveDownAffectedTilesForTile:(RSTile*)movedTile withFrame:(CGRect)tileFrame {
	NSMutableArray* affectedTiles = [NSMutableArray new];
	CGFloat intersectionWidth = 0, intersectionHeight = 0;
	
	for (RSTile* tile in self->pinnedTiles) {
		if (tile != movedTile) {
			if (CGRectIntersectsRect(tileFrame, tile.frame)) {
				[affectedTiles addObject:tile];

				intersectionHeight = (CGRectGetMaxY(tileFrame) - CGRectGetMinY(tile.frame)) + [RSMetrics tileBorderSpacing];
				[affectedTiles addObjectsFromArray:[self affectedTilesForTile:tile moveDistance:intersectionHeight horizontal:NO]];
				
				break;
			}
		
			/*if (tile.frame.origin.y >= tileFrame.origin.y) {
				[UIView animateWithDuration:.3 animations:^{
					[tile setEasingFunction:easeOutQuint forKeyPath:@"frame"];
					[tile setFrame:CGRectMake(tile.frame.origin.x, tile.frame.origin.y+tileFrame.size.height, tile.frame.size.width, tile.frame.size.height)];
				} completion:^(BOOL finished) {
					[tile removeEasingFunctionForKeyPath:@"frame"];
				}];
			}*/
		}
	}
	
	if ([affectedTiles count] > 0) {
		[UIView animateWithDuration:.3 animations:^{
			for (RSTile* tile in affectedTiles) {
				[tile setEasingFunction:easeOutQuint forKeyPath:@"frame"];
				[tile setFrame:CGRectOffset(tile.frame, intersectionWidth, intersectionHeight)];
			}
		} completion:^(BOOL finished) {
			for (RSTile* tile in affectedTiles) {
				[tile removeEasingFunctionForKeyPath:@"frame"];
			}
		}];
	}
}

- (NSArray*)affectedTilesForTile:(RSTile*)tile moveDistance:(CGFloat)distance horizontal:(BOOL)horizontal {
	NSMutableArray* affectedTiles = [NSMutableArray new];
	
	CGRect changedFrame = CGRectOffset(tile.frame, 0, distance);
	for (RSTile* _tile in self->pinnedTiles) {
		if (_tile.frame.origin.y > tile.frame.origin.y) {
			if (CGRectIntersectsRect(_tile.frame, changedFrame)) {
				[affectedTiles addObject:_tile];
				
				[affectedTiles addObjectsFromArray:[self affectedTilesForTile:_tile moveDistance:distance horizontal:horizontal]];
			}
		}
	}
	
	return affectedTiles;
}

@end
