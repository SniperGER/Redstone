#import <Foundation/Foundation.h>

@class RSStartScrollView, RSTile;

@interface RSStartScreenController : NSObject {
	RSStartScrollView* _startScrollView;
	NSMutableArray* pinnedTiles;
	
	BOOL _isEditing;
	RSTile* _selectedTile;
}

@property (nonatomic, retain) RSStartScrollView* startScrollView;
@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, retain) RSTile* selectedTile;

- (void)moveAffectedTilesForTile:(RSTile*)movedTile;
- (void)prepareForAppLaunch:(RSTile*)sender;
- (void)returnToHomescreen;

@end
