#import <UIKit/UIKit.h>

@class SBLeafIcon, RSTiltView, RSTileInfo, RSTileNotificationView;
@protocol RSLiveTileDelegate;

@interface RSTile : RSTiltView <UIGestureRecognizerDelegate> {
	CGPoint centerOffset;
	
	UIView* tileWrapper;
	UIView* tileContainer;
	
	UILabel* tileLabel;
	UIImageView* tileImageView;
	
	int badgeValue;
	UILabel* badgeLabel;
	
	UIView* unpinButton;
	UIView* scaleButton;
	
	UITapGestureRecognizer* tapGestureRecognizer;
	UILongPressGestureRecognizer* longPressGestureRecognizer;
	UIPanGestureRecognizer* panGestureRecognizer;
	
	UITapGestureRecognizer* unpinGestureRecognizer;
	UITapGestureRecognizer* scaleGestureRecognizer;
	
	BOOL shouldAllowPan;
	
	UIView<RSLiveTileDelegate>* liveTile;
	NSTimer* liveTileUpdateTimer;
	NSTimer* liveTileAnimationTimer;
	NSInteger liveTilePageIndex;
	
	RSTileNotificationView* notificationTile;
}

@property (nonatomic, assign) CGPoint originalCenter;
@property (nonatomic, assign) int size;
@property (nonatomic, strong) RSTileInfo* tileInfo;
@property (nonatomic, strong) SBLeafIcon* icon;
@property (nonatomic, assign) BOOL isSelectedTile;
@property (nonatomic, assign) int tileX;
@property (nonatomic, assign) int tileY;
@property (nonatomic, assign, readonly) CGRect basePosition;

- (id)initWithFrame:(CGRect)frame leafIdentifier:(NSString*)leafId size:(int)tileSize;
- (CGRect)basePosition;
- (CGPoint)originalCenter;
- (void)setBadge:(int)badgeCount;

- (void)transitionLiveTileToStarted:(BOOL)ready;
- (void)startLiveTile;
- (void)stopLiveTile;
- (void)updateLiveTile;

- (void)addBulletin:(BBBulletin*)bulletin;
- (void)removeBulletin:(BBBulletin*)bulletin;

@end
