#import "../Redstone.h"

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
		[homeScreenWindow setHidden:YES];
		
		[UIFont registerFontFromURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Fonts/segoeui.ttf", RESOURCE_PATH]]];
		[UIFont registerFontFromURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Fonts/segoeuil.ttf", RESOURCE_PATH]]];
		[UIFont registerFontFromURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Fonts/segoeuisl.ttf", RESOURCE_PATH]]];
		[UIFont registerFontFromURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Fonts/seguisb.ttf", RESOURCE_PATH]]];
		[UIFont registerFontFromURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Fonts/segmdl2.ttf", RESOURCE_PATH]]];
		
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

- (void)frontDisplayDidChange:(id)application {
	currentApplication = application;
	SBApplication* frontApp = [(SpringBoard*)[UIApplication sharedApplication] _accessibilityFrontMostApplication];
	
	if (frontApp) {
		[[RSStartScreenController sharedInstance] setTilesVisible:NO];
		[[RSLaunchScreenController sharedInstance] setLaunchIdentifier:[frontApp bundleIdentifier]];
	} else {
		[[RSStartScreenController sharedInstance] setTilesVisible:YES];
	}
}

- (BOOL)handleMenuButtonEvent {
	if  ([currentApplication isKindOfClass:NSClassFromString(@"SBDashBoardViewController")]) {
		return YES;
	}
	if ([RSLaunchScreenController sharedInstance]) {
		if ([[RSLaunchScreenController sharedInstance] isLaunchingApp]) {
			return NO;
		}
	}
	
	if ([RSStartScreenController sharedInstance]) {
		if ([[RSStartScreenController sharedInstance] isEditing]) {
			[[RSStartScreenController sharedInstance] setIsEditing:NO];
			return NO;
		}
		
		if ([[RSHomeScreenController sharedInstance] contentOffset].x != 0 || [(UIScrollView*)[[RSStartScreenController sharedInstance] view] contentOffset].y != -24) {
			[[RSHomeScreenController sharedInstance] setContentOffset:CGPointZero animated:YES];
			[(UIScrollView*)[[RSStartScreenController sharedInstance] view] setContentOffset:CGPointMake(0, -24) animated:YES];
			[(UIScrollView*)[[RSAppListController sharedInstance] view] setContentOffset:CGPointZero animated:YES];
			
			return NO;
		}
	}
	
	return YES;
}

@end
