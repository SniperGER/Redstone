#import <UIKit/UIKit.h>

@class SBIcon;

@interface RSTile : UIView {
	CGPoint centerOffset;
	CGPoint originalCenter;
	
	int _size;
	SBIcon* _icon;
	UILabel* tileLabel;
	
	BOOL _isSelectedTile;
	
	UIPanGestureRecognizer* panGestureRecognizer;
}

@property (nonatomic, assign) int size;
@property (nonatomic, strong) SBIcon* icon;
@property (nonatomic, assign) BOOL isSelectedTile;

- (id)initWithFrame:(CGRect)frame leafIdentifier:(NSString*)leafId size:(int)tileSize;
- (CGRect)positionWithoutTransform;
- (CGPoint)originalCenter;

@end
