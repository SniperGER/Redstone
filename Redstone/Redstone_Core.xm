#import "Redstone.h"
#import "substrate.h"

%group core

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)arg1 {
	%orig(arg1);
	
	redstone = [[RSCore alloc] initWithWindow:[[%c(SBUIController) sharedInstance] window]];
	[redstone setSharedSpringBoard:self];
}

%end // %hook SpringBoard

%end // %group core

%ctor {
	[[RSPreferences alloc] init];
	
	if ([[[RSPreferences preferences] objectForKey:@"enabled"] boolValue]) {
		NSLog(@"[Redstone] Initializing");
		%init(core);
	}
}
