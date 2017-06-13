#import <UIKit/UIKit.h>

@interface RSAppListSection : RSTiltView <UIGestureRecognizerDelegate> {
	UILabel* sectionLabel;
	
	UIImageView* backgroundImage;
	UIView* backgroundImageOverlay;
}

@property (nonatomic, strong) NSString* displayName;
@property (nonatomic, assign) int yCoordinate;

- (id)initWithFrame:(CGRect)frame letter:(NSString*)letter;

@end
