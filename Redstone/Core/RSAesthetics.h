#import <UIKit/UIKit.h>

@interface RSAesthetics : NSObject

+ (UIImage*)getCurrentWallpaper;
+ (UIImage*)getImageForTileWithBundleIdentifier:(NSString*)bundleIdentifier;
+ (UIColor*)accentColor;
+ (UIColor*)accentColorForTile:(NSString*)bundleIdentifier;
+ (UIColor*)accentColorForLaunchScreen:(NSString*)bundleIdentifier;
+ (NSString*)localizedStringForKey:(NSString*)key;

@end
