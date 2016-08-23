//
//  RSTileDelegate.m
//  
//
//  Created by Janik Schmidt on 06.08.16.
//
//

#import "RSTileDelegate.h"
#define REDSTONE_LIBRARY_PATH @"/private/var/mobile/Library/Redstone"
#define DEFAULT_SUITE @"ml.festival.redstone"

@implementation RSTileDelegate

+(NSArray*)getTileList {
    NSUserDefaults* defaults = [[NSUserDefaults alloc] initWithSuiteName:DEFAULT_SUITE];
    
    /*if ([defaults objectForKey:@"currentLayout"]) {
        return [defaults arrayForKey:@"currentLayout"];
    } else {*/
        NSMutableArray* returnArray = [NSMutableArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", REDSTONE_LIBRARY_PATH, @"3ColumnDefaultLayout.plist"]];
        [defaults setObject:returnArray forKey:@"currentLayout"];
        
        return returnArray;
    //}
}

+(NSDictionary*)getTileInfo:(NSString*)bundleIdentifier {
    NSDictionary* returnDict = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Tiles/%@/Tile.plist", REDSTONE_LIBRARY_PATH, bundleIdentifier]];
    
    if (returnDict == nil) {
        returnDict = @{
                       @"isSystemApp": @NO,
                       @"usesGlobalAccentColor": @YES,
                       @"bundleIdentifier": bundleIdentifier,
                       @"availableTileSizes": @[@1, @2, @3],
                       @"isLiveTile": @NO
                       };
    }
    
    return returnDict;
}
+(NSString*)getTileDisplayName:(NSString*)bundleIdentifier {
    Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
    NSObject* workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
    for (LSApplicationProxy* apps in [workspace performSelector:@selector(allApplications)]) {
        if ([apps.applicationIdentifier isEqualToString:bundleIdentifier]) {
            return apps.localizedName;
        }
    }
    
    return nil;
}

+(UIColor*)getGlobalAccentColor {
    NSUserDefaults* defaults = [[NSUserDefaults alloc] initWithSuiteName:DEFAULT_SUITE];
    
    if ([defaults objectForKey:@"accentColor"]) {
        return [self colorFromHexString:[defaults objectForKey:@"accentColor"]];
    } else {
        [defaults setObject:@"0078D7" forKey:@"accentColor"];
        return [self colorFromHexString:@"0078D7"];
    }
}
+(UIColor*)getIndividualTileColor:(NSString*)bundleIdentifier {
    NSDictionary* tileInfo = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Tiles/%@/Tile.plist", REDSTONE_LIBRARY_PATH, bundleIdentifier]];
    
    if ([tileInfo objectForKey:@"customAccentColor"]) {
        return [self colorFromHexString:[tileInfo objectForKey:@"customAccentColor"]];
    } else {
        return [self getGlobalAccentColor];
    }
}
+(UIColor*)getTileLaunchImageColor:(NSString*)bundleIdentifier {
    NSDictionary* tileInfo = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Tiles/%@/Tile.plist", REDSTONE_LIBRARY_PATH, bundleIdentifier]];
    if ([tileInfo objectForKey:@"customAccentColor"]) {
        return [self colorFromHexString:[tileInfo objectForKey:@"customAccentColor"]];
    } else {
        return [UIColor blackColor];
    }
}

+(BOOL)isAppHidden:(NSString*)bundleIdentifier {
    NSDictionary* tileInfo = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Tiles/%@/Tile.plist", REDSTONE_LIBRARY_PATH, bundleIdentifier]];
    
    BOOL appHiddenBySystem = NO;
    BOOL appHiddenByPlist = NO;
    
    NSArray *_apps = [[objc_getClass("LSApplicationWorkspace") defaultWorkspace] allInstalledApplications];
    for (LSApplicationProxy *app in _apps) {
        NSString *appBundleIdentifier = app.bundleIdentifier;
        
        if ([appBundleIdentifier isEqualToString:bundleIdentifier]) {
            NSString *bundlePath = app.bundleURL.path;
            NSBundle* appBundle = [NSBundle bundleWithPath:bundlePath];
            NSArray* appTags = [[appBundle infoDictionary] objectForKey:@"SBAppTags"];
            
            if (appTags != nil && (int)[appTags indexOfObject:@"hidden"] != -1) {
                appHiddenBySystem = YES;
            }
            break;
        }
    }
    
    if ([tileInfo objectForKey:@"hidden"]) {
        appHiddenByPlist = [[tileInfo objectForKey:@"hidden"] boolValue];
    }
    
    if (appHiddenByPlist || appHiddenBySystem) {
        return YES;
    }
    
    return NO;
}

+(CGFloat)getTileOpacity {
    NSUserDefaults* defaults = [[NSUserDefaults alloc] initWithSuiteName:DEFAULT_SUITE];
    
    if ([defaults objectForKey:@"tileOpacity"]) {
        return [[defaults objectForKey:@"tileOpacity"] floatValue];
    } else {
        [defaults setObject:[NSNumber numberWithFloat:0.6] forKey:@"tileOpacity"];
        return 0.6;
    }
}

+(UIImage*)getTileImage:(NSString*)bundleIdentifier withSize:(NSString*)size {
    NSURL* tileImageDataURL = [NSURL URLWithString:[[NSString stringWithFormat:@"file://%@/Tiles/%@/icon-%@.png", REDSTONE_LIBRARY_PATH, bundleIdentifier, size] stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet]];
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:tileImageDataURL]];
}

+(UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    //[scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
