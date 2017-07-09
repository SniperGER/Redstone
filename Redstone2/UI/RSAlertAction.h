#import <UIKit/UIKit.h>

@class RSTiltView;

@interface RSAlertAction : RSTiltView

@property (copy) void (^handler) (void);

+ (id)actionWithTitle:(NSString*)title style:(UIAlertActionStyle)style handler:(void (^)(void))handler;

@end
