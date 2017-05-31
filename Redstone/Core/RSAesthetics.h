#import <UIKit/UIKit.h>

@class RSTileInfo;

@interface RSAesthetics : NSObject

+ (UIImage*)lockScreenWallpaper;
+ (UIImage*)homeScreenWallpaper;
+ (UIImage*)getImageForTileWithBundleIdentifier:(NSString*)bundleIdentifier;
+ (UIImage*)getImageForTileWithBundleIdentifier:(NSString*)bundleIdentifier size:(int)size;
+ (UIColor*)accentColor;
+ (UIColor*)accentColorForTile:(RSTileInfo*)tileInfo;
+ (UIColor*)accentColorForLaunchScreen:(RSTileInfo*)tileInfo;
+ (NSString*)localizedStringForKey:(NSString*)key;

@end
