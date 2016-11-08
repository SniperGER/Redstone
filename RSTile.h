#import <UIKit/UIKit.h>
#import "CommonHeaders.h"

@class SBIcon, RSTiltView;

@interface RSTile : UIView {
	RSTiltView* innerView;
	NSArray* supportedSizes;
	NSString* leafId;
	NSString* resourcePath;
	SBIcon* icon;
	UIView* unpinButton;
	UIView* scaleButton;
	UILabel* appLabel;
	int size;
	BOOL isSelectedTile;
	BOOL isPlayingLiftAnimation;
	BOOL launchEnabled;
	BOOL shouldHover;
	BOOL isInactive;
	BOOL isBeingMoved;
	CGPoint originalCenter;
}

@property (nonatomic,assign) int tileX;
@property (nonatomic,assign) int tileY;

-(id)initWithFrame:(CGRect)frame leafId:(id)arg2 size:(int)arg3;
-(void)setIsSelectedTile:(BOOL)isSelected;
-(void)tapped:(id)sender;
-(void)pressed:(id)sender;
-(void)unpin:(id)sender;
-(void)setNextSize:(id)sender;
-(int)size;
-(CGPoint)originalCenter;
-(NSString*)leafId;
-(SBIcon*)icon;
-(void)updateTileColor;

@end