#import "Redstone.h"

@implementation RSMetrics

int columns = 3;

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
		default: break;
	}
	
	return CGSizeZero;
}

+ (CGFloat)tileBorderSpacing {
	return 5.0;
}

@end
