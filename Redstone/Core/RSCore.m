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
		if ([view isKindOfClass:[RSRootScrollView class]] || view == wallpaperView) {
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
		self->_window = window;
		
		[UIFont registerFontFromURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Fonts/segoeui.ttf", RESOURCE_PATH]]];
		[UIFont registerFontFromURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Fonts/segoeuil.ttf", RESOURCE_PATH]]];
		[UIFont registerFontFromURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Fonts/segoeuisl.ttf", RESOURCE_PATH]]];
		[UIFont registerFontFromURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Fonts/segmdl2.ttf", RESOURCE_PATH]]];
		
		self->preferences = [[RSPreferences alloc] init];
		
		wallpaperView = [[UIImageView alloc] initWithImage:[RSAesthetics getCurrentWallpaper]];
		[wallpaperView setFrame:[[UIScreen mainScreen] bounds]];
		[self->_window addSubview:wallpaperView];
		
		self.rootScrollView = [[RSRootScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
		[self->_window addSubview:self.rootScrollView];
		
		self.startScreenController = [RSStartScreenController new];
		[self.rootScrollView addSubview:self.startScreenController.startScrollView];
		
		self.launchScreenController = [RSLaunchScreenController new];
		[self.window addSubview:self.launchScreenController.launchScreen];
		
		self.appListController = [RSAppListController new];
		[self.rootScrollView addSubview:self.appListController.appList];
	}
	
	return self;
}

- (void)frontDisplayDidChange:(id)arg1 {
	currentApplication = arg1;
	
	if (arg1) {
		[self.startScreenController resetTileVisibility];
		[self.launchScreenController hide];
		[self.rootScrollView setContentOffset:CGPointMake(0, 0)];
		[[self.startScreenController startScrollView] setContentOffset:CGPointMake(0, -24)];
		[self.appListController.appList setContentOffset:CGPointMake(0, 0)];
		
		if ([[self.startScreenController pinnedTiles] count] > 0) {
			[self.rootScrollView setScrollEnabled:YES];
		} else {
			[self.rootScrollView setScrollEnabled:NO];
		}
	} else {
		[self.rootScrollView setHidden:NO];
		[wallpaperView setHidden:NO];
	}
}

- (BOOL)handleMenuButtonEvent {
	if ([self.startScreenController isEditing]) {
		[self.startScreenController setIsEditing:NO];
		[self.startScreenController saveTiles];
		
		return YES;
	}
	
	if (self.rootScrollView.contentOffset.x != 0 || self.startScreenController.startScrollView.contentOffset.y != -24) {
		if ([[self.startScreenController pinnedTiles] count] > 0) {
			[self.rootScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
			[self.startScreenController.startScrollView setContentOffset:CGPointMake(0, -24) animated:YES];
			[self.appListController.appList setContentOffset:CGPointMake(0, 0) animated:YES];
		}
		
		return YES;
	}
	
	return NO;
}

- (UIImageView*)wallpaperView {
	return wallpaperView;
}

- (id)currentApplication {
	return currentApplication;
}

@end
