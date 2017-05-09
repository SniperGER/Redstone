#import <UIKit/UIKit.h>

@class SBIcon;

@interface RSTile : UIView <UIGestureRecognizerDelegate> {
	CGPoint centerOffset;
	CGPoint _originalCenter;
	
	int _size;
	SBIcon* _icon;
	
	UILabel* tileLabel;
	UIImageView* tileImageView;
	
	BOOL _isSelectedTile;
	
	UITapGestureRecognizer* tapGestureRecognizer;
	UILongPressGestureRecognizer* longPressGestureRecognizer;
	UIPanGestureRecognizer* panGestureRecognizer;
}

@property (nonatomic, assign) CGPoint originalCenter;
@property (nonatomic, assign) int size;
@property (nonatomic, strong) SBIcon* icon;
@property (nonatomic, assign) BOOL isSelectedTile;

- (id)initWithFrame:(CGRect)frame leafIdentifier:(NSString*)leafId size:(int)tileSize;
- (CGRect)positionWithoutTransform;
- (CGPoint)originalCenter;

@end
