#import "../Redstone.h"

@implementation RSStartScreenController

- (void)loadView {
	self.view = [[UIScrollView alloc] initWithFrame:CGRectMake(4, 0, screenWidth-8, screenHeight)];
	[(UIScrollView*)self.view setContentSize:CGSizeMake(self.view.frame.size.width, 1000)];
	[(UIScrollView*)self.view setContentInset:UIEdgeInsetsMake(24, 0, 70, 0)];
	[(UIScrollView*)self.view setContentOffset:CGPointMake(0, -24)];
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
			
			RSTile* tile = [[RSTile alloc] initWithFrame:tileFrame];
			
			[self.view addSubview:tile];
			[pinnedTiles addObject:tile];
			[pinnedLeafIdentifiers addObject:[icon applicationBundleID]];
		}
	}
}

- (void)saveTiles {
	
}

#pragma mark Editing Mode

- (void)moveAffectedRowsForTile:(RSTile*)tile {
	
}

- (void)eliminateEmptyRows {
	CGFloat sizeForPosition = [RSMetrics tileDimensionsForSize:1].width + [RSMetrics tileBorderSpacing];
	
	for (RSTile* tile in pinnedTiles) {
		NSInteger yPosition = tile.frame.origin.y / sizeForPosition;
		
		if (yPosition > 0) {
			for (int i = (yPosition-1); i>=0; i--) {
				CGRect testFrame = CGRectMake(tile.frame.origin.x, i*sizeForPosition, tile.frame.size.width, tile.frame.size.height);
				
				BOOL canSetFrame = YES;
				for (RSTile* view in pinnedTiles) {
					if (view != tile) {
						if (CGRectIntersectsRect(testFrame, view.frame)) {
							canSetFrame = NO;
							break;
						}
					}
				}
				
				if (canSetFrame) {
					[tile setFrame:testFrame];
				} else {
					break;
				}
			}
		}
	}
}

@end
