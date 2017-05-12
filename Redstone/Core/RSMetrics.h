#import <UIKit/UIKit.h>

@interface RSMetrics : NSObject

+ (CGSize)tileDimensionsForSize:(int)size;
+ (CGSize)tileIconDimensionsForSize:(int)size;
+ (CGFloat)tileBorderSpacing;
+ (int)columns;

@end
