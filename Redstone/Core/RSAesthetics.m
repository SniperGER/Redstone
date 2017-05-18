#import "../Redstone.h"

extern CFArrayRef CPBitmapCreateImagesFromData(CFDataRef cpbitmap, void*, int, void*);
NSBundle* redstoneBundle;

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

+ (UIColor*)accentColor {
	return [UIColor colorWithRed:0.0 green:0.47 blue:0.843 alpha:1.0];
}

+ (UIColor*)accentColorForTile:(NSString *)bundleIdentifier {
	NSDictionary* tileInfo = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Tiles/%@/tile.plist", RESOURCE_PATH, bundleIdentifier]];
	
	if ([tileInfo objectForKey:@"AccentColor"]) {
		return [self colorFromHexString:[tileInfo objectForKey:@"AccentColor"]];
	} else {
		return [self accentColor];
	}
}

+ (UIColor*)accentColorForLaunchScreen:(NSString*)bundleIdentifier {
	NSDictionary* tileInfo = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Tiles/%@/tile.plist", RESOURCE_PATH, bundleIdentifier]];
	
	if ([tileInfo objectForKey:@"LaunchScreenAccentColor"]) {
		return [self colorFromHexString:[tileInfo objectForKey:@"LaunchScreenAccentColor"]];
	} else {
		return [self accentColorForTile:bundleIdentifier];
	}
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
