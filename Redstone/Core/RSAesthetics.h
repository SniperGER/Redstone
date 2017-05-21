#import <UIKit/UIKit.h>

@interface RSAesthetics : NSObject

+ (UIImage*)lockScreenWallpaper;
+ (UIImage*)homeScreenWallpaper;
+ (UIImage*)getImageForTileWithBundleIdentifier:(NSString*)bundleIdentifier;
+ (UIImage*)getImageForTileWithBundleIdentifier:(NSString*)bundleIdentifier size:(int)size;
+ (UIColor*)accentColor;
+ (UIColor*)accentColorForTile:(NSString*)bundleIdentifier;
+ (UIColor*)accentColorForLaunchScreen:(NSString*)bundleIdentifier;
+ (NSString*)localizedStringForKey:(NSString*)key;

@end
