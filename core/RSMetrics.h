/*
 * Redstone
 * A Windows 10 Mobile experience for iOS
 * Compatible with iOS 9 (tested with iOS 9.3.3);
 *
 * Licensed under GNU GPLv3
 *
 * © 2016 Sniper_GER, FESTIVAL Development
 * All rights reserved.
 */

@interface RSMetrics : NSObject

+ (void)initialize;
+ (CGSize)tileDimensionsForSize:(int)size;
+ (CGSize)tileImageDimensionsForSize:(int)size;
+ (int)tileBorderSpacing;
+ (int)columns;

@end