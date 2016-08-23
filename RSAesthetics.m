#import "RSAesthetics.h"
#define REDSTONE_LIBRARY_PATH @"/private/var/mobile/Library/Redstone"
#define REDSTONE_PREF_PATH @"/var/mobile/Library/Preferences/ml.festival.redstone.plist"
#define DEFAULT_SUITE @"ml.festival.redstone"

extern CFArrayRef CPBitmapCreateImagesFromData(CFDataRef cpbitmap, void*, int, void*);

@implementation RSAesthetics

+(UIColor *)accentColor {
	//NSUserDefaults* defaults = [[NSUserDefaults alloc] initWithSuiteName:DEFAULT_SUITE];
    NSMutableDictionary* defaults = [NSMutableDictionary dictionaryWithContentsOfFile:REDSTONE_PREF_PATH];
    
    if ([defaults objectForKey:@"accentColor"]) {
        if ([[defaults objectForKey:@"accentColor"] isEqualToString:@"auto"]) {
            return [self colorFromHexString:[defaults objectForKey:@"autoAccentColor"]];
        }
    
        return [self colorFromHexString:[defaults objectForKey:@"accentColor"]];
    } else {
        [defaults setObject:@"0078D7" forKey:@"accentColor"];
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

+(UIImage*)getTileImage:(NSString*)bundleIdentifier withSize:(NSInteger)size {
    NSString* _size = @"";
    int screenScale = (int)[[UIScreen mainScreen] scale];
    NSString* scale = [[UIScreen mainScreen] scale] > 1 ? [NSString stringWithFormat:@"@%dx", screenScale] : @"";

    switch (size) {
        case 0: _size = @"-AppList"; break;
        case 1: _size = @"-Small"; break;
        case 2: _size = @"-Medium"; break;
        case 3: _size = @"-Wide"; break;
        case 10: _size = @"-LaunchScreen"; break;
        default: break;
    }

    NSURL* tileImageDataURL = [NSURL URLWithString:[[NSString stringWithFormat:@"file://%@/Tiles/%@/icon%@%@.png", REDSTONE_LIBRARY_PATH, bundleIdentifier, _size, scale] stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet]];
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:tileImageDataURL]];
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

@end