#import "../RedstoneHeaders.h"

@implementation RSPreferences

static NSMutableDictionary* sharedPreferences;

+(NSMutableDictionary*)preferences {
	//sharedPreferences = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/ml.festival.redstone.plist"];
	sharedPreferences = [NSMutableDictionary dictionaryWithContentsOfFile:@"/Users/janikschmidt/Documents/ml.festival.redstone.plist"];
	return sharedPreferences;
}

+ (void)setValue:(id)value forKey:(NSString*)key {
	[sharedPreferences setObject:value forKey:key];
	//[sharedPreferences writeToFile:@"/var/mobile/Library/Preferences/ml.festival.redstone.plist" atomically:YES];
	[sharedPreferences writeToFile:@"/Users/janikschmidt/Documents/ml.festival.redstone.plist" atomically:YES];
}

- (id)init {
	self = [super init];

	if (self) {
		//sharedPreferences = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/ml.festival.redstone.plist"];
		sharedPreferences = [NSMutableDictionary dictionaryWithContentsOfFile:@"/Users/janikschmidt/Documents/ml.festival.redstone.plist"];

		if (![sharedPreferences objectForKey:@"enabled"]) {
			// Set default settings if they're not set
			sharedPreferences = [[NSMutableDictionary alloc] init];
		}

		if (![sharedPreferences objectForKey:@"startScreenEnabled"]) {
			[sharedPreferences setValue:[NSNumber numberWithBool:YES] forKey:@"startScreenEnabled"];
		}

		if (![sharedPreferences objectForKey:@"themeColor"]) {
			[sharedPreferences setValue:@"dark" forKey:@"themeColor"];
		}

		if (![sharedPreferences objectForKey:@"accentColor"]) {
			[sharedPreferences setValue:@"#0078D7" forKey:@"accentColor"];
		}

		if (![sharedPreferences objectForKey:@"showMoreTiles"]) {
			[sharedPreferences setValue:[NSNumber numberWithBool:NO] forKey:@"showMoreTiles"];
		}

		if (![sharedPreferences objectForKey:@"tileOpacity"]) {
			[sharedPreferences setValue:[NSNumber numberWithFloat:0.6] forKey:@"tileOpacity"];
		}

		if (![sharedPreferences objectForKey:@"showWallpaper"]) {
			[sharedPreferences setValue:[NSNumber numberWithBool:NO] forKey:@"showWallpaper"];
		}

		if (![sharedPreferences objectForKey:@"2ColumnLayout"]) {
			//[sharedPreferences setObject:[NSArray arrayWithContentsOfFile:@"/var/mobile/Library/FESTIVAL/Redstone.bundle/2ColumnDefaultLayout.plist"] forKey:@"2ColumnLayout"];
		}

		if (![sharedPreferences objectForKey:@"3ColumnLayout"]) {
			//[sharedPreferences setObject:[NSArray arrayWithContentsOfFile:@"/var/mobile/Library/FESTIVAL/Redstone.bundle/3ColumnDefaultLayout.plist"] forKey:@"3ColumnLayout"];
		}


		[sharedPreferences writeToFile:@"/Users/janikschmidt/Documents/ml.festival.redstone.plist" atomically:YES];
	}

	return self;
}

@end
