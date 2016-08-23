#import "Headers.h"

#define PREF_PATH @"/var/mobile/Library/Preferences/ml.festival.redstone.plist"

RSRootScrollView* rootScrollView;

@interface SBHomeScreenViewController : UIViewController
@end

@interface SBHomeScreenView : UIView
@end

@interface SBHomeScreenWindow : UIWindow
@end

@interface FBProcessState
@property (assign,getter=isForeground,nonatomic) BOOL foreground;              //@synthesize foreground=_foreground - In the implementation block
@property (assign,nonatomic) int taskState;                                    //@synthesize taskState=_taskState - In the implementation block
@property (assign,nonatomic) int visibility;
@end

SBHomeScreenWindow* homeScreenView;
NSUserDefaults *defaults;
BOOL appSwitcherIsOpen = NO;
BOOL activeAppIsOpen = NO;

static void LoadSettings() {
    defaults = [[NSUserDefaults alloc] initWithSuiteName:@"ml.festival.redstone"];
    [defaults registerDefaults:@{
        @"enabled": @YES,
        @"accentColor": @"0078D7",
        @"tileOpacity": @0.6
    }];
    
    CGRect rootViewRect = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    rootScrollView = [[RSRootScrollView alloc] initWithFrame:rootViewRect];
}

static void addTileViewToHomescreen() {
    if (homeScreenView != nil) {
        /*for (UIView* subview in [homeScreenView subviews]) {
            if (![subview isKindOfClass:[RSRootScrollView class]]) {
                [subview setHidden:YES];
            }
        }*/
        
        [rootScrollView removeFromSuperview];
        [rootScrollView deckSwitcherDidAppear];
        [homeScreenView addSubview:rootScrollView];
    }
}

static void resetHomeScreen() {
    if (homeScreenView != nil) {
        for (UIView* subview in [homeScreenView subviews]) {
            if (![subview isKindOfClass:[RSRootScrollView class]]) {
                [subview setHidden:NO];
            }
        }
    }
}

%hook SBHomeScreenWindow

-(id)_initWithFrame:(CGRect)arg1 debugName:(id)arg2 scene:(id)arg3 attached:(BOOL)arg4 {
    id r = %orig(arg1, arg2, arg3, arg4);
    
    homeScreenView = r;
    
    if ([defaults boolForKey:@"enabled"]) {
        addTileViewToHomescreen();
    } 
    return r;
}
%end

%hook SBLockScreenManager

-(void)_finishUIUnlockFromSource:(int)arg1 withOptions:(id)arg2 {
    %orig(arg1,arg2);
    
    if ([defaults boolForKey:@"enabled"]) {
        addTileViewToHomescreen();
        [rootScrollView willAnimateDeactivation];
    }
}

%end

%hook SBApplication

-(void)willAnimateDeactivation:(BOOL)arg1 {
    %orig(arg1);

    if ([defaults boolForKey:@"enabled"]) {
        addTileViewToHomescreen();
        activeAppIsOpen = NO;
        if (!appSwitcherIsOpen) {
            [rootScrollView willAnimateDeactivation];
        }
    }
}

%end

%hook SBDeckSwitcherViewController

-(void)viewDidAppear:(BOOL)arg1 {
    %orig(arg1);
    
    if ([defaults boolForKey:@"enabled"]) {
        appSwitcherIsOpen = YES;
        addTileViewToHomescreen();
    }
}
-(void)viewWillDisappear:(BOOL)arg1 {
    %orig(arg1);
    
    if ([defaults boolForKey:@"enabled"]) {
        appSwitcherIsOpen = NO;
        [rootScrollView deckSwitcherDidAppear];
    }
}

%end

// Disable Homescreen Rotation

%hook SpringBoard

-(long long)homeScreenRotationStyle {
    if ([defaults boolForKey:@"enabled"]) {
        return 0;
    }
    
    return %orig;
}

-(BOOL)homeScreenSupportsRotation {
    if ([defaults boolForKey:@"enabled"]) {
        return NO;
    }
    
    return %orig;
}

// Application did finish launching
-(void)frontDisplayDidChange:(id)arg1 {
    %orig(arg1);
    %log;
    
    if ([defaults boolForKey:@"enabled"]) {
        if (arg1 != nil && [arg1 isKindOfClass:[%c(SBApplication) class]]) {
            activeAppIsOpen = YES;
            //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (activeAppIsOpen && !appSwitcherIsOpen) {
                    [rootScrollView applicationDidFinishLaunching];
                }
            //});
        } else {
            activeAppIsOpen = NO;
        }
    }
}

// Hook home button press (hopefully it works as expected inside apps)
-(void)_menuButtonUp:(id)arg1 {
    %orig(arg1);
    
    if ([defaults boolForKey:@"enabled"]) {
        unsigned test = MSHookIvar<unsigned>(self, "_menuButtonClickCount");
        if (test == 0) {
            [rootScrollView handleHomeButtonPress];
        }
    }
}

%end

static void ChangeNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    LoadSettings();
}

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, ChangeNotification, CFSTR("ml.festival.redstone.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    LoadSettings();
}