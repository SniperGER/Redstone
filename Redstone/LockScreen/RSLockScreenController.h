#import <UIKit/UIKit.h>

@class RSLockScreenView, RSLockScreenMediaControlsView, RSLockScreenPasscodeEntryController;

@interface RSLockScreenController : NSObject <UIScrollViewDelegate> {
	UIImageView* wallpaperView;
	UIView* wallpaperOverlayView;
	UIScrollView* lockScreenScrollView;
}

@property (nonatomic, retain) UIView* containerView;
@property (nonatomic, retain) RSLockScreenView* lockScreenView;
@property (nonatomic, retain) RSLockScreenMediaControlsView* mediaControlsView;
@property (nonatomic, retain) RSLockScreenPasscodeEntryController* passcodeEntryController;
@property (nonatomic, assign) BOOL isScrolling;
@property (nonatomic, assign) BOOL isShowingPasscodeScreen;

+ (id)sharedInstance;

- (void)setLockScreenTime:(NSString*)time;
- (void)setLockScreenDate:(NSString*)date;
- (void)resetLockScreen;

@end
