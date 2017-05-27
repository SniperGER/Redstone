#import <UIKit/UIKit.h>

@class BBBulletin;

@interface RSNotificationView : UIView {
	UILabel* titleLabel;
	UILabel* subtitleLabel;
	UILabel* messageLabel;
	
	UIImageView* toastIcon;
	
	NSTimer* hideTimer;
}

- (id)notificationForBulletin:(BBBulletin*)bulletin isStatic:(BOOL)isStatic;
- (void)show;
- (void)hide;


@end
