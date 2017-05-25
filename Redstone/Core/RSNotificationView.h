#import <UIKit/UIKit.h>

@interface RSNotificationView : UIView {
	UILabel* titleLabel;
	UILabel* subtitleLabel;
	UILabel* messageLabel;
	
	UIImageView* toastIcon;
	
	NSTimer* hideTimer;
}

- (id)notificationWithTitle:(NSString*)title subtitle:(NSString*)subtitle message:(NSString*)message bundleIdentifier:(NSString*)bundleIdentifier;
- (id)staticNotificationWithTitle:(NSString*)title subtitle:(NSString*)subtitle message:(NSString*)message bundleIdentifier:(NSString*)bundleIdentifier;
- (void)show;
- (void)hide;


@end
