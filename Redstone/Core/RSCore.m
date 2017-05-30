#import "../Redstone.h"

@implementation RSCore

static RSCore* sharedInstance;
static UIImageView* wallpaperView;
static id currentApplication;

+ (id)sharedInstance {
	return sharedInstance;
}

+ (void)hideAllExcept:(id)objectToShow {
	if (objectToShow) {
		[objectToShow setHidden:NO];
	}
	
	for (UIView* view in [[[objc_getClass("SBUIController") sharedInstance] window] subviews]) {
		if ([view isKindOfClass:[RSRootScrollView class]] || view == wallpaperView) {
			[view setHidden:NO];
		} else if (view != objectToShow) {
			[view setHidden:YES];
		}
	}
}

+ (void)showAllExcept:(id)objectToHide {
	if (objectToHide) {
		[objectToHide setHidden:YES];
	}
	
	for (UIView* view in [[[objc_getClass("SBUIController") sharedInstance] window] subviews]) {
		if ([view isKindOfClass:[RSRootScrollView class]] || [view isKindOfClass:[RSLaunchScreen class]] || view == wallpaperView) {
			[view setHidden:YES];
		} else if (view != objectToHide) {
			[view setHidden:NO];
		}
	}
}



- (id)initWithWindow:(id)window {
	self = [super init];
	
	if (self) {
		sharedInstance = self;
		self.window = window;
		
		[UIFont registerFontFromURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Fonts/segoeui.ttf", RESOURCE_PATH]]];
		[UIFont registerFontFromURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Fonts/segoeuil.ttf", RESOURCE_PATH]]];
		[UIFont registerFontFromURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Fonts/segoeuisl.ttf", RESOURCE_PATH]]];
		[UIFont registerFontFromURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Fonts/seguisb.ttf", RESOURCE_PATH]]];
		[UIFont registerFontFromURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Fonts/segmdl2.ttf", RESOURCE_PATH]]];
		
		if ([[[RSPreferences preferences] objectForKey:@"startScreenEnabled"] boolValue]) {
			[[self class] hideAllExcept:nil];
			
			wallpaperView = [[UIImageView alloc] initWithImage:[RSAesthetics homeScreenWallpaper]];
			[wallpaperView setFrame:[[UIScreen mainScreen] bounds]];
			[self.window addSubview:wallpaperView];
			
			self.rootScrollView = [[RSRootScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
			[self.window addSubview:self.rootScrollView];
			
			self.startScreenController = [RSStartScreenController new];
			[self.rootScrollView addSubview:self.startScreenController.startScrollView];
			if ([[self.startScreenController pinnedTiles] count] <= 0) {
				[self.rootScrollView setContentOffset:CGPointMake(screenWidth, 0)];
				[self.rootScrollView setScrollEnabled:NO];
			}
			
			self.launchScreenController = [RSLaunchScreenController new];
			[self.window addSubview:self.launchScreenController.launchScreen];
			
			self.appListController = [RSAppListController new];
			[self.rootScrollView addSubview:self.appListController.appList];
			[self.rootScrollView addSubview:self.appListController.jumpList];
		}
		
		if ([[[RSPreferences preferences] objectForKey:@"lockScreenEnabled"] boolValue]) {
			self.lockScreenController = [RSLockScreenController new];
		}
	}
	
	return self;
}

- (void)frontDisplayDidChange:(id)arg1 {
	if (![[[RSPreferences preferences] objectForKey:@"startScreenEnabled"] boolValue]) {
		return;
	}
	currentApplication = arg1;
	
	if (arg1) {
		[self.startScreenController resetTileVisibility];
		[self.launchScreenController hide];
		[[self.startScreenController startScrollView] setContentOffset:CGPointMake(0, -24)];
		[self.appListController.appList setContentOffset:CGPointMake(0, 0)];
		[self.appListController hidePinMenu];
		[self.appListController hideJumpList];
		[self.appListController setIsSearching:NO];
		
		if ([[self.startScreenController pinnedTiles] count] > 0) {
			[self.rootScrollView setScrollEnabled:YES];
			[self.rootScrollView setContentOffset:CGPointMake(0, 0)];
		} else {
			[self.rootScrollView setScrollEnabled:NO];
			[self.rootScrollView setContentOffset:CGPointMake(screenWidth, 0)];
		}
	} else {
		[self.rootScrollView setHidden:NO];
		[wallpaperView setHidden:NO];
	}
}

- (BOOL)handleMenuButtonEvent {
	if (![[[RSPreferences preferences] objectForKey:@"startScreenEnabled"] boolValue]) {
		return NO;
	}
	
	if  ([currentApplication isKindOfClass:NSClassFromString(@"SBDashBoardViewController")]) {
		if ([[[RSPreferences preferences] objectForKey:@"lockScreenEnabled"] boolValue]) {
			return NO;
		} else {
			[self.startScreenController setIsEditing:NO];
			[self.startScreenController saveTiles];
			[self.appListController hidePinMenu];
			[self.appListController hideJumpList];
			[self.appListController setIsSearching:NO];
			
			if ([[self.startScreenController pinnedTiles] count] > 0) {
				[self.rootScrollView setContentOffset:CGPointMake(0, 0)];
				[self.startScreenController.startScrollView setContentOffset:CGPointMake(0, -24)];
				[self.appListController.appList setContentOffset:CGPointMake(0, 0)];
			} else {
				[self.rootScrollView setContentOffset:CGPointMake(screenWidth, 0)];
			}
			
			return NO;
		}
	}
	
	if (currentApplication == nil) {
		if ([self.startScreenController isEditing]) {
			[self.startScreenController setIsEditing:NO];
			
			return YES;
		}
		
		if (self.appListController.showsPinMenu) {
			[self.appListController hidePinMenu];
			
			return YES;
		}
		if (self.appListController.jumpList.isOpen) {
			[self.appListController hideJumpList];
			
			return YES;
		}
		
		if ([self.appListController isSearching]) {
			[self.appListController setIsSearching:NO];
			
			return YES;
		}
		
		if ([[self.startScreenController pinnedTiles] count] > 0) {
			if (self.rootScrollView.contentOffset.x != 0 || self.startScreenController.startScrollView.contentOffset.y != -24) {
				[self.rootScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
				[self.startScreenController.startScrollView setContentOffset:CGPointMake(0, -24) animated:YES];
				[self.appListController.appList setContentOffset:CGPointMake(0, 0) animated:YES];
				
				return YES;
			}
		}
	}
	
	return NO;
}

- (UIImageView*)wallpaperView {
	return wallpaperView;
}

- (void)updateWallpaper {
	[wallpaperView setImage:[RSAesthetics homeScreenWallpaper]];
}

- (id)currentApplication {
	return currentApplication;
}

@end
