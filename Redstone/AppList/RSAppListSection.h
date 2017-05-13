#import <UIKit/UIKit.h>

@interface RSAppListSection : UIView {
	NSString* _displayName;
	UILabel* sectionLabel;
	int _yCoordinate;
	
	UIImageView* backgroundImage;
	UIView* backgroundImageOverlay;
}

@property (nonatomic, retain) NSString* displayName;
@property (nonatomic, assign) int yCoordinate;

- (id)initWithFrame:(CGRect)frame letter:(NSString*)letter;
- (void)updateBackgroundPosition;

- (void)setOverlayAlpha:(CGFloat)alpha;

@end
