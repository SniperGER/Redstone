#import "../Redstone.h"

extern CFArrayRef CPBitmapCreateImagesFromData(CFDataRef cpbitmap, void*, int, void*);
NSBundle* redstoneBundle;

@implementation RSAesthetics

+ (UIImage*)lockScreenWallpaper {
	NSData* lockscreenWallpaper = [NSData dataWithContentsOfFile:LOCK_WALLPAPER_PATH];
	
	if (lockscreenWallpaper) {
		CFDataRef lockWallpaperDataRef = (__bridge CFDataRef)lockscreenWallpaper;
		NSArray* imageArray = (__bridge NSArray*)CPBitmapCreateImagesFromData(lockWallpaperDataRef, NULL, 1, NULL);
		UIImage* lockWallpaper = [UIImage imageWithCGImage:(CGImageRef)imageArray[0]];
		
		return lockWallpaper;
	} else {
		UIImage* baseImage = [self imageWithColor:[UIColor blackColor] size:[UIScreen mainScreen].bounds.size];
		return baseImage;
	}
}

+ (UIImage*)homeScreenWallpaper {
	NSData* homescreenWallpaper = [NSData dataWithContentsOfFile:HOME_WALLPAPER_PATH];
	
	if (!homescreenWallpaper) {
		return [self lockScreenWallpaper];
	} else {
		CFDataRef homeWallpaperDataRef = (__bridge CFDataRef)homescreenWallpaper;
		NSArray* imageArray = (__bridge NSArray*)CPBitmapCreateImagesFromData(homeWallpaperDataRef, NULL, 1, NULL);
		UIImage* homeWallpaper = [UIImage imageWithCGImage:(CGImageRef)imageArray[0]];
		
		return homeWallpaper;
	}
	
	//return [[[objc_getClass("SBWallpaperController") sharedInstance] homescreenWallpaperView] image];
}

+ (UIImage*)getImageForTileWithBundleIdentifier:(NSString*)bundleIdentifier {
	NSString* imagePath = [NSString stringWithFormat:@"%@/Tiles/%@/tile", RESOURCE_PATH, bundleIdentifier];
	UIImage* tileImage = [[UIImage imageWithContentsOfFile:imagePath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	
	if (!tileImage) {
		UIImage* defaultAppIcon = [[[[objc_getClass("SBIconController") sharedInstance] model] applicationIconForBundleIdentifier:bundleIdentifier] getUnmaskedIconImage:2];
		
		if (!defaultAppIcon) {
			return [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/Tiles/default_icon", RESOURCE_PATH]];
		}
		
		return defaultAppIcon;
	}
	
	return tileImage;
}

+ (UIImage*)getImageForTileWithBundleIdentifier:(NSString*)bundleIdentifier size:(int)size colored:(BOOL)colored {
	NSString* iconFileName = @"";
	
	switch (size) {
		case 1:
			iconFileName = @"tile-70x70";
			break;
		case 2:
			iconFileName = @"tile-132x132";
			break;
		case 3:
			iconFileName = @"tile-269x132";
			break;
		case 4:
			iconFileName = @"tile-269x269";
			break;
		case 5:
			iconFileName = @"tile-AppList";
			break;
		case 6:
			iconFileName = @"splash";
			
		default:
			break;
	}
	
	NSString* imagePath = [NSString stringWithFormat:@"%@/Tiles/%@/%@", RESOURCE_PATH, bundleIdentifier, iconFileName];
	UIImage* tileImage = [UIImage imageWithContentsOfFile:imagePath];
	
	if (!tileImage) {
		return [self getImageForTileWithBundleIdentifier:bundleIdentifier];
	}
	
	if (!colored) {
		return [tileImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	}
	
	return tileImage;
}

+ (UIColor*)accentColor {
	return [self colorFromHexString:[[RSPreferences preferences] objectForKey:@"accentColor"]];
}

+ (UIColor*)accentColorForTile:(RSTileInfo*)tileInfo {
	if (tileInfo.tileAccentColor) {
		return [self colorFromHexString:tileInfo.tileAccentColor];
	} else if (tileInfo.accentColor) {
		return [self colorFromHexString:tileInfo.accentColor];
	} else {
		return [[self accentColor] colorWithAlphaComponent:[self tileOpacity]];
	}
}

+ (UIColor*)accentColorForLaunchScreen:(RSTileInfo*)tileInfo {
	if (tileInfo.launchScreenAccentColor) {
		return [self colorFromHexString:tileInfo.launchScreenAccentColor];
	} else if (tileInfo.accentColor) {
		return [self colorFromHexString:tileInfo.accentColor];
	} else {
		return [self accentColor];
	}
}

+ (CGFloat)tileOpacity {
	return [[[RSPreferences preferences] objectForKey:@"tileOpacity"] floatValue];
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

+ (UIColor*)colorFromHexString:(NSString*)arg1 {
	NSString *cleanString = [arg1 stringByReplacingOccurrencesOfString:@"#" withString:@""];
	
	if ([cleanString length] == 3) {
		cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
					   [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
					   [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
					   [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
	}
	
	if ([cleanString length] == 6) {
		cleanString = [cleanString stringByAppendingString:@"ff"];
	}
	
	unsigned int baseValue;
	[[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
	
	float red = ((baseValue >> 24) & 0xFF)/255.0f;
	float green = ((baseValue >> 16) & 0xFF)/255.0f;
	float blue = ((baseValue >> 8) & 0xFF)/255.0f;
	float alpha = ((baseValue >> 0) & 0xFF)/255.0f;
	
	return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (NSString*)localizedStringForKey:(NSString*)key {
	if (!redstoneBundle) {
		redstoneBundle = [NSBundle bundleWithPath:RESOURCE_PATH];
	}
	
	return [redstoneBundle localizedStringForKey:key value:nil table:nil];
}

@end
