#import <UIKit/UIKit.h>

@class RSLockScreenView, RSPasscodeEntryView;

@interface RSLockScreenController : NSObject <UIScrollViewDelegate> {
	UIImageView* wallpaperView;
	UIView* wallpaperOverlayView;
	UIScrollView* lockScreenScrollView;
}

@property (nonatomic, retain) UIView* containerView;
@property (nonatomic, retain) RSLockScreenView* lockScreenView;
@property (nonatomic, retain) RSPasscodeEntryView* passcodeEntryView;

+ (id)sharedInstance;

- (void)setLockScreenTime:(NSString*)time;
- (void)setLockScreenDate:(NSString*)date;
- (void)resetLockScreen;

@end
