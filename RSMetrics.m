#import "RSMetrics.h"

@implementation RSMetrics

int columns = 2;

int largeScreenSize = 414;
int mediumScreenSize = 375;
int smallScreenSize = 320;

+(void)initialize {
	if ([[UIScreen mainScreen] bounds].size.width >= 414) {
		columns = 3;
	} else {
		if ([[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/Preferences/ml.festival.redstone.plist"]) {
			NSDictionary* settings = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/ml.festival.redstone.plist"];
			if ([[settings objectForKey:@"showMoreTiles"] boolValue]) {
				columns = 3;
			}
		}
	}
}

+(CGSize)tileDimensionsForSize:(int)size {
	int screenWidth = (int)[[UIScreen mainScreen] bounds].size.width;

	switch (screenWidth) {
		case 414:
			if (size == 1) {
				return CGSizeMake(63, 63);
			} else if (size == 2) {
				return CGSizeMake(131, 131);
			} else if (size == 3) {
				return CGSizeMake(267, 131);
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
				}
			} else if (columns == 2) {
				if (size == 1) {
					return CGSizeMake(88, 88);
				} else if (size == 2) {
					return CGSizeMake(180, 180);
				} else if (size == 3) {
					return CGSizeMake(365, 180);
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
					return CGSizeMake(206, 206);
				}
			} else if (columns == 2) {
				if (size == 1) {
					return CGSizeMake(73.25, 73.25);
				} else if (size == 2) {
					return CGSizeMake(151.5, 151.5);
				} else if (size == 3) {
					return CGSizeMake(308, 151.5);
				}
			}
			break;
		default: break;
	}
	return CGSizeZero;
}

+(int)tileBorderSpacing {
	return 5;
}

+(int)tilePositionsOfSizePerRow:(CGSize)size {
	if ([self tileDimensionsForSize:1].width == size.width) {
		return 2 * columns;
	} else if ([self tileDimensionsForSize:2].width == size.width) {
		return 2 * columns - 1;
	} else if ([self tileDimensionsForSize:3].width == size.width) {
		return 2 * columns - 3;
	}

	return 0;
}

+(int)columns {
	return columns;
}

@end