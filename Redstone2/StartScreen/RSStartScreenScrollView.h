/**
 @class RSStartScreenScrollView
 @author Sniper_GER
 @discussion The main Start Screen scroll view that contains Redstone's tiles
 */

#import <UIKit/UIKit.h>

@class RSTiltView;

@interface RSStartScreenScrollView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, strong) RSTiltView* allAppsButton;

@end
