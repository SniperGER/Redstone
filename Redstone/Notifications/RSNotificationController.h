#import <UIKit/UIKit.h>

@class RSNotificationWindow, BBBulletin;

@interface RSNotificationController : NSObject {
	RSNotificationWindow* notificationWindow;
}

+ (id)sharedInstance;

- (void)addBulletin:(BBBulletin*)bulletin;

@end
