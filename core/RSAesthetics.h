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

@interface RSAesthetics : NSObject

+ (UIColor*)themeColor;
+ (UIColor*)textColor;
+ (UIColor *)accentColor;
+ (UIColor *)accentColorForApp:(NSString *)bundleIdentifier;
+ (UIColor *)accentColorForLaunchScreen:(NSString *)bundleIdentifier;
+ (UIImage*)tileImageForApp:(NSString*)bundleIdentifier withSize:(NSInteger)size;
+ (CGFloat)tileOpacity;
+ (CGFloat)tileOpacityForApp:(NSString*)bundleIdentifier;
+ (UIImage*)getCurrentHomeWallpaper;
+ (id)localizedStringForKey:(NSString*)key;

@end