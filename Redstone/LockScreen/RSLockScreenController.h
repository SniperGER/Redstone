#import <UIKit/UIKit.h>

@class RSLockScreen, RSMediaControls;

@interface RSLockScreenController : NSObject <UIScrollViewDelegate>

@property (nonatomic, retain) UIView* containerView;
@property (nonatomic, retain) UIImageView* wallpaperView;
@property (nonatomic, retain) RSLockScreen* lockScreen;
@property (nonatomic, retain) RSMediaControls* mediaControls;
@property (nonatomic, assign) BOOL isScrolling;

+ (id)sharedInstance;

- (void)setTime:(NSString*)time;
- (void)setDate:(NSString*)date;

@end
