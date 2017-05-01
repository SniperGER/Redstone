/*
 * Redstone
 * A Windows 10 Mobile experience for iOS
 * Compatible with iOS 9 (tested with iOS 9.3.3);
 *
 * Licensed under GNU GPLv3
 *
 * © 2016 Sniper_GER, FESTIVAL Development
 * All rights reserved.
 */

@class RSTiltView, SBIcon;

@interface RSTile : UIView {
	RSTiltView* innerView;
	UIImageView* tileImage;
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
	CGRect originalRect;
	CGPoint originalCenter;
	
	UITapGestureRecognizer* tap;
	UILongPressGestureRecognizer* press;
}

@property (nonatomic,assign) int tileX;
@property (nonatomic,assign) int tileY;

- (id)initWithFrame:(CGRect)frame leafId:(id)leafId size:(int)size;
- (void)tapped:(id)sender;
- (void)pressed:(id)sender;
- (void)setIsSelectedTile:(BOOL)selected;
- (void)resetFrameToOriginalPosition;
- (int)size;
- (BOOL)isSelectedTile;
- (CGRect)originalRect;
- (CGPoint)originalCenter;
- (SBIcon*)icon;

@end
