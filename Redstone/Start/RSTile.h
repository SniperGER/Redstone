#import <UIKit/UIKit.h>

@class SBLeafIcon, RSTiltView;

@interface RSTile : RSTiltView <UIGestureRecognizerDelegate> {
	CGPoint centerOffset;
	CGPoint _originalCenter;
	
	int _size;
	SBLeafIcon* _icon;
	
	UILabel* tileLabel;
	UIImageView* tileImageView;
	
	int badgeValue;
	UILabel* badgeLabel;
	
	UIView* unpinButton;
	UIView* scaleButton;
	
	BOOL _isSelectedTile;
	
	UITapGestureRecognizer* tapGestureRecognizer;
	UILongPressGestureRecognizer* longPressGestureRecognizer;
	UIPanGestureRecognizer* panGestureRecognizer;
	
	UITapGestureRecognizer* unpinGestureRecognizer;
	UITapGestureRecognizer* scaleGestureRecognizer;
	
	BOOL shouldAllowPan;
}

@property (nonatomic, assign) CGPoint originalCenter;
@property (nonatomic, assign) int size;
@property (nonatomic, strong) SBLeafIcon* icon;
@property (nonatomic, assign) BOOL isSelectedTile;
@property (nonatomic, assign) int tileX;
@property (nonatomic, assign) int tileY;

- (id)initWithFrame:(CGRect)frame leafIdentifier:(NSString*)leafId size:(int)tileSize;
- (CGRect)positionWithoutTransform;
- (CGPoint)originalCenter;
- (void)setBadge:(int)badgeCount;

@end
