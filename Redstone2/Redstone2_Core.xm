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

%end // %group core

%ctor {
	id preferences = [[RSPreferences alloc] init];
	
	if ([[preferences objectForKey:kRSPEnabledKey] boolValue]) {
		NSLog(@"[Redstone | Core] Initializing Core");
		
		%init(core);
		
#if (!TARGET_OS_SIMULATOR)
		[OBJCIPC registerIncomingMessageFromAppHandlerForMessageName:@"Redstone.Application.BecameActive"  handler:^NSDictionary *(NSDictionary *message) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"RedstoneApplicationDidBecomeActive" object:nil];
			
			return nil;
		}];
#endif
	}
}
