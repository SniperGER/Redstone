#import "UIImageAverageColorAddition.h"

@interface RSAesthetics : NSObject {
	//UIImage* homeWallpaper;
	//NSData homeWallpaperData;
}

+(UIColor*)accentColor;
+(UIColor *)accentColorForApp:(NSString *)bundleIdentifier;
+(UIColor *)accentColorForLaunchScreen:(NSString *)bundleIdentifier;
+(UIImage*)getTileImage:(NSString*)bundleIdentifier withSize:(NSInteger)size;
+(CGFloat)getTileOpacity;

@end