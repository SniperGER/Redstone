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
	CGSize smallSize = [RSMetrics tileDimensionsForSize:1];
	RSTile* tile1 = [[RSTile alloc] initWithFrame:CGRectMake(0, 137, smallSize.width, smallSize.height)];
	[self.startScrollView addSubview:tile1];
	
	CGSize mediumSize = [RSMetrics tileDimensionsForSize:2];
	RSTile* tile2 = [[RSTile alloc] initWithFrame:CGRectMake(0, 0, mediumSize.width, mediumSize.height)];
	[self.startScrollView addSubview:tile2];
	
	CGSize largeSize = [RSMetrics tileDimensionsForSize:3];
	RSTile* tile3 = [[RSTile alloc] initWithFrame:CGRectMake(137, 0, largeSize.width, largeSize.height)];
	[self.startScrollView addSubview:tile3];
}

@end
