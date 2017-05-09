#import "Redstone.h"

@implementation RSMetrics

int columns;

+ (void)initialize {
	columns = 3;
}

+ (CGSize)tileDimensionsForSize:(int)size {
	switch ((int)screenWidth) {
		case 414:
			if (size == 1) {
				return CGSizeMake(63.5, 63.5);
			} else if (size == 2) {
				return CGSizeMake(132, 132);
			} else if (size == 3) {
				return CGSizeMake(269, 132);
			} else if (size == 4) {
				return CGSizeMake(269, 269);
			}
			break;
		case 375:
			if (columns == 3) {
				if (size == 1) {
					return CGSizeMake(57, 57);
				} else if (size == 2) {
					return CGSizeMake(119, 119);
				} else if (size == 3) {
					return CGSizeMake(243, 119);
				} else if (size == 4) {
					return CGSizeMake(243, 243);
				}
			} else if (columns == 2) {
				if (size == 1) {
					return CGSizeMake(88, 88);
				} else if (size == 2) {
					return CGSizeMake(181, 181);
				} else if (size == 3) {
					return CGSizeMake(367, 181);
				} else if (size == 4) {
					return CGSizeMake(367, 367);
				}
			}
		case 320:
			if (columns == 3) {
				if (size == 1) {
					return CGSizeMake(47.83333, 47.83333);
				} else if (size == 2) {
					return CGSizeMake(100.66666, 100.66666);
				} else if (size == 3) {
					return CGSizeMake(206.33333, 100.66666);
				} else if (size == 4) {
					return CGSizeMake(206.33333, 206.33333);
				}
			} else if (columns == 2) {
				if (size == 1) {
					return CGSizeMake(74.25, 74.25);
				} else if (size == 2) {
					return CGSizeMake(153.5, 153.5);
				} else if (size == 3) {
					return CGSizeMake(312, 153.5);
				} else if (size == 4) {
					return CGSizeMake(312, 312);
				}
			}
		default: break;
	}
	
	return CGSizeZero;
}

+ (CGSize)tileIconDimensionsForSize:(int)size {
	switch ((int)screenWidth) {
		case 414:
			if (size == 1) {
				return CGSizeMake(31.75, 31.75);
			} else if (size == 2 || size == 3) {
				return CGSizeMake(44, 44);
			} else if (size == 4) {
				return CGSizeMake(89.66666, 89.66666);
			}
			break;
		default: break;
	}
	
	return CGSizeZero;
}

+ (CGFloat)tileBorderSpacing {
	return 5.0;
}

@end
