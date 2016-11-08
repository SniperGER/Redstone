#import "Redstone.h"
#import "RSRootScrollView.h"
#import "RSStartScreenController.h"
#import "RSStartScrollView.h"
#import "RSAppListController.h"
#import "RSLaunchScreenController.h"
#import "RSAesthetics.h"
#import "RSJumpList.h"
#import "UIFont+WDCustomLoader.h"

@implementation Redstone

static Redstone* sharedInstance;
UIImageView* wallpaperView;
id currentApplication;

+(id)sharedInstance {
	return sharedInstance;
}

+(void)hideAllExcept:(id)arg1 {
	if (arg1) {
		[arg1 setHidden:NO];
	}

	for (UIView* view in [[[objc_getClass("SBUIController") sharedInstance] window] subviews]) {
		if ([view isKindOfClass:NSClassFromString(@"SBHostWrapperView")] || [view isKindOfClass:NSClassFromString(@"RSRootScrollView")]) {
			[view setHidden:NO];
		} else if (view == wallpaperView) {
			[view setHidden:NO];
		} else if (view != arg1) {
			[view setHidden:YES];
		}
	}
}

+(void)showAllExcept:(id)arg1 {
	if (arg1) {
		[arg1 setHidden:YES];
	}
	
	for (UIView* view in [[[objc_getClass("SBUIController") sharedInstance] window] subviews]) {
		if ([view isKindOfClass:NSClassFromString(@"SBHostWrapperView")] || [view isKindOfClass:NSClassFromString(@"RSRootScrollView")]) {
			[view setHidden:YES];
		} else if (view == wallpaperView) {
			[view setHidden:YES];
		} else if (view != arg1) {
			[view setHidden:NO];
		}
	}
}

-(id)initWithWindow:(id)arg1 {
	self = [super init];

	if (self) {
		sharedInstance = self;
		[self setWindow:arg1];

		[self loadFonts];

		self.rootScrollView = [[RSRootScrollView alloc] initWithFrame:CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];

		self.startScreenController = [[RSStartScreenController alloc] init];

		self.appListController = [[RSAppListController alloc] init];

		self.launchScreenController = [[RSLaunchScreenController alloc] init];

		wallpaperView = [[UIImageView alloc] initWithImage:[RSAesthetics getCurrentHomeWallpaper]];
		[wallpaperView setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
		[self.window addSubview:wallpaperView];

		[self.window addSubview:_rootScrollView];
		[Redstone hideAllExcept:_rootScrollView];
		//[_startScrollView updateAllTiles];
	}

	return self;
}

-(void)updatePreferences {
	[wallpaperView removeFromSuperview];
	wallpaperView = [[UIImageView alloc] initWithImage:[RSAesthetics getCurrentHomeWallpaper]];
	[wallpaperView setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
	[self.window insertSubview:wallpaperView belowSubview:_rootScrollView];

	// Tell interface elements that preferences have been updated
	[self.rootScrollView updatePreferences];
	[self.startScreenController updatePreferences];
	[self.appListController updatePreferences];
}

-(void)loadFonts {
	[UIFont registerFontFromURL:[NSURL fileURLWithPath:@"/var/mobile/Library/FESTIVAL/Redstone.bundle/Fonts/segoeui.ttf"]];
	[UIFont registerFontFromURL:[NSURL fileURLWithPath:@"/var/mobile/Library/FESTIVAL/Redstone.bundle/Fonts/segoeuil.ttf"]];
	[UIFont registerFontFromURL:[NSURL fileURLWithPath:@"/var/mobile/Library/FESTIVAL/Redstone.bundle/Fonts/segoeuisl.ttf"]];
	[UIFont registerFontFromURL:[NSURL fileURLWithPath:@"/var/mobile/Library/FESTIVAL/Redstone.bundle/Fonts/segmdl2.ttf"]];
}

-(BOOL)hanldeMenuButtonPressed {
	if (currentApplication != nil) {
		//[self.startScreenController returnToHomescreen];
		
		[self.appListController updateTileColors];
		return false;
	}

	if ([self.startScreenController isEditing]) {
		[self.startScreenController setIsEditing:NO];
		[self.startScreenController saveTiles];

		return true;
	}
	
	if ([[RSAppListController sharedInstance] pinMenu]) {
		[[RSAppListController sharedInstance] hidePinMenu];
		return true;
	}
	if (![[RSAppListController sharedInstance] jumpList].hidden) {
		[[RSAppListController sharedInstance] hideJumpList];
		return true;
	}

	if ([self.appListController isSearching]) {
		[self.appListController setIsSearching:NO];

		return true;
	}
	
	if (self.rootScrollView.contentOffset.x != 0 || [self.startScreenController startScrollView].contentOffset.y != -24) {
		if ([[self.startScreenController pinnedLeafIdentifiers] count] > 0) {
			[self.rootScrollView setContentOffset:CGPointMake(0,0) animated:YES];
			[[self.startScreenController startScrollView] setContentOffset:CGPointMake(0,-24) animated:YES];
		}
		
		[[self.appListController appList] setContentOffset:CGPointMake(0,0)];
		
		return true;
	}

	return false;
}

-(void)setCurrentApplication:(id)app {
	currentApplication = app;

	if (app != nil) {
		[self.rootScrollView setHidden:YES];
		[wallpaperView setHidden:YES];

		[self.startScreenController resetTileVisibility];
		[self.appListController resetAppVisibility];
		[self.launchScreenController hide];
		[self.rootScrollView setUserInteractionEnabled:YES];
		
		if ([[self.startScreenController pinnedLeafIdentifiers] count] > 0) {
			[self.rootScrollView setScrollEnabled:YES];
			[self.rootScrollView setContentOffset:CGPointMake(0,0)];
		} else {
			[self.rootScrollView setScrollEnabled:NO];
		}
		[[self.startScreenController startScrollView] setContentOffset:CGPointMake(0,-24)];
		[[self.appListController appList] setContentOffset:CGPointMake(0,0)];
		[self.appListController setIsSearching:NO];
		//[self.appListController updateTileColors];
	} else {
		[self.rootScrollView setHidden:NO];
		[wallpaperView setHidden:NO];

		[self.appListController hidePinMenu];
		[self.appListController hideJumpList];
		[self.appListController setIsSearching:NO];
	}
}

-(UIImageView*)wallpaperView {
	return wallpaperView;
}

@end