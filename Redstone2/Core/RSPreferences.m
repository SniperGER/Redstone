#import "../Redstone.h"

@implementation RSPreferences

static RSPreferences* sharedInstance;

+ (NSDictionary*)preferences {
	return sharedInstance.preferences;
}

- (id)init {
	if (self = [super init]) {
		sharedInstance = self;
		self.preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:PREFERENCES_PATH];
		
		if (!self.preferences) {
			self.preferences = [NSMutableDictionary new];
		}
		
		// Core
		if (![self.preferences objectForKey:kRSPEnabledKey]) {
			[self.preferences setValue:[NSNumber numberWithBool:YES] forKey:kRSPEnabledKey];
		}
		
		// Home Screen
		if (![self.preferences objectForKey:kRSPHomeScreenEnabledKey]) {
			[self.preferences setValue:[NSNumber numberWithBool:YES] forKey:kRSPHomeScreenEnabledKey];
		}
		
		// Lock Screen
		if (![self.preferences objectForKey:kRSPLockScreenEnabledKey]) {
			[self.preferences setValue:[NSNumber numberWithBool:YES] forKey:kRSPLockScreenEnabledKey];
		}
		
		// Notifications
		if (![self.preferences objectForKey:kRSPNotificationsEnabledKey]) {
			[self.preferences setValue:[NSNumber numberWithBool:YES] forKey:kRSPNotificationsEnabledKey];
		}
		
		// Volume Control
		if (![self.preferences objectForKey:kRSPVolumeControlEnabledKey]) {
			[self.preferences setValue:[NSNumber numberWithBool:YES] forKey:kRSPVolumeControlEnabledKey];
		}
		
		// Accent Color
		if (![self.preferences objectForKey:@"accentColor"]) {
			[self.preferences setValue:@"#0078D7" forKey:@"accentColor"];
		}
		
		// Theme Color
		if (![self.preferences objectForKey:@"themeColor"]) {
			[self.preferences setValue:@"dark" forKey:@"themeColor"];
		}
		
		// Tile Opacity
		if (![self.preferences objectForKey:@"tileOpacity"]) {
			[self.preferences setValue:[NSNumber numberWithFloat:0.6] forKey:@"tileOpacity"];
		}
		
		// Show More Tiles
		if (![self.preferences objectForKey:@"showMoreTiles"]) {
			[self.preferences setValue:[NSNumber numberWithBool:(screenWidth >= 414)] forKey:@"showMoreTiles"];
		}
		
		// 2 column tile layout
		if (![self.preferences objectForKey:kRSP2ColumnLayoutKey]) {
			[self.preferences setObject:[NSArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/2ColumnDefaultLayout.plist", RESOURCE_PATH]] forKey:kRSP2ColumnLayoutKey];
		}
		
		// 3 column tile layout
		if (![self.preferences objectForKey:kRSP3ColumnLayoutKey]) {
			[self.preferences setObject:[NSArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/3ColumnDefaultLayout.plist", RESOURCE_PATH]] forKey:kRSP3ColumnLayoutKey];
		}
		
		[self.preferences writeToFile:PREFERENCES_PATH atomically:YES];
	}
	
	return self;
}

- (id)objectForKey:(NSString*)key {
	return [self.preferences objectForKey:key];
}

- (void)setValue:(nonnull id)value forKey:(NSString *)key {
	[self.preferences setValue:value forKey:key];
}

- (void)setObject:(nonnull id)object forKey:(NSString *)key {
	[self.preferences setObject:object forKey:key];
}

@end
