#import "RSTileDelegate.h"
#define REDSTONE_LIBRARY_PATH @"/private/var/mobile/Library/Redstone"
#define REDSTONE_PREF_PATH @"/var/mobile/Library/Preferences/ml.festival.redstone.plist"

@interface SBApplication : NSObject
-(id)displayName;
@end

@interface SBApplicationController : NSObject
+(id) sharedInstance;
-(SBApplication*) applicationWithBundleIdentifier:(NSString*)identifier;
@end

@implementation RSTileDelegate

+(NSDictionary*)getTileInfo:(NSString*)bundleIdentifier {
	NSDictionary* returnDict = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Tiles/%@/Tile.plist", REDSTONE_LIBRARY_PATH, bundleIdentifier]];
		
	if (returnDict == nil) {
		returnDict = @{
						 @"tileDisplayName": @"",
						 @"isFullsizeTile": @NO,
						 @"bundleIdentifier": bundleIdentifier,
						 @"availableTileSizes": @[@1, @2, @3],
					  };
	} else {
		[returnDict setObject:bundleIdentifier forKey:@"bundleIdentifier"];
	}
		
	return returnDict;
}
+(NSString*)getTileDisplayName:(NSString*)bundleIdentifier {
	SBApplication* application = [[objc_getClass("SBApplicationController") sharedInstance] applicationWithBundleIdentifier:bundleIdentifier];
	return [application displayName];
}

+(NSArray*)getTileList {
	NSMutableDictionary* defaults = [NSMutableDictionary dictionaryWithContentsOfFile:REDSTONE_PREF_PATH];

	 /*if ([defaults objectForKey:@"currentLayout"]) {
        return [defaults arrayForKey:@"currentLayout"];
    } else {*/
        NSMutableArray* returnArray = [NSMutableArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", REDSTONE_LIBRARY_PATH, @"3ColumnDefaultLayout.plist"]];
        //[defaults setObject:returnArray forKey:@"currentLayout"];
        
        return returnArray;
    //}
}

@end