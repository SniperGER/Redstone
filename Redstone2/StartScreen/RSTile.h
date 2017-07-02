/**
 @class RSTile
 @author Sniper_GER
 @discussion A class that creates tiles to be displayed on Start Screen
 */

#import <UIKit/UIKit.h>

@class RSTiltView, SBLeafIcon, RSTileInfo;

@interface RSTile : RSTiltView <UIGestureRecognizerDelegate> {
	UITapGestureRecognizer* tapGestureRecognizer;
	UILongPressGestureRecognizer* longPressGestureRecognizer;
	UIPanGestureRecognizer* panGestureRecognizer;
	
	BOOL panEnabled;
	CGPoint centerOffset;
	
	UIView* tileWrapper;
	UIView* tileContainer;
	
	UILabel* tileLabel;
	UIImageView* tileImageView;
	
	UIView* unpinButton;
	UIView* scaleButton;
	UITapGestureRecognizer* unpinGestureRecognizer;
	UITapGestureRecognizer* scaleGestureRecognizer;
}

@property (nonatomic, assign) int size;
@property (nonatomic, strong) SBLeafIcon* icon;
@property (nonatomic, strong) RSTileInfo* tileInfo;
@property (nonatomic, assign) BOOL isSelectedTile;
@property (nonatomic, assign) CGPoint originalCenter;

@property (nonatomic, assign) CGPoint nextCenterUpdate;
@property (nonatomic, assign) CGRect nextFrameUpdate;

/**
 Initializes a tile with a given frame, application identifier and size index

 @param frame The frame to initialize the tile with
 @param leafIdentifier The identifier for the application the tile is supposed to launch
 @param size The size index (1-3 on phones, 1-4 on tablets) for internal use
 @return An initialized instance of RSTile
 */
- (id)initWithFrame:(CGRect)frame leafIdentifier:(NSString*)leafIdentifier size:(int)size;

/**
 Returns a tile's position regardless of animations or transforms

 @return A \p CGRect containing the tile's position regardless of animations or transforms
 */
- (CGRect)basePosition;

@end
