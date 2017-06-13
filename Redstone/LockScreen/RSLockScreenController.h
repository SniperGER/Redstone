#import <UIKit/UIKit.h>

@class RSLockScreenView, RSLockScreenMediaControlsView, RSLockScreenPasscodeEntryController;

@interface RSLockScreenController : NSObject <UIScrollViewDelegate> {
	UIImageView* wallpaperView;
	UIView* wallpaperOverlayView;
	UIScrollView* lockScreenScrollView;
}

@property (nonatomic, strong) UIView* containerView;
@property (nonatomic, strong) RSLockScreenView* lockScreenView;
@property (nonatomic, strong) RSLockScreenMediaControlsView* mediaControlsView;
@property (nonatomic, strong) RSLockScreenPasscodeEntryController* passcodeEntryController;
@property (nonatomic, assign) BOOL isScrolling;
@property (nonatomic, assign) BOOL isShowingPasscodeScreen;

+ (id)sharedInstance;

- (void)setLockScreenTime:(NSString*)time;
- (void)setLockScreenDate:(NSString*)date;
- (void)resetLockScreen;

- (void)displayNotification:(RSNotificationView*)notification;

- (void)updateWallpaper;

@end
