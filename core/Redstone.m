#import "../RedstoneHeaders.h"

@implementation Redstone

static Redstone* sharedInstance;
static UIImageView* wallpaperView;

+ (id)sharedInstance {
	return sharedInstance;
}

+ (void)hideAllExcept:(id)objectToShow {
	if (objectToShow) {
		[objectToShow setHidden:NO];
	}

	for (UIView* view in [[[objc_getClass("SBUIController") sharedInstance] window] subviews]) {
		if ([view isKindOfClass:NSClassFromString(@"SBHostWrapperView")] || [view isKindOfClass:NSClassFromString(@"RSRootScrollView")]) {
			[view setHidden:NO];
		} else if (view == wallpaperView) {
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
		if ([view isKindOfClass:NSClassFromString(@"RSRootScrollView")]) {
			[view setHidden:YES];
		} else if (view == wallpaperView) {
			[view setHidden:YES];
		} else if (view != objectToHide) {
			[view setHidden:NO];
		}
	}
}

- (id)initWithWindow:(id)_window {
	self = [super init];

	if (self) {
		NSLog(@"[Redstone] init");
		sharedInstance = self;

		[self loadFonts];

		self->window = _window;
		self->preferences = [[RSPreferences alloc] init];
		self->rootScrollView = [[RSRootScrollView alloc] initWithFrame:CGRectMake(0,0,screenW, screenH)];

		self->startScreenController = [[RSStartScreenController alloc] init];
		[self->rootScrollView addSubview:[self->startScreenController startScrollView]];

		wallpaperView = [[UIImageView alloc] initWithImage:[RSAesthetics getCurrentHomeWallpaper]];
		[wallpaperView setFrame:CGRectMake(0, 0, screenW, screenH)];
		[self->window addSubview:wallpaperView];

		[self->window addSubview:self->rootScrollView];
		if ([[[RSPreferences preferences] objectForKey:@"startScreenEnabled"] boolValue]) {
			[Redstone hideAllExcept:self->rootScrollView];
		} else {
			[Redstone showAllExcept:self->rootScrollView];
		}
	}
	return self;
}

- (void)setWindow:(UIWindow*)_window {
	self->window = _window;
}

- (UIWindow*)window {
	return self->window;
}

- (RSRootScrollView*)rootScrollView {
	return self->rootScrollView;
}

- (UIImageView*)wallpaperView {
	return wallpaperView;
}

- (BOOL)handleMenuButtonEvent {
	return false;
}
- (void)frontDisplayDidChange:(id)activeApplication {
	if ([activeApplication isKindOfClass:[objc_getClass("SBApplication") class]]) {
		[self->rootScrollView setHidden:YES];
		[wallpaperView setHidden:YES];
		[[RSStartScreenController sharedInstance] resetTileVisibility];
	} else {
		[self->rootScrollView setHidden:NO];
		[wallpaperView setHidden:NO];
	}
}

- (void)finishUIUnlockFromSource {
	//[self->startScreenController returnToHomescreen];

	id hiddenView = nil;

	if ([[objc_getClass("SBUserAgent") sharedUserAgent] foregroundApplicationDisplayID]) {
		hiddenView = nil;
	} else {
		hiddenView = self->rootScrollView;
		[self->startScreenController returnToHomescreen];
	}

	[Redstone hideAllExcept:hiddenView];
}

- (void)loadFonts {
	[UIFont registerFontFromURL:[NSURL fileURLWithPath:@"/var/mobile/Library/FESTIVAL/Redstone.bundle/Fonts/segoeui.ttf"]];
	[UIFont registerFontFromURL:[NSURL fileURLWithPath:@"/var/mobile/Library/FESTIVAL/Redstone.bundle/Fonts/segoeuil.ttf"]];
	[UIFont registerFontFromURL:[NSURL fileURLWithPath:@"/var/mobile/Library/FESTIVAL/Redstone.bundle/Fonts/segoeuisl.ttf"]];
	[UIFont registerFontFromURL:[NSURL fileURLWithPath:@"/var/mobile/Library/FESTIVAL/Redstone.bundle/Fonts/segmdl2.ttf"]];
}

- (void)updatePreferences {
	[wallpaperView setImage:[RSAesthetics getCurrentHomeWallpaper]];
	[self->startScreenController loadTiles];
}

@end
