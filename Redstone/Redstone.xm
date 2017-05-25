#import "Redstone.h"
#import "substrate.h"

extern "C" UIImage * _UICreateScreenUIImage();

RSCore* redstone;
BOOL switcherIsOpen;

void playZoomDownAppAnimation(BOOL applicationSnapshot) {
	[redstone.rootScrollView setHidden:NO];
	for (RSTile* tile in [redstone.startScreenController pinnedTiles]) {
		[tile.layer setOpacity:0];
	}
	
	if (applicationSnapshot && [redstone currentApplication] != nil && ![[redstone currentApplication] isKindOfClass:%c(SBDashBoardViewController)] && ![[redstone currentApplication] isKindOfClass:%c(SBLockScreenViewController)]) {
		UIImage *screenImage = _UICreateScreenUIImage();
		UIImageView *screenImageView = [[UIImageView alloc] initWithImage:screenImage];
		[redstone.window addSubview:screenImageView];
		
		CAAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
																function:CubicEaseInOut
															   fromValue:1.0
																 toValue:0.0];
		opacity.duration = 0.225;
		opacity.removedOnCompletion = NO;
		opacity.fillMode = kCAFillModeForwards;
		
		CAAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"
															  function:CubicEaseInOut
															 fromValue:1.0
															   toValue:1.5];
		scale.duration = 0.25;
		scale.removedOnCompletion = NO;
		scale.fillMode = kCAFillModeForwards;
		
		[screenImageView.layer addAnimation:opacity forKey:@"opacity"];
		[screenImageView.layer addAnimation:scale forKey:@"scale"];
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[screenImageView removeFromSuperview];
			
			[redstone.startScreenController returnToHomescreen];
		});
	} else {
		[redstone.startScreenController returnToHomescreen];
	}
}

id traverseResponderChainForUIViewController(id target) {
	id nextResponder = [target nextResponder];
	if ([nextResponder isKindOfClass:[UIViewController class]]) {
		return nextResponder;
	} else if ([nextResponder isKindOfClass:[UIView class]]) {
		return traverseResponderChainForUIViewController(nextResponder);
	} else {
		return nil;
	}
}

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)arg1 {
	%orig(arg1);
	
	redstone = [[RSCore alloc] initWithWindow:[[%c(SBUIController) sharedInstance] window]];
	[RSCore hideAllExcept:nil];
}

- (void)frontDisplayDidChange:(id)arg1 {
	%orig(arg1);
	
	[redstone frontDisplayDidChange:arg1];
}

- (void)_handleMenuButtonEvent {
	if (redstone && !switcherIsOpen) {
		if (![redstone handleMenuButtonEvent]) {
			%orig;
		} else {
			[self clearMenuButtonTimer];
			[self cancelMenuButtonRequests];
		}
	} else {
		%orig;
	}
}

%end

%hook SBHomeHardwareButton
- (void)singlePressUp:(id)arg1 {
	if (redstone && !switcherIsOpen) {
		if (![redstone handleMenuButtonEvent]) {
			%orig;
		}
	} else {
		%orig(arg1);
	}
}
%end

%hook SBLockScreenManager

- (BOOL)_finishUIUnlockFromSource:(int)arg1 withOptions:(id)arg2 {
	[[RSLockScreenController sharedInstance] resetLockScreen];
	
	return %orig;
}

%end

%hook SBUIAnimationZoomApp

- (void)__startAnimation {
	if ([self zoomDirection] == 1) {
		playZoomDownAppAnimation(YES);
	}
	
	%orig;
}

%end

%hook SBUIAnimationZoomDownApp

- (void)_startAnimation {
	playZoomDownAppAnimation(YES);
	
	%orig;
}

%end

%hook SBHomeScreenViewController

- (NSInteger)supportedInterfaceOrientations {
	return 1;
}

%end

%hook SBDeckSwitcherViewController

- (void)viewDidAppear:(BOOL)arg1 {
	%orig(arg1);
	
	switcherIsOpen = YES;
	
	if (redstone) {
		[redstone.rootScrollView setHidden:NO];
	}
}

- (void)viewWillDisappear:(BOOL)arg1 {
	%orig(arg1);
	
	switcherIsOpen = NO;
	
	if (redstone) {
		[redstone.rootScrollView setHidden:YES];
	}
}

%end

%hook SBIconModel

- (void)addIcon:(id)arg1 {
	%orig;
	
	[redstone.appListController addAppsAndSections];
}

%end

%hook SBApplication

- (void)setBadge:(id)arg1 {
	%orig(arg1);
	
	if ([redstone.startScreenController tileForLeafIdentifier:[self bundleIdentifier]]) {
		[[redstone.startScreenController tileForLeafIdentifier:[self bundleIdentifier]] setBadge:[arg1 intValue]];
	}
}

%end

%hook SBWallpaperController

- (void)_handleWallpaperChangedForVariant:(int)arg1 {
	%orig(arg1);
	
	[[[RSCore sharedInstance] wallpaperView] setImage:[RSAesthetics homeScreenWallpaper]];
	[[[RSLockScreenController sharedInstance] wallpaperView] setImage:[RSAesthetics lockScreenWallpaper]];
}

%end

%hook SBBacklightController

- (void)_startFadeOutAnimationFromLockSource:(int)arg1 {
	if ([[RSLockScreenController sharedInstance] isScrolling] || [[RSLockScreenController sharedInstance] isShowingPasscodeScreen]) {
		[self resetIdleTimer];
		return;
	}
	
	%orig(arg1);
}

%end

%hook BBServer

-(void)_addBulletin:(BBBulletin*)arg1 {
	[[NSOperationQueue mainQueue] addOperationWithBlock:^ {
		// I guess this has to run on the main thread so Lock Screen gets updated
		[[RSLockScreenController sharedInstance] displayLockScreenNotificationWithTitle:[arg1 title] subtitle:[arg1 subtitle] message:[arg1 message] bundleIdentifier:[arg1 section]];
	}];
	
	%log;
	%orig;
}

%end

%hook NCNotificationShortLookView

- (void)setFrame:(CGRect)frame {
	if (![self isNCNotification]) {
		frame = CGRectMake(-8, -8, screenWidth, frame.size.height);
		%orig(frame);
	} else {
		%orig(frame);
	}
}

- (void)layoutSubviews {
	BOOL isNCNotification = [self isNCNotification];
	for (UIView* subview in self.subviews) {
		if ([subview isKindOfClass:%c(RSNotificationView)] && isNCNotification) {
			[subview removeFromSuperview];
		}
		[subview setHidden:!isNCNotification];
	}
	
	if (!isNCNotification) {
		NCNotificationShortLookViewController* viewController = traverseResponderChainForUIViewController(self);
		BBBulletin* bulletin = [[viewController notificationRequest] bulletin];
		
		RSNotificationView* notificationView = [[RSNotificationView alloc] staticNotificationWithTitle:[bulletin title] subtitle:[bulletin subtitle] message:[bulletin message] bundleIdentifier:[bulletin section]];
		[self addSubview:notificationView];
	}
	
	%orig;
}

%new
- (BOOL)isNCNotification {
	UIView* view = self;
	BOOL canProceed = NO;
	
	while (view.superview) {
		if ([view.superview isKindOfClass:%c(NCNotificationListCollectionView)]) {
			canProceed = YES;
			break;
		}
		
		view = view.superview;
	}
	
	return canProceed;
}

%end
