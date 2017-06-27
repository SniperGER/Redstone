#import <UIKit/UIKit.h>

@class BBBulletin, SBApplication;

@interface RSNotificationView : UIView {
	NSTimer* slideOutTimer;
	
	UIImageView* toastIcon;
	UILabel* titleLabel;
	UILabel* subtitleLabel;
	UILabel* messageLabel;
	
	BBBulletin* bulletin;
	SBApplication* application;
}

- (id)initForBulletin:(BBBulletin*)_bulletin;
- (void)animateIn;
- (void)animateOut;
- (void)stopSlideOutTimer;
- (void)resetSlideOutTimer;

@end
