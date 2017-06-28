#import "../Redstone.h"

@implementation RSMetrics

int columns = 3;

+ (NSInteger)columns {
	return columns;
}

+ (CGSize)tileDimensionsForSize:(NSInteger)size {
	CGFloat baseTileWidth = 0;
	if (columns == 3) {
		baseTileWidth = (screenWidth - 8 - ([self tileBorderSpacing] * 5)) / 6;
	} else if (columns == 2) {
		baseTileWidth = (screenWidth - 8 - ([self tileBorderSpacing] * 3)) / 4;
	}
	
	switch (size) {
		case 1:
			return CGSizeMake(baseTileWidth, baseTileWidth);
		case 2:
			return CGSizeMake(baseTileWidth*2 + [self tileBorderSpacing], baseTileWidth * 2 + [self tileBorderSpacing]);
		case 3:
			return CGSizeMake((baseTileWidth * 4) + ([self tileBorderSpacing] * 3), baseTileWidth * 2 + [self tileBorderSpacing]);
		case 4:
			return CGSizeMake((baseTileWidth * 4) + ([self tileBorderSpacing] * 3), (baseTileWidth * 4) + ([self tileBorderSpacing] * 3));
	}
	
	return CGSizeZero;
}

+ (CGSize)tileIconDimensionsForSize:(NSInteger)size {
	return CGSizeZero;
}

+ (CGFloat)tileBorderSpacing {
	return 5.0;
}

@end
