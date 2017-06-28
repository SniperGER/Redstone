/**
 @class RSMetrics
 @author Sniper_GER
 @discussion Provides measurements for tiles, tile icons and other things that requires sizes
 */

#import <UIKit/UIKit.h>

@interface RSMetrics : NSObject


/**
 Returns the currently active column count

 @return A \p NSInteger representing the currently active column count
 */
+ (NSInteger)columns;


/**
 Returns a \p CGSize object for a specified tile size \p size

 @param size The tile size as specified in the tile layout settings
 @return A \p CGSize object for a specified tile size \p size
 */
+ (CGSize)tileDimensionsForSize:(NSInteger)size;


/**
 Returns the \p CGSize for tile icons for a specified tile size \p size

 @param size The tile size as specified in the tile layout settings
 @return The \p CGSize for tile icons for a specified tile size \p size
 */
+ (CGSize)tileIconDimensionsForSize:(NSInteger)size;


/**
 Returns the \p float for the spacing between tiles

 @return The \p float for the spacing between tiles
 */
+ (CGFloat)tileBorderSpacing;

@end
