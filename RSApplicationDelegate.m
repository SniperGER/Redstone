#import "RSApplicationDelegate.h"

@implementation RSApplicationDelegate

+(NSArray*)listVisibleIcons {
	SBIconModel* iconModel = [[objc_getClass("SBIconController") sharedInstance] model];

	NSMutableArray* allApps = [[iconModel visibleIconIdentifiers] mutableCopy];
	[allApps sortUsingComparator: ^(NSString* a, NSString* b) {
	    //NSString *a_ = [[objc_getClass("SBApplicationController") sharedInstance] applicationWithBundleIdentifier:a].displayName;
	    //NSString *b_ = [[objc_getClass("SBApplicationController") sharedInstance] applicationWithBundleIdentifier:b].displayName;
		SBApplicationInfo* a_info = [[[iconModel leafIconForIdentifier:a] application] _appInfo];
		SBApplicationInfo* b_info = [[[iconModel leafIconForIdentifier:b] application] _appInfo];

		NSString* a_ = a_info.displayName;
		NSString* b_ = b_info.displayName;

	    return [a_ caseInsensitiveCompare:b_];
	}];

	

	return allApps;
}

@end