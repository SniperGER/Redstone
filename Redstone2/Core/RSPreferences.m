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
