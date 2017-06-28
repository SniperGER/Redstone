#import <UIKit/UIKit.h>

@class SBIconModel;

@interface SBIconController : NSObject

+ (id)sharedInstance;
- (SBIconModel*)model;

@end
