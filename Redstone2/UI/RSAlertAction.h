#import <UIKit/UIKit.h>

@class RSTiltView;

@interface RSAlertAction : RSTiltView

@property (copy) void (^handler) (void);

/**
 Initializes a new alert action with a given title and callback action \p handler

 @param title The title that is shown on the action
 @param handler The function that is called when the action is tapped
 @return An initialized instance of RSAlertAction
 */
+ (id)actionWithTitle:(NSString*)title handler:(void (^)(void))handler;

@end
