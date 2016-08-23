#import "CommonHeaders.h"

@class RSRootScrollView, RSTile;

@interface RSTileScrollView : UIScrollView {
    NSMutableArray* allTiles;
    id _parentRootScrollView;

@public
	BOOL isEditing;
    NSMutableArray* pinnedBundleIdentifiers;
    NSMutableDictionary* snapPositions;
}

@property (retain) RSRootScrollView* parentRootScrollView;

-(void)createTileWithBundleIdentifier:(NSString*)bundleIdentifier;
-(void)unpinTile:(RSTile*)tile;

-(void)tileExitAnimation:(RSTile*)sender;
-(void)tileEntryAnimation;
-(void)resetTileVisibility;
-(void)prepareForEntryAnimation;
-(void)enterEditModeWithTile:(RSTile*)tile;
-(void)changeEditingTileFocus:(RSTile*)tile;
-(void)exitEditMode;

-(void)moveTilesBeginningAtRow:(NSInteger)row withAmount:(NSInteger)amount fromTile:(RSTile*)tile;

@end