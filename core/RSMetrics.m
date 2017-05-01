#import "../RedstoneHeaders.h"

/*
	Tile Icon sizes
	small: 44px
	medium: 60px
	wide: 60px
	large: 120px

	Tile Image sizes
	small: 88px x 88px
	medium: 180px x 180px
	wide: 365px x 180px
	large: 365px x 365px

	Circle stroke width: 8px @1x
*/

int columns = 2;

@implementation RSMetrics

+ (void)initialize {
	if (screenW >= 414) {
		columns = 3;
	} else {
		if ([[[RSPreferences preferences] objectForKey:@"showMoreTiles"] boolValue]) {
			columns = 3;
		}
	}
}

+ (CGSize)tileDimensionsForSize:(int)size {
	switch ((int)screenW) {
		case 414:
			if (size == 1) {
				return CGSizeMake(63,63);
			} else if (size == 2) {
				return CGSizeMake(131,131);
			} else if (size == 3) {
				return CGSizeMake(267,131);
			} else if (size == 4) {
				return CGSizeMake(267, 267);
			}
			break;
		case 375:
			if (columns == 3) {
				if (size == 1) {
					return CGSizeMake(57, 57);
				} else if (size == 2) {
					return CGSizeMake(119, 119);
				} else if (size == 3) {
					return CGSizeMake(242, 119);
				} else if (size == 4) {
					return CGSizeMake(242, 242);
				}
			} else if (columns == 2) {
				if (size == 1) {
					return CGSizeMake(88, 88);
				} else if (size == 2) {
					return CGSizeMake(180, 180);
				} else if (size == 3) {
					return CGSizeMake(365, 180);
				} else if (size == 4) {
					return CGSizeMake(365, 365);
				}
			}
			break;
		case 320: 
			if (columns == 3) {
				if (size == 1) {
					return CGSizeMake(48, 48);
				} else if (size == 2) {
					return CGSizeMake(101, 101);
				} else if (size == 3) {
					return CGSizeMake(206, 101);
				} else if (size == 4) {
					return CGSizeMake(206, 206);
				}
			} else if (columns == 2) {
				if (size == 1) {
					return CGSizeMake(73.25, 73.25);
				} else if (size == 2) {
					return CGSizeMake(151.5, 151.5);
				} else if (size == 3) {
					return CGSizeMake(308, 151.5);
				} else if (size == 4) {
					return CGSizeMake(308, 308);
				}
			}
			break;
		default: break;
	}
	return CGSizeZero;
}

+ (CGSize)tileImageDimensionsForSize:(int)size {
	CGSize tileSize = [self tileDimensionsForSize:size];
	switch (size) {
		case 1:
			tileSize.width = ceil(tileSize.width * 0.5);
			tileSize.height = tileSize.width;
			break;
		case 2:
			tileSize.width = ceil(tileSize.width * 0.33);
			tileSize.height = tileSize.width;
			break;
		case 3:
		case 4:
			tileSize.height = ceil(tileSize.height * 0.33);
			tileSize.width = tileSize.height;
			break;
		
		default: break;
	}

	return tileSize;
}

+ (int)tileBorderSpacing {
	return 5;
}

+ (int)tilePositionsOfSizePerRow:(CGSize)size {
	if ([self tileDimensionsForSize:1].width == size.width) {
		return 2 * columns;
	} else if ([self tileDimensionsForSize:2].width == size.width) {
		return 2 * columns - 1;
	} else if ([self tileDimensionsForSize:3].width == size.width) {
		return 2 * columns - 3;
	}

	return 0;
}

+ (int)columns {
	return columns;
}

@end