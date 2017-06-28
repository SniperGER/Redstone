/**
 @class RSStartScreenController
 @author Sniper_GER
 @discussion A class that controls Redstone's Start Screen component
 */

#import <UIKit/UIKit.h>

@interface RSStartScreenController : UIViewController {
	NSMutableArray* pinnedTiles;
	NSMutableArray* pinnedLeafIdentifiers;
}

- (void)loadTiles;
- (void)saveTiles;

@end
