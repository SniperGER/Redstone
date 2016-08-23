#import "CommonHeaders.h"
#import "RSTiltView.h"

@class RSTileScrollView;

@interface RSTile : UIView {
	int _tileSize;
	float _tileX;
	float _tileY;
	RSTileScrollView* _parentView;
	UILabel* _appLabel;
	NSString* _applicationIdentifier;
	RSTiltView* _tileInnerView;
	RSTiltView* _tiltButton;
	UIImageView* _tileImage;
	UIView* editingModeButtons;

	UIView* unpinButton;
	UIView* changeSizeButton;

	BOOL isCurrentlyEditing;

@public
	CGPoint tileOrigin;
	NSMutableArray* activePositions;

	CGPoint originalCenter;
}

@property (assign) int tileSize;
@property (assign) float tileX;
@property (assign) float tileY;
@property (retain) RSTileScrollView* parentView;
@property (retain) UILabel* appLabel;
@property (retain) NSString* applicationIdentifier;
@property (retain) UIView* tileInnerView;
@property (retain) RSTiltView* tiltButton;
@property (retain) UIImageView* tileImage;

-(id)initWithTileSize:(int)tileSize withOptions:(NSDictionary*)options;
-(void)updateTileColor;
-(float)scaleButtonRotationForCurrentSize;
-(void)exitEditMode;
-(void)changeEditFocusToOtherTile;
-(void)setIsCurrentlyEditing:(BOOL)isEditing;

@end
