#import <UIKit/UIKit.h>

@interface RSAppListSection : UIView <UIGestureRecognizerDelegate> {
	NSString* _displayName;
	UILabel* sectionLabel;
	int _yCoordinate;
	
	UIImageView* backgroundImage;
	UIView* backgroundImageOverlay;
}

@property (nonatomic, retain) NSString* displayName;
@property (nonatomic, assign) int yCoordinate;

- (id)initWithFrame:(CGRect)frame letter:(NSString*)letter;

@end
