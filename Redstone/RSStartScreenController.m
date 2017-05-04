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
	RSTile* tile1 = [[RSTile alloc] initWithFrame:CGRectMake(0, 137, smallSize.width, smallSize.height)];
	[self.startScrollView addSubview:tile1];
	[self->pinnedTiles addObject:tile1];
	
	CGSize mediumSize = [RSMetrics tileDimensionsForSize:2];
	RSTile* tile2 = [[RSTile alloc] initWithFrame:CGRectMake(0, 0, mediumSize.width, mediumSize.height)];
	[self.startScrollView addSubview:tile2];
	[self->pinnedTiles addObject:tile2];
	
	CGSize largeSize = [RSMetrics tileDimensionsForSize:3];
	RSTile* tile3 = [[RSTile alloc] initWithFrame:CGRectMake(137, 0, largeSize.width, largeSize.height)];
	[self.startScrollView addSubview:tile3];
	[self->pinnedTiles addObject:tile3];
}

- (void)moveDownAffectedTilesForTile:(RSTile*)movedTile withFrame:(CGRect)tileFrame {
	for (RSTile* tile in self->pinnedTiles) {
		if (tile != movedTile) {
			if (CGRectIntersectsRect(tileFrame, tile.frame)) {
				NSLog(@"[Redstone] intersect");
				
				CGFloat intersectWidth;
				if (tileFrame.origin.x <= tile.frame.origin.x) {
					intersectWidth = CGRectGetMaxX(tileFrame) - CGRectGetMinX(tile.frame);
				} else {
					intersectWidth = CGRectGetMaxX(tile.frame) - CGRectGetMinX(tileFrame);
				}
				
				if (intersectWidth >= [RSMetrics tileDimensionsForSize:1].width/2) {
					for (RSTile* _tile in self->pinnedTiles) {
						if (_tile != movedTile) {
							if (_tile.frame.origin.y >= tile.frame.origin.y) {
								[UIView animateWithDuration:.3 animations:^{
									[_tile setEasingFunction:easeOutQuint forKeyPath:@"frame"];
									[_tile setFrame:CGRectMake(_tile.frame.origin.x,
															  _tile.frame.origin.y + tileFrame.size.height + [RSMetrics tileBorderSpacing],
															  _tile.frame.size.width,
															  _tile.frame.size.height)];
								} completion:^(BOOL finished) {
									[_tile removeEasingFunctionForKeyPath:@"frame"];
								}];
							}
						}
					}
				}
				
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
}

@end
