#import "../Redstone.h"
#import <dlfcn.h>

@implementation RSCore

static RSCore* sharedInstance;
static id currentApplication;

+ (id)sharedInstance {
	return sharedInstance;
}

- (id)initWithWindow:(UIWindow*)window {
	if (self = [super init]) {
		sharedInstance = self;
		
		homeScreenWindow = window;
		
		[UIFont registerFontFromURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Fonts/segoeui.ttf", RESOURCE_PATH]]];
		[UIFont registerFontFromURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Fonts/segoeuil.ttf", RESOURCE_PATH]]];
		[UIFont registerFontFromURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Fonts/segoeuisl.ttf", RESOURCE_PATH]]];
		[UIFont registerFontFromURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Fonts/seguisb.ttf", RESOURCE_PATH]]];
		[UIFont registerFontFromURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Fonts/segmdl2.ttf", RESOURCE_PATH]]];
		
		if ([[[RSPreferences preferences] objectForKey:kRSPHomeScreenEnabledKey] boolValue]) {
			[homeScreenWindow setHidden:YES];
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

- (void)frontDisplayDidChange:(id)application {
	if (homeScreenController == nil) {
		return;
	}
	
	currentApplication = application;
	SBApplication* frontApp = [(SpringBoard*)[UIApplication sharedApplication] _accessibilityFrontMostApplication];
	
	if (frontApp) {
		[[homeScreenController startScreenController] setTilesVisible:NO];
		[[homeScreenController startScreenController] setIsEditing:NO];
		[[homeScreenController launchScreenController] setLaunchIdentifier:[frontApp bundleIdentifier]];
	} else {
		[[homeScreenController startScreenController] setTilesVisible:YES];
	}
}

- (BOOL)handleMenuButtonEvent {
	SBApplication* frontApp = [(SpringBoard*)[UIApplication sharedApplication] _accessibilityFrontMostApplication];
	
	if (homeScreenController != nil) {
		if  ([currentApplication isKindOfClass:NSClassFromString(@"SBDashBoardViewController")] || frontApp != nil) {
			[[homeScreenController launchScreenController] setLaunchIdentifier:[frontApp bundleIdentifier]];
			return YES;
		}
		
		if ([homeScreenController launchScreenController]) {
			if ([[homeScreenController launchScreenController] isLaunchingApp]) {
				return NO;
			}
		}
		
		if ([[homeScreenController appListController] isUninstallingApp]) {
			return NO;
		}
		
		if ([[[homeScreenController appListController] jumpList] isOpen]) {
			[[homeScreenController appListController] hideJumpList];
			return NO;
		}
		
		if ([[[homeScreenController appListController] pinMenu] isOpen]) {
			[[homeScreenController appListController] hidePinMenu];
			return NO;
		}
		
		if ([[[homeScreenController appListController] searchBar] text].length > 0) {
			[[[homeScreenController appListController] searchBar] resignFirstResponder];
			[[[homeScreenController appListController] searchBar] setText:@""];
			[[homeScreenController appListController] showAppsFittingQuery];
		}
		
		if ([[[homeScreenController appListController] searchBar] isFirstResponder]) {
			[[[homeScreenController appListController] searchBar] resignFirstResponder];
			return NO;
		}
		
		if ([[homeScreenController startScreenController] isEditing]) {
			[[homeScreenController startScreenController] setIsEditing:NO];
			return NO;
		}
		
		if (([[RSHomeScreenController sharedInstance] contentOffset].x != 0
			|| [[homeScreenController startScreenController] contentOffset].y != -24
			|| [[homeScreenController appListController] contentOffset].y != 0)
			&& [[homeScreenController startScreenController] pinnedTiles].count > 0) {
			[[RSHomeScreenController sharedInstance] setContentOffset:CGPointZero animated:YES];
			[[homeScreenController startScreenController] setContentOffset:CGPointMake(0, -24) animated:YES];
			[[homeScreenController appListController] setContentOffset:CGPointZero animated:YES];
			
			return NO;
		}
	}
	
	return YES;
}

@end
