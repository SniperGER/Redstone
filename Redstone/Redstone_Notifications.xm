#import "Redstone.h"
#import "substrate.h"

%group ios10

%hook NCNotificationShortLookView

// iOS 10
- (void)setFrame:(CGRect)frame {
	%log;
	%orig(frame);
}

%end // %hook NCNotificationShortLookView

%end // %group ios10

%group ios9

%hook SBLockScreenBulletinCell

// iOS 9
- (id)initWithStyle:(long long)arg1 reuseIdentifier:(id)arg2 {
	id r = %orig(arg1, arg2);
	%log;
	return r;
}

%end // %hook SBLockScreenBulletinCell

%hook SBBannerContextView

// iOS 9
- (id)initWithFrame:(CGRect)frame {
	self = %orig(frame);
	%log;
	return self;
}

%end // %hook SBBannerContextView

%end // %group ios9

%ctor {
	NSDictionary* settings = [NSDictionary dictionaryWithContentsOfFile:PREFERENCES_PATH];
	
	if ([[settings objectForKey:@"enabled"] boolValue] && [[settings objectForKey:@"notificationsEnabled"] boolValue]) {
		NSLog(@"[Redstone] Initializing Notifications");
		
		if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_9_x_Max) {
			%init(ios10)
		} else if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_8_x_Max) {
			%init(ios9);
		}
	}
}
