/**
 @class Redstone2_Core
 @author Sniper_GER
 @discussion Tweak part of Redstone's Core
 */

#import "Redstone.h"
#import "substrate.h"
#import <objcipc/objcipc.h>

%group core

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)arg1 {
	%orig;
	
	redstone = [[RSCore alloc] initWithWindow:[[%c(SBUIController) sharedInstance] window]];
}

%end // %hook SpringBoard

%hook SBHomeHardwareButton

// iOS 10
- (void)singlePressUp:(id)arg1 {
	if ([[RSCore sharedInstance] handleMenuButtonEvent]) {
		%orig;
	}
}

%end // %hook SBHomeHardwareButton

static void lockedDevice(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RedstoneDeviceHasFinishedLock" object:nil];
}

%end // %group core

%ctor {
	id preferences = [[RSPreferences alloc] init];
	
	if ([[preferences objectForKey:kRSPEnabledKey] boolValue]) {
		NSLog(@"[Redstone | Core] Initializing Core");
		
		%init(core);
		
		// Device has been locked
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, lockedDevice, CFSTR("com.apple.springboard.lockcomplete"), NULL, CFNotificationSuspensionBehaviorCoalesce);
		
#if (!TARGET_OS_SIMULATOR)
		[OBJCIPC registerIncomingMessageFromAppHandlerForMessageName:@"Redstone.Application.BecameActive"  handler:^NSDictionary *(NSDictionary *message) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"RedstoneApplicationDidBecomeActive" object:nil];
			
			return nil;
		}];
#endif
	}
}
