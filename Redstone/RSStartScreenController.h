#import <Foundation/Foundation.h>

@class RSStartScrollView, RSTile;

@interface RSStartScreenController : NSObject {
	RSStartScrollView* _startScrollView;
	NSMutableArray* pinnedTiles;
}

@property (nonatomic, retain) RSStartScrollView* startScrollView;

- (void)moveDownAffectedTilesForTile:(RSTile*)movedTile withFrame:(CGRect)tileFrame;

@end
