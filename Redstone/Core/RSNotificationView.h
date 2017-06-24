#import <UIKit/UIKit.h>

@class BBBulletin, SBApplication;

@interface RSNotificationView : UIView {
	SBApplication* application;
	UILabel* titleLabel;
	UILabel* subtitleLabel;
	UILabel* messageLabel;
	
	UIImageView* toastIcon;
	
	NSTimer* hideTimer;
}

- (id)initNotificationForBulletin:(BBBulletin*)bulletin isStatic:(BOOL)isStatic;
- (void)show;
- (void)hide;


@end
