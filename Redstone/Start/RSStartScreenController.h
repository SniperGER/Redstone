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
- (void)moveAffectedTilesForTile:(RSTile*)movedTile;
- (void)prepareForAppLaunch:(RSTile*)sender;
- (void)returnToHomescreen;

- (void)pinTileWithId:(NSString*)leafId;
- (void)unpinTile:(RSTile*)tile;

@end
