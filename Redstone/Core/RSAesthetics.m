#import "../Redstone.h"

extern CFArrayRef CPBitmapCreateImagesFromData(CFDataRef cpbitmap, void*, int, void*);

@implementation RSAesthetics

+ (UIImage*)getCurrentWallpaper {
	NSData* homescreenWallpaper = [NSData dataWithContentsOfFile:@"/var/mobile/Library/SpringBoard/HomeBackground.cpbitmap"];
	
	if (!homescreenWallpaper) {
		homescreenWallpaper = [NSData dataWithContentsOfFile:@"/var/mobile/Library/SpringBoard/LockBackground.cpbitmap"];
	}
	
	if (homescreenWallpaper) {
		CFDataRef homeWallpaperDataRef = (__bridge CFDataRef)homescreenWallpaper;
		NSArray* imageArray = (__bridge NSArray*)CPBitmapCreateImagesFromData(homeWallpaperDataRef, NULL, 1, NULL);
		UIImage* homeWallpaper = [UIImage imageWithCGImage:(CGImageRef)imageArray[0]];
		
		return homeWallpaper;
	} else {
		UIImage* baseImage = [self imageWithColor:[UIColor blackColor] size:[UIScreen mainScreen].bounds.size];
		return baseImage;
	}
}

+ (UIImage*)getImageForTileWithBundleIdentifier:(NSString*)bundleIdentifier {
	NSString* imagePath = [NSString stringWithFormat:@"%@/Tiles/%@/tile", RESOURCE_PATH, bundleIdentifier];
	UIImage* tileImage = [[UIImage imageWithContentsOfFile:imagePath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	
	return tileImage;
}

+ (UIImage*) imageWithColor:(UIColor*)color size:(CGSize)size {
	UIGraphicsBeginImageContext(size);
	UIBezierPath* rPath = [UIBezierPath bezierPathWithRect:CGRectMake(0., 0., size.width, size.height)];
	[color setFill];
	[rPath fill];
	UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}

@end
