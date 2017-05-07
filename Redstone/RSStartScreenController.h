#import <Foundation/Foundation.h>

@class RSStartScrollView, RSTile;

@interface RSStartScreenController : NSObject {
	RSStartScrollView* _startScrollView;
	NSMutableArray* pinnedTiles;
}

@property (nonatomic, retain) RSStartScrollView* startScrollView;

- (void)moveAffectedTilesForTile:(RSTile*)movedTile;

@end
