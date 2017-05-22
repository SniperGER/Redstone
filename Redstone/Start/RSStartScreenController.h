#import <Foundation/Foundation.h>

@class RSStartScrollView, RSTile;

@interface RSStartScreenController : NSObject {
	RSStartScrollView* _startScrollView;
	
	NSMutableArray* pinnedTiles;
	NSMutableArray* pinnedLeafIdentifiers;
	
	BOOL _isEditing;
	RSTile* _selectedTile;
}

@property (nonatomic, retain) RSStartScrollView* startScrollView;
@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, retain) RSTile* selectedTile;

+ (id)sharedInstance;

- (id)viewIntersectsWithAnotherView:(CGRect)rect;
- (void)resetTileVisibility;

- (void)loadTiles;
- (void)saveTiles;
- (NSArray*)pinnedTiles;
- (NSArray*)pinnedLeafIdentifiers;
- (RSTile*)tileForLeafIdentifier:(NSString*)leafId;

- (void)setIsEditing:(BOOL)isEditing;
- (void)setSelectedTile:(RSTile *)selectedTile;
- (void)pinTileWithId:(NSString *)leafId;
- (void)unpinTile:(RSTile *)tile;

- (void)snapTile:(RSTile *)tile withTouchPosition:(CGPoint)position;
- (void)moveAffectedTilesForTile:(RSTile *)movedTile;
- (void)eliminateEmptyRows;
- (void)updateStartContentSize;

- (void)prepareForAppLaunch:(RSTile *)sender;
- (void)returnToHomescreen;

@end
