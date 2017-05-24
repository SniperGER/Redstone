#import <UIKit/UIKit.h>

@interface RSNotificationView : UIView {
	UILabel* titleLabel;
	UILabel* subtitleLabel;
	UILabel* messageLabel;
}

- (id)notificationWithTitle:(NSString*)title subtitle:(NSString*)subtitle message:(NSString*)message;
- (void)show;
- (void)hide;


@end
