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

+ (id)alertControllerWithTitle:(NSString *)title message:(NSString *)message;

- (void)addAction:(RSAlertAction*)action;

- (void)show;

@end
