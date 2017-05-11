#import <UIKit/UIKit.h>

@class SBLeafIcon;

@interface RSTile : UIView <UIGestureRecognizerDelegate> {
	CGPoint centerOffset;
	CGPoint _originalCenter;
	
	int _size;
	SBLeafIcon* _icon;
	
	UILabel* tileLabel;
	UIImageView* tileImageView;
	
	BOOL _isSelectedTile;
	
	UITapGestureRecognizer* tapGestureRecognizer;
	UILongPressGestureRecognizer* longPressGestureRecognizer;
	UIPanGestureRecognizer* panGestureRecognizer;
	
	BOOL shouldAllowPan;
}

@property (nonatomic, assign) CGPoint originalCenter;
@property (nonatomic, assign) int size;
@property (nonatomic, strong) SBLeafIcon* icon;
@property (nonatomic, assign) BOOL isSelectedTile;

- (id)initWithFrame:(CGRect)frame leafIdentifier:(NSString*)leafId size:(int)tileSize;
- (CGRect)positionWithoutTransform;
- (CGPoint)originalCenter;

@end
