#import "../Redstone.h"

@implementation RSCore

- (id)initWithWindow:(UIWindow*)window {
	if (self = [super init]) {
		homeScreenWindow = window;
		[homeScreenWindow setHidden:YES];
		
		if ([[[RSPreferences preferences] objectForKey:kRSPHomeScreenEnabledKey] boolValue]) {
			homeScreenController = [RSHomeScreenController new];
		}
		
		if ([[[RSPreferences preferences] objectForKey:kRSPLockScreenEnabledKey] boolValue]) {
			//lockScreenController = [RSLockScreenController new];
		}
		
		if ([[[RSPreferences preferences] objectForKey:kRSPNotificationsEnabledKey] boolValue]) {
			//notificationController = [RSNotificationController new];
		}
		
		if ([[[RSPreferences preferences] objectForKey:kRSPVolumeControlEnabledKey] boolValue]) {
			//volumeController = [RSVolumeController new];
		}
	}
	
	return self;
}

@end
