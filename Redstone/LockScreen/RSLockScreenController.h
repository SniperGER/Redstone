#import <UIKit/UIKit.h>

@class RSLockScreen;

@interface RSLockScreenController : NSObject <UIScrollViewDelegate>

@property (nonatomic, retain) UIView* containerView;
@property (nonatomic, retain) RSLockScreen* lockScreen;

- (void)setTime:(NSString*)time;
- (void)setDate:(NSString*)date;

@end
