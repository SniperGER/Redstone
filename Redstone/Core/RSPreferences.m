#import "../Redstone.h"

@implementation RSPreferences

static RSPreferences* sharedInstance;

+ (NSMutableDictionary*)preferences {
	return sharedInstance.preferences;
}

+ (void)setValue:(id)value forKey:(NSString*)key {
	[sharedInstance.preferences setObject:value forKey:key];
	[sharedInstance.preferences writeToFile:PREFERENCES_PATH atomically:YES];
}

- (id)init {
	self = [super init];
	
	if (self) {
		sharedInstance = self;
		
		self.preferences = [NSMutableDictionary dictionaryWithContentsOfFile:PREFERENCES_PATH];
		
		if (![self.preferences objectForKey:@"enabled"]) {
			self.preferences = [[NSMutableDictionary alloc] init];
			[self.preferences setValue:[NSNumber numberWithBool:YES] forKey:@"enabled"];
		}
		
		if (![self.preferences objectForKey:@"startScreenEnabled"]) {
			[self.preferences setValue:[NSNumber numberWithBool:YES] forKey:@"startScreenEnabled"];
		}
		
		if (![self.preferences objectForKey:@"lockScreenEnabled"]) {
			[self.preferences setValue:[NSNumber numberWithBool:NO] forKey:@"lockScreenEnabled"];
		}
		
		if (![self.preferences objectForKey:@"accentColor"]) {
			[self.preferences setValue:@"#0078D7" forKey:@"accentColor"];
		}
		
		if (![self.preferences objectForKey:@"tileOpacity"]) {
			[self.preferences setValue:[NSNumber numberWithFloat:0.8] forKey:@"tileOpacity"];
		}
		
		/*if (![sharedPreferences objectForKey:@"themeColor"]) {
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
			[sharedPreferences setObject:[NSArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/2ColumnDefaultLayout.plist", RESOURCE_PATH]] forKey:@"2ColumnLayout"];
		} */
		
		if (![self.preferences objectForKey:@"3ColumnLayout"]) {
			[self.preferences setObject:[NSArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/3ColumnDefaultLayout.plist", RESOURCE_PATH]] forKey:@"3ColumnLayout"];
		}
		
		[self.preferences writeToFile:PREFERENCES_PATH atomically:YES];
	}
	
	return self;
}

@end
