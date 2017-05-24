#import <UIKit/UIKit.h>

@class RSLockScreen, RSMediaControls, RSPasscodeView;

@interface RSLockScreenController : NSObject <UIScrollViewDelegate>

@property (nonatomic, retain) UIView* containerView;
@property (nonatomic, retain) UIImageView* wallpaperView;
@property (nonatomic, retain) UIView* overlayView;
@property (nonatomic, retain) RSLockScreen* lockScreen;
@property (nonatomic, retain) RSMediaControls* mediaControls;
@property (nonatomic, retain) RSPasscodeView* passcodeView;

@property (nonatomic, assign) BOOL isScrolling;
@property (nonatomic, assign) BOOL isShowingPasscodeScreen;

+ (id)sharedInstance;

- (void)setTime:(NSString*)time;
- (void)setDate:(NSString*)date;

- (void)resetLockScreen;

@end
