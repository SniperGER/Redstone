/**
 @class RSAlertController
 @author Sniper_GER
 @discussion A controller that displays alerts
 */

#import <UIKit/UIKit.h>

@class RSAlertAction;

@interface RSAlertController : UIViewController {
	UIView* contentView;
	NSMutableArray* actions;
	
	UILabel* titleLabel;
	UILabel* messageLabel;
}

@property (nonatomic, strong) NSString* message;

/**
 Initializes a new alert controller with a given title and message

 @param title The title for the modal alert
 @param message The message for the modal alert
 @return An initialized instance of RSAlertController
 */
+ (id)alertControllerWithTitle:(NSString *)title message:(NSString *)message;

/**
 Adds a new action to the modal alert

 @param action The action to add to the modal alert
 */
- (void)addAction:(RSAlertAction*)action;

/**
 Shows the modal alert
 */
- (void)show;

@end
