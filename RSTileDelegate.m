//
//  RSTileDelegate.m
//  
//
//  Created by Janik Schmidt on 05.08.16.
//
//

#import "RSTileDelegate.h"
#define REDSTONE_LIBRARY_PATH @"/var/mobile/Library/Redstone/"

@implementation RSTileDelegate

+(NSArray*)getTileList {
    NSUserDefaults* defaults = [[NSUserDefaults alloc] initWithSuiteName:@"ml.festival.redstone"];
    
    /*if ([defaults objectForKey:@"currentLayout"]) {
        return [defaults arrayForKey:@"currentLayout"];
    } else {*/
        NSMutableArray* returnArray = [NSMutableArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@%@", REDSTONE_LIBRARY_PATH, @"3ColumnDefaultLayout.plist"]];
        [defaults setObject:returnArray forKey:@"currentLayout"];
        
        return returnArray;
    //}
}

+(NSDictionary*)getTileInformation:(NSString*)bundleIdentifier {
    return nil;
}
+(NSString*)getGlobalTileAccentColor {
    NSUserDefaults* defaults = [[NSUserDefaults alloc] initWithSuiteName:@"ml.festival.redstone"];
    
    if ([defaults objectForKey:@"accentColor"]) {
        return [defaults objectForKey:@"accentColor"];
    } else {
        [defaults setObject:@"0078D7" forKey:@"accentColor"];
        return @"0078D7";
    }
}
+(NSString*)getIndividualTileAccentColor:(NSString*)bundleIdentifier {
    return @"";
}

+(BOOL)isTileHidden:(NSString*)bundleIdentifier {
    return NO;
}

@end
