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
		//UIImage* baseImage = [self imageWithColor:[UIColor blackColor] size:[UIScreen mainScreen].bounds.size];
		return nil;
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

+ (CGFloat)tileOpacity {
	return [[[RSPreferences preferences] objectForKey:@"tileOpacity"] floatValue];
}

+ (NSDictionary*)colorsForCurrentTheme {
	NSString* themeName = [[RSPreferences preferences] objectForKey:@"themeColor"];
	if ([themeName isEqualToString:@"dark"]) {
		return @{
				 @"ForegroundColor": [UIColor whiteColor],
				 @"BackgroundColor": [UIColor colorWithWhite:0.22 alpha:1.0],
				 @"InvertedForegroundColor": [UIColor blackColor],
				 @"InvertedBackgroundColor": [UIColor whiteColor],
				 @"OpaqueBackgroundColor": [UIColor colorWithWhite:0.0 alpha:0.75],
				 @"BorderColor": [UIColor colorWithWhite:0.46 alpha:1.0]
				 };
	} else if ([themeName isEqualToString:@"light"]) {
		return @{
				 @"ForegroundColor": [UIColor blackColor],
				 @"BackgroundColor": [UIColor colorWithWhite:0.95 alpha:1.0],
				 @"InvertedForegroundColor": [UIColor whiteColor],
				 @"InvertedBackgroundColor": [UIColor colorWithWhite:0.22 alpha:1.0],
				 @"OpaqueBackgroundColor": [UIColor colorWithWhite:1.0 alpha:0.75],
				 @"BorderColor": [UIColor colorWithWhite:0.80 alpha:1.0]
				 };
	}
	
	return nil;
}

+ (UIImage*)getImageForTileWithBundleIdentifier:(NSString*)bundleIdentifier {
	NSString* imagePath = [NSString stringWithFormat:@"%@/Tiles/%@/tile", RESOURCE_PATH, bundleIdentifier];
	UIImage* tileImage = [[UIImage imageWithContentsOfFile:imagePath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	
	if (!tileImage) {
		UIImage* defaultAppIcon = [[[(SBIconController*)[objc_getClass("SBIconController") sharedInstance] model] leafIconForIdentifier:bundleIdentifier] getUnmaskedIconImage:2];
		
		if (!defaultAppIcon) {
			return [[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/Tiles/default_icon", RESOURCE_PATH]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
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
		if (colored) {
			return [[self getImageForTileWithBundleIdentifier:bundleIdentifier] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
		} else {
			return [self getImageForTileWithBundleIdentifier:bundleIdentifier];
		}
	}
	
	if (!colored) {
		return [tileImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	}
	
	return tileImage;
}

+ (UIColor *)readableForegroundColorForBackgroundColor:(UIColor*)backgroundColor {
	size_t count = CGColorGetNumberOfComponents(backgroundColor.CGColor);
	const CGFloat *componentColors = CGColorGetComponents(backgroundColor.CGColor);
	
	CGFloat darknessScore = 0;
	if (count == 2) {
		darknessScore = (((componentColors[0]*255) * 299) + ((componentColors[0]*255) * 587) + ((componentColors[0]*255) * 114)) / 1000;
	} else if (count == 4) {
		darknessScore = (((componentColors[0]*255) * 299) + ((componentColors[1]*255) * 587) + ((componentColors[2]*255) * 114)) / 1000;
	}
	
	if (darknessScore >= 180) {
		return [UIColor blackColor];
	}
	
	return [UIColor whiteColor];
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

@end
