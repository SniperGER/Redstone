/**
 @class RSAesthetics
 @author Sniper_GER
 @discussion A class that controls various design aspects of Redstone
 */

#import <UIKit/UIKit.h>

@interface RSAesthetics : NSObject


/**
 Returns the currently selected accent color

 @return An UIColor object with the currently selected accent color
 */
+ (UIColor*)accentColor;

/**
 Returns the colors for a specified theme name \p themeName as a dictionary

 @param themeName The theme name. Can be either \p dark or \p light
 @return A dictionary containing color objects for various keys used throughout Redstone
 */
+ (NSDictionary*)colorsForTheme:(NSString*)themeName;

@end
