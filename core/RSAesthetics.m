#import "../RedstoneHeaders.h"

#define REDSTONE_LIBRARY_PATH @"/private/var/mobile/Library/FESTIVAL/Redstone.bundle"
#define REDSTONE_PREF_PATH @"/var/mobile/Library/Preferences/ml.festival.redstone.plist"
#define DEFAULT_SUITE @"ml.festival.redstone"

extern CFArrayRef CPBitmapCreateImagesFromData(CFDataRef cpbitmap, void*, int, void*);

@implementation RSAesthetics

+ (UIColor*)themeColor {
	if ([[[RSPreferences preferences] objectForKey:@"themeColor"] isEqualToString:@"light"]) {
		return [UIColor whiteColor];
	}

	return [UIColor blackColor];
}

+ (UIColor*)textColor {
	if ([[[RSPreferences preferences] objectForKey:@"themeColor"] isEqualToString:@"light"]) {
		return [UIColor blackColor];
	}

	return [UIColor whiteColor];
}

+ (UIColor *)accentColor {
	if ([[[RSPreferences preferences] objectForKey:@"useAutoAccentColor"] boolValue] && [[[RSPreferences preferences] objectForKey:@"showWallpaper"] boolValue]) {
		NSData *homeWallpaperData = [NSData dataWithContentsOfFile:@"/var/mobile/Library/SpringBoard/HomeBackground.cpbitmap"];
		if (!homeWallpaperData) {
			homeWallpaperData = [NSData dataWithContentsOfFile:@"/var/mobile/Library/SpringBoard/LockBackground.cpbitmap"];;
		}

		if (homeWallpaperData) {
			CFDataRef homeWallpaperDataRef = (__bridge CFDataRef)homeWallpaperData;
			NSArray *imageArray = (__bridge NSArray *)CPBitmapCreateImagesFromData(homeWallpaperDataRef, NULL, 1, NULL);
			UIImage *homeWallpaper = [UIImage imageWithCGImage:(CGImageRef)imageArray[0]];

			return [homeWallpaper dominantColor];
		}
	}

	return [self colorFromHexString:[[RSPreferences preferences] objectForKey:@"accentColor"]];
}

+ (UIColor *)accentColorForApp:(NSString *)bundleIdentifier {
	NSDictionary* tileInfo = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Tiles/%@/Tile.plist", REDSTONE_LIBRARY_PATH, bundleIdentifier]];

	if ([tileInfo objectForKey:@"tileAccentColor"]) {
		return [self colorFromHexString:[tileInfo objectForKey:@"tileAccentColor"]];
	} else {
		return [self accentColor];
	}
}

+ (UIColor *)accentColorForLaunchScreen:(NSString *)bundleIdentifier {
	NSDictionary* tileInfo = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Tiles/%@/Tile.plist", REDSTONE_LIBRARY_PATH, bundleIdentifier]];
	
	if ([tileInfo objectForKey:@"launchScreenAccentColor"]) {
		return [self colorFromHexString:[tileInfo objectForKey:@"launchScreenAccentColor"]];
	} else {
		return [UIColor colorWithWhite:0.2 alpha:1.0];
	}
}

+ (UIImage*)tileImageForApp:(NSString*)bundleIdentifier withSize:(NSInteger)size {
	 NSString* _size = @"";
    int screenScale = (int)[[UIScreen mainScreen] scale];
    NSString* scale = [[UIScreen mainScreen] scale] > 1 ? [NSString stringWithFormat:@"@%dx", screenScale] : @"";

	if ([[[RSPreferences preferences] objectForKey:@"showMoreTiles"] boolValue] || screenW >= 414) {
			switch (size) {
			case 1: _size = @"-small"; break;
			case 2: _size = @"-small"; break;
			case 3: _size = @"-small"; break;
			case 4: _size = @"-medium"; break;
			default: break;
		}
	} else {
		switch (size) {
			case 1: _size = @"-small"; break;
			case 2: _size = @"-medium"; break;
			case 3: _size = @"-medium"; break;
			case 4: _size = @"-large"; break;
			default: break;
		}
	}

	NSURL* tileImageDataURL = [NSURL URLWithString:[[NSString stringWithFormat:@"file://%@/Tiles/%@/tile%@%@.png", REDSTONE_LIBRARY_PATH, bundleIdentifier, _size, scale] stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet]];
	return [UIImage imageWithData:[NSData dataWithContentsOfURL:tileImageDataURL]];
}

+ (CGFloat)tileOpacity {
	if (![[[RSPreferences preferences] objectForKey:@"showWallpaper"] boolValue]) {
		return 1.0;
	}

	return [[[RSPreferences preferences] objectForKey:@"tileOpacity"] floatValue];
}

+ (CGFloat)tileOpacityForApp:(NSString*)bundleIdentifier {
	NSDictionary* tileInfo = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Tiles/%@/Tile.plist", REDSTONE_LIBRARY_PATH, bundleIdentifier]];

	if ([tileInfo objectForKey:@"tileAccentColor"]) {
		return 1.0;
	}

	return [self tileOpacity];
}

+ (UIImage*)getCurrentHomeWallpaper {
	if (![[[RSPreferences preferences] objectForKey:@"showWallpaper"] boolValue]) {
		return [self imageWithColor:[self themeColor] size:[UIScreen mainScreen].bounds.size];
	}

	return nil;
}

+ (id)localizedStringForKey:(NSString*)key {
	return nil;
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

+(NSString *)hexStringFromColor:(UIColor *)color {
	const CGFloat *components = CGColorGetComponents(color.CGColor);

	CGFloat r = components[0];
	CGFloat g = components[1];
	CGFloat b = components[2];

	return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
			lroundf(r * 255),
			lroundf(g * 255),
			lroundf(b * 255)];
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