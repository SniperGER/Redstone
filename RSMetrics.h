#import <UIKit/UIKit.h>

@interface RSMetrics : NSObject

+(void)initialize;
+(CGSize)tileDimensionsForSize:(int)size;
+(int)tilePositionsOfSizePerRow:(CGSize)size;
+(int)tileBorderSpacing;
+(int)columns;

@end 