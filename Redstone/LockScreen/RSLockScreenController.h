#import <UIKit/UIKit.h>

@class RSLockScreenView, RSNowPlayingControls, RSLockScreenPasscodeEntryController;

@interface RSLockScreenController : NSObject <UIScrollViewDelegate> {
	UIImageView* wallpaperView;
	UIView* wallpaperOverlayView;
	UIScrollView* lockScreenScrollView;
}

@property (nonatomic, strong) UIView* containerView;
@property (nonatomic, strong) RSLockScreenView* lockScreenView;
@property (nonatomic, strong) RSNowPlayingControls* mediaControlsView;
@property (nonatomic, strong) RSLockScreenPasscodeEntryController* passcodeEntryController;
@property (nonatomic, assign) BOOL isScrolling;
@property (nonatomic, assign) BOOL isShowingPasscodeScreen;
@property (nonatomic, copy) void (^completionHandler)();

+ (id)sharedInstance;

- (void)setLockScreenTime:(NSString*)time;
- (void)setLockScreenDate:(NSString*)date;
- (void)resetLockScreen;
- (void)attemptManualUnlockWithCompletionHandler:(void (^)(void))completion;

- (void)displayNotification:(RSNotificationView*)notification;

- (void)updateWallpaper;

@end
