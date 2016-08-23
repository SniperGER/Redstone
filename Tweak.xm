#import "RSRootView.h"
#import "CAKeyframeAnimation+AHEasing.h"

@interface SBHomeScreenWindow : UIWindow
@end

extern "C" UIImage * _UICreateScreenUIImage();

RSRootView* rootView;
SBHomeScreenWindow* homeScreenView;
BOOL appSwitcherIsOpen = NO;
BOOL activeAppIsOpen;

static void LoadSettings() {
    /*defaults = [[NSUserDefaults alloc] initWithSuiteName:@"ml.festival.redstone"];
    [defaults registerDefaults:@{
        @"enabled": @YES,
        @"accentColor": @"0078D7",
        @"tileOpacity": @0.6
    }];*/
    
    //CGRect rootViewRect = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    //rootView = [[RSRootView alloc] initWithFrame:rootViewRect];
}

static void addTileViewToHomescreen() {
    if (!rootView) {
        CGRect rootViewRect = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
        rootView = [[RSRootView alloc] initWithFrame:rootViewRect];
    }
    if (homeScreenView != nil) {
        /*for (UIView* subview in [homeScreenView subviews]) {
            if (![subview isKindOfClass:[RSRootScrollView class]]) {
                [subview setHidden:YES];
            }
        }*/
        [rootView removeFromSuperview];
        [homeScreenView addSubview:rootView];
        [rootView setHomescreenWallpaper];
        [rootView resetHomeScrollPosition];
    }
}

%hook SpringBoard

-(void)_handleMenuButtonEvent {
//-(void)_menuButtonUp:(id)arg1 {
    if (!appSwitcherIsOpen) {
        if (![rootView handleMenuButtonPressed]) {
            %orig;
        } else {
            [self clearMenuButtonTimer];
            [self cancelMenuButtonRequests];
        }
    } else {
        %orig;
    }
}

-(void)frontDisplayDidChange:(id)arg1 {
    %orig(arg1);

    [rootView setCurrentApplication:arg1];
    
    //if ([defaults boolForKey:@"enabled"]) {
        if (arg1 != nil && [arg1 isKindOfClass:[%c(SBApplication) class]]) {
            activeAppIsOpen = YES;
            //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (activeAppIsOpen && !appSwitcherIsOpen) {
                    [rootView applicationDidFinishLaunching];
                }
            //});
        } else {
            activeAppIsOpen = NO;
        }
    //}
}

%end


%hook SBHomeScreenWindow

-(id)_initWithFrame:(CGRect)arg1 debugName:(id)arg2 scene:(id)arg3 attached:(BOOL)arg4 {
    id r = %orig(arg1, arg2, arg3, arg4);
    
    homeScreenView = r;
    
    //if ([defaults boolForKey:@"enabled"]) {
        //addTileViewToHomescreen();
    //} 
    return r;
}
%end

%hook SBLockScreenManager

-(void)_finishUIUnlockFromSource:(int)arg1 withOptions:(id)arg2 {
    %orig(arg1,arg2);
    
    //if ([defaults boolForKey:@"enabled"]) {
        addTileViewToHomescreen();
        //[rootScrollView willAnimateDeactivation];
    //}
}

%end

%hook SBApplication

-(void)willAnimateDeactivation:(BOOL)arg1 {
    %orig(arg1);

    //if ([defaults boolForKey:@"enabled"]) {
        addTileViewToHomescreen();
        /*activeAppIsOpen = NO;
        if (!appSwitcherIsOpen) {
            [rootScrollView willAnimateDeactivation];
        }*/
    //}
}

%end

%hook SBDeckSwitcherViewController

-(void)viewDidAppear:(BOOL)arg1 {
    %orig(arg1);
    
    //if ([defaults boolForKey:@"enabled"]) {
        appSwitcherIsOpen = YES;
        addTileViewToHomescreen();
    //}
}
-(void)viewWillDisappear:(BOOL)arg1 {
    %orig(arg1);
    
    //if ([defaults boolForKey:@"enabled"]) {
        appSwitcherIsOpen = NO;
        //[rootScrollView deckSwitcherDidAppear];
    //}
}

%end

%hook SBHomeScreenViewController

-(unsigned long long)supportedInterfaceOrientations {
    return 1;
}

%end

// UIAnimations

%hook SBUIAnimationZoomDownApp

-(void)_startAnimation {
    %orig;

    [rootView->rootScrollView->tileScrollView prepareForEntryAnimation];

    UIImage *screenImage = _UICreateScreenUIImage();
    UIImageView *screenImageView = [[UIImageView alloc] initWithImage:screenImage];
    [rootView addSubview:screenImageView];

    CAAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
                                                            function:CubicEaseInOut
                                                           fromValue:1.0
                                                             toValue:0.0];
    opacity.duration = 0.4;
    opacity.removedOnCompletion = NO;
    opacity.fillMode = kCAFillModeForwards;
    
    CAAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"
                                                          function:CubicEaseInOut
                                                         fromValue:1.0
                                                           toValue:1.5];
    scale.duration = 0.4;
    scale.removedOnCompletion = NO;
    scale.fillMode = kCAFillModeForwards;

    [screenImageView.layer addAnimation:opacity forKey:@"opacity"];
    [screenImageView.layer addAnimation:scale forKey:@"scale"];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [screenImageView removeFromSuperview];
        [rootView->rootScrollView->tileScrollView tileEntryAnimation];
    });
}

%end

/*%hook% SBUIAnimationZoomDownLockScreenToHome
%end*/

static void ChangeNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    LoadSettings();
}

static void lockedDevice(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    UIKeyboardImpl *impl = [%c(UIKeyboardImpl) activeInstance];
    [impl dismissKeyboard];
}

%ctor {
    // Settings changed
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, ChangeNotification, CFSTR("ml.festival.redstone.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);

    // Device has been locked
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, lockedDevice, CFSTR("com.apple.springboard.lockcomplete"), NULL, CFNotificationSuspensionBehaviorCoalesce);

    LoadSettings();
}