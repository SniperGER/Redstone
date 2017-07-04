/**
 @class RSAppListController
 @author Sniper_GER
 @discussion A class that controls Redstone's App List component
 */

#import <UIKit/UIKit.h>

@interface RSAppListController : UIViewController {
	NSMutableArray* sections;
	NSMutableArray* apps;
	NSMutableDictionary* appsBySection;
}

+ (id)sharedInstance;

- (CGFloat)getMaxDelayForAnimation;

- (void)animateIn;

- (void)animateOut;

@end
