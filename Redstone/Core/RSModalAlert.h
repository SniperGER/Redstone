#import <UIKit/UIKit.h>

@interface RSModalAlert : UIView {
	NSMutableArray* actionButtons;
	NSMutableArray* actionHandlers;
	
	UIView* alertView;
	UILabel* alertTitle;
	UILabel* alertMessage;
}

@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* message;

- (id)modalAlertWithTitle:(NSString*)title message:(NSString*)message;
- (void)addActionWithTitle:(NSString*)title handler:(void (^)(void))callback;
- (void)show;
- (void)hide;

@end
