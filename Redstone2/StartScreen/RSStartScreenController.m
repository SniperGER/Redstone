#import "../Redstone.h"

@implementation RSStartScreenController

- (void)loadView {
	self.view = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
	[(UIScrollView*)self.view setContentSize:CGSizeMake(screenWidth, 1000)];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self loadTiles];
}

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
			
			UIView* tile = [[UIView alloc] initWithFrame:tileFrame];
			[tile setBackgroundColor:[UIColor blueColor]];
			
			[self.view addSubview:tile];
			[pinnedTiles addObject:tile];
			[pinnedLeafIdentifiers addObject:[icon applicationBundleID]];
		}
	}
}

- (void)saveTiles {
	
}

@end
