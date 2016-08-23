#import "RSRootScrollView.h"

#define PREF_PATH @"/var/mobile/Library/Preferences/ml.festival.redstone.plist"

RSRootScrollView* rootScrollView;

@interface SBHomeScreenViewController : UIViewController
@end

@interface SBHomeScreenView : UIView
@end

SBHomeScreenView* homeScreenView;

NSUserDefaults *defaults;

static void LoadSettings() {
    defaults = [[NSUserDefaults alloc] initWithSuiteName:@"ml.festival.redstone"];
    [defaults registerDefaults:@{
        @"enabled": @YES,
        @"accentColor": @"0078D7",
        @"tileOpacity": @0.6
    }];
}

%hook SBHomeScreenView

-(id)layoutSubviews {
    id r = %orig;

    if ([defaults boolForKey:@"enabled"]) {
        homeScreenView = self;

        for (UIView* subview in [self subviews]) {
            if (![subview isKindOfClass:[RSRootScrollView class]]) {
                [subview setHidden:YES];
            }
        }
    }

    return r;
}

%end

%hook SBLockScreenManager

-(void)_finishUIUnlockFromSource:(int)arg1 withOptions:(id)arg2 {
    if ([defaults boolForKey:@"enabled"]) {
        [rootScrollView removeFromSuperview];
        CGRect rootViewRect = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
        rootScrollView = [[RSRootScrollView alloc] initWithFrame:rootViewRect];
        [homeScreenView addSubview:rootScrollView];
    }
    %orig(arg1,arg2);
}

%end

%hook SBApplication

-(void)willAnimateDeactivation:(BOOL)arg1 {
    %orig(arg1);

    if ([defaults boolForKey:@"enabled"]) {
        if (homeScreenView != nil) {
            [rootScrollView removeFromSuperview];
            CGRect rootViewRect = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
            rootScrollView = [[RSRootScrollView alloc] initWithFrame:rootViewRect];
            [homeScreenView addSubview:rootScrollView];
        }
    }
}

-(void)didAnimateActivation {
    %orig;
}

%end

/*%hook SpringBoard

-(void)_menuButtonUp:(struct __GSEvent *)arg1 {
    %orig(arg1);

dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
[rootScrollView.startScrollView appHomescreenAnimation];
});

}

%end*/

static void ChangeNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
LoadSettings();
}

%ctor
{

CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, ChangeNotification, CFSTR("ml.festival.redstone.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
LoadSettings();

}