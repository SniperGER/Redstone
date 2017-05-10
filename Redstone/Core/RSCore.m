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
		
		wallpaperView = [[UIImageView alloc] initWithImage:[RSAesthetics getCurrentWallpaper]];
		[wallpaperView setFrame:[[UIScreen mainScreen] bounds]];
		[self->_window addSubview:wallpaperView];
		
		self.rootScrollView = [[RSRootScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
		[self->_window addSubview:self.rootScrollView];
		
		self.startScreenController = [RSStartScreenController new];
		[self.rootScrollView addSubview:self.startScreenController.startScrollView];
		
		self.launchScreenController = [RSLaunchScreenController new];
		[self.rootScrollView addSubview:self.launchScreenController.launchScreen];
	}
	
	return self;
}

- (void)frontDisplayDidChange:(id)arg1 {
	currentApplication = arg1;
	
	if (arg1) {
		//[self.rootScrollView setHidden:YES];
		[self.launchScreenController hide];
	} else {
		[self.rootScrollView setHidden:NO];
	}
}

@end