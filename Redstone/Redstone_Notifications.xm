#import "Redstone.h"
#import "substrate.h"

%group notifications

// iOS 10
%hook SBNotificationBannerWindow

- (id)initWithFrame:(CGRect)arg1 {
	self = %orig(CGRectZero);
	return self;
}

- (void)setFrame:(CGRect)arg1 {
	%orig(CGRectZero);
}

- (CGRect)frame {
	return CGRectZero;
}

%end // %hook SBNotificationBannerWindow

// iOS 9
%hook SBBannerContainerView

- (id)initWithFrame:(CGRect)arg1 {
	self = %orig(CGRectZero);
	[self setHidden:YES];
	return self;
}

- (void)setFrame:(CGRect)arg1 {
	%orig(CGRectZero);
	[self setHidden:YES];
}

- (CGRect)frame {
	return CGRectZero;
}

- (void)setHidden:(BOOL)arg1 {
	%orig(YES);
}

%end // %hook SBBannerContainerView

%hook BBServer

- (void)_addBulletin:(BBBulletin*)arg1 {
	[[RSNotificationController sharedInstance] addBulletin:arg1];
	%orig;
}

%end // %hook BBServer

%hook SBBulletinBannerController

%new
- (BBObserver*)observer {
	BBObserver* observer = MSHookIvar<BBObserver*>(self, "_observer");
	return observer;
}

%end // %hook SBBulletinBannerController

%end // %group notifications

%ctor {
	NSDictionary* settings = [NSDictionary dictionaryWithContentsOfFile:PREFERENCES_PATH];
	
	if ([[settings objectForKey:@"enabled"] boolValue] && [[settings objectForKey:@"notificationsEnabled"] boolValue]) {
		NSLog(@"[Redstone] Initializing Notifications");
		
		%init(notifications);
	}
}
