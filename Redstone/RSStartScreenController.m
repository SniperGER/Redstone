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
	
	CGSize mediumSize = [RSMetrics tileDimensionsForSize:2];
	RSTile* tile1 = [[RSTile alloc] initWithFrame:CGRectMake(0, 0, mediumSize.width, mediumSize.height) leafIdentifier:@"com.apple.Maps" size:2];
	[self.startScrollView addSubview:tile1];
	
	[self->pinnedTiles addObject:tile1];
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
