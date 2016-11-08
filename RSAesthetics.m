#import "RSAesthetics.h"
#include <objc/runtime.h>

#define REDSTONE_LIBRARY_PATH @"/private/var/mobile/Library/FESTIVAL/Redstone.bundle"
#define REDSTONE_PREF_PATH @"/var/mobile/Library/Preferences/ml.festival.redstone.plist"
#define DEFAULT_SUITE @"ml.festival.redstone"

extern CFArrayRef CPBitmapCreateImagesFromData(CFDataRef cpbitmap, void*, int, void*);

NSBundle* redstoneBundle;

@implementation RSAesthetics

+(UIColor *)accentColor {
	//NSMutableDictionary* defaults = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/ml.festival.redstone.plist"];
    NSUserDefaults* defaults = [[NSUserDefaults alloc] initWithSuiteName:@"ml.festival.redstone"];

	/* if ([[defaults objectForKey:@"useAutoAccentColor"] boolValue] && [defaults objectForKey:@"autoAccentColor"] && [[defaults objectForKey:@"showWallpaper"] boolValue]) {
		return [self colorFromHexString:[defaults objectForKey:@"autoAccentColor"]];
	} else */ if ([defaults objectForKey:@"accentColor"]) {
		return [self colorFromHexString:[defaults objectForKey:@"accentColor"]];
	} else {
		[defaults setObject:@"0078D7" forKey:@"accentColor"];
		//[defaults writeToFile:@"/var/mobile/Library/Preferences/ml.festival.redstone.plist" atomically:YES];

        return [self colorFromHexString:@"0078D7"];
	}
}

+(UIColor *)accentColorForApp:(NSString *)bundleIdentifier {
    NSDictionary* tileInfo = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Tiles/%@/Tile.plist", REDSTONE_LIBRARY_PATH, bundleIdentifier]];

    if ([tileInfo objectForKey:@"tileAccentColor"]) {
        return [self colorFromHexString:[tileInfo objectForKey:@"tileAccentColor"]];
    } else {
        return [self accentColor];
    }
}

+(UIColor *)accentColorForLaunchScreen:(NSString *)bundleIdentifier {
    NSDictionary* tileInfo = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Tiles/%@/Tile.plist", REDSTONE_LIBRARY_PATH, bundleIdentifier]];
    
    if ([tileInfo objectForKey:@"launchScreenAccentColor"]) {
        return [self colorFromHexString:[tileInfo objectForKey:@"launchScreenAccentColor"]];
    } else {
        return [UIColor colorWithWhite:0.2 alpha:1.0];
    }
}

+(CGFloat)getTileOpacity {
    NSMutableDictionary* defaults = [NSMutableDictionary dictionaryWithContentsOfFile:REDSTONE_PREF_PATH];
    
    if ([defaults objectForKey:@"tileOpacity"]) {
        return [[defaults objectForKey:@"tileOpacity"] floatValue];
    } else {
        [defaults setObject:[NSNumber numberWithFloat:0.6] forKey:@"tileOpacity"];
        [defaults writeToFile:REDSTONE_PREF_PATH atomically:YES];
        return 0.6;
    }
}

+(UIImage*)getCurrentHomeWallpaper {
	//NSMutableDictionary* defaults = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/ml.festival.redstone.plist"];
    NSUserDefaults* defaults = [[NSUserDefaults alloc] initWithSuiteName:@"ml.festival.redstone"];

	// Get current Homescreen wallpaper (if exists)
	NSData *homeWallpaperData = [NSData dataWithContentsOfFile:@"/var/mobile/Library/SpringBoard/HomeBackground.cpbitmap"];

	// Homescreen wallpaper doesn't exist, use Lockscreen data instead
	// If the same wallpaper is used for both Homescreen and Lockscreen, only Lockscreen data is saved
	if (!homeWallpaperData) {
		homeWallpaperData = [NSData dataWithContentsOfFile:@"/var/mobile/Library/SpringBoard/LockBackground.cpbitmap"];;
	}

	if (homeWallpaperData && [[defaults objectForKey:@"showWallpaper"] boolValue]) {
		CFDataRef homeWallpaperDataRef = (__bridge CFDataRef)homeWallpaperData;
		NSArray *imageArray = (__bridge NSArray *)CPBitmapCreateImagesFromData(homeWallpaperDataRef, NULL, 1, NULL);
		UIImage *homeWallpaper = [UIImage imageWithCGImage:(CGImageRef)imageArray[0]];

		//[defaults setObject:[self hexStringFromColor:[[homeWallpaper mainColorsInImage] objectAtIndex:0]] forKey:@"autoAccentColor"];
		//[defaults writeToFile:@"/var/mobile/Library/Preferences/ml.festival.redstone.plist" atomically:YES];

		return homeWallpaper;
	} else {
		return [self imageWithColor:[UIColor blackColor] size:[UIScreen mainScreen].bounds.size];
	}
}

+(id)localizedStringForKey:(NSString*)key {
    if (!redstoneBundle) {
        redstoneBundle = [NSBundle bundleWithPath:REDSTONE_LIBRARY_PATH];
    }

    if ([redstoneBundle localizedStringForKey:key value:@"nil" table:nil] != nil) {
        return [redstoneBundle localizedStringForKey:key value:@"nil" table:nil];
    } else {
        return [[NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/FESTIVAL/Redstone.bundle/en.lproj/Localizable.strings"] objectForKey:key];
    }
    /*NSString *language = [[NSLocale componentsFromLocaleIdentifier:[[NSLocale preferredLanguages] objectAtIndex:0]] objectForKey:@"kCFLocaleLanguageCodeKey"];

    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[NSString stringWithFormat:@"/var/mobile/Library/Redstone/Localization/%@.lproj/Localizable.strings", language]]) {
        return [[NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Redstone/Localization/%@.lproj/Localizable.strings", language]] objectForKey:key];
    } else if ([fileManager fileExistsAtPath:@"/var/mobile/Library/Redstone/Localization/en.lproj/Localizable.strings"]) {
        return [[NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Redstone/Localization/en.lproj/Localizable.strings"] objectForKey:key];
    } else {
        return nil;
    }*/
}

+(UIColor*)colorFromHexString:(NSString*)arg1 {
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


+ (UIImage*) imageWithColor:(UIColor*)color size:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    UIBezierPath* rPath = [UIBezierPath bezierPathWithRect:CGRectMake(0., 0., size.width, size.height)];
    [color setFill];
    [rPath fill];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image; 
}

@end