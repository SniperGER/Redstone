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

@class RSStartScrollView, RSTile;

@interface RSStartScreenController : NSObject {
	RSStartScrollView* startScrollView;
	NSMutableArray* pinnedLeafIds;
	RSTile* selectedTile;
	BOOL isEditing;
}

+ (id)sharedInstance;
- (RSStartScrollView*)startScrollView;

- (void)loadTiles;
- (void)saveTiles;
- (void)pinTileWithId:(NSString*)leadId;
- (void)unpinTile:(id)tile;

- (void)prepareForAppLaunch:(id)sender;
- (void)returnToHomescreen;
- (void)resetTileVisibility;

- (void)setIsEditing:(BOOL)editing;
- (BOOL)isEditing;
- (void)setSelectedTile:(RSTile*)tile;
- (RSTile*)selectedTile;

- (id)affectedTilesForAttemptingSnapForRect:(CGRect)rect;
- (void)moveDownAffectedTilesForAttemptingSnapForRect:(CGRect)rect;
- (CGPoint)getNearestSnapPointForRect:(CGRect)frame;
- (void)restartMoveTimer:(UIView*)sender;

@end
