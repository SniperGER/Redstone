/**
 @class RSAesthetics
 @author Sniper_GER
 @discussion A class that controls various design aspects of Redstone
 */

#import <UIKit/UIKit.h>

@class RSTileInfo;

@interface RSAesthetics : NSObject


/**
 Returns a user's currently selected Lock Screen wallpaper

 @return A UIImage representing a user's currently selected Lock Screen wallpaper
 */
+ (UIImage*)lockScreenWallpaper;

/**
 Returns a user's currently selected Home Screen wallpaper. If the user uses the same image for both the Lock Screen and the Home Screen, the Lock Screen wallpaper is returned instead
 
 @return A UIImage representing a user's currently selected Home Screen wallpaper
 */
+ (UIImage*)homeScreenWallpaper;

/**
 Returns the currently selected accent color

 @return An UIColor object with the currently selected accent color
 */
+ (UIColor*)accentColor;

/**
 Returns the accent color for a specific tile. If the tile doesn't have it's own accent color, the global accent color is returned instead
 
 @param tileInfo The tile info representing a specific tile
 @return An UIColor object with the accent color as defined in
 */

+ (UIColor*)accentColorForTile:(RSTileInfo*)tileInfo;

/**
 Returns the currently selected tile opacity

 @return The currently selected tile opacity
 */
+ (CGFloat)tileOpacity;

/**
 Returns the colors for the currently selected theme as a dictionary

 @return A dictionary containing color objects for various keys used throughout Redstone
 */
+ (NSDictionary*)colorsForCurrentTheme;

+ (UIImage*)getImageForTileWithBundleIdentifier:(NSString*)bundleIdentifier;

+ (UIImage*)getImageForTileWithBundleIdentifier:(NSString*)bundleIdentifier size:(int)size colored:(BOOL)colored;

+ (UIColor *)readableForegroundColorForBackgroundColor:(UIColor*)backgroundColor;

@end
