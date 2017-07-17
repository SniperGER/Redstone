/**
 @class RSStartScreenController
 @author Sniper_GER
 @discussion A class that controls Redstone's Start Screen component
 */

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>

@class RSTile;

@interface RSStartScreenController : UIViewController {
	NSMutableArray* pinnedTiles;
	NSMutableArray* pinnedLeafIdentifiers;
	
	CGRect nextTileFrameUpdate;
}

@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, strong) RSTile* selectedTile;

/**
 Returns a global instance of \p RSStartScreenController
 
 @return A global instance of \p RSStartScreenController
 */
+ (id)sharedInstance;

/**
 Loads the current tile layout saved in Redstone's preferences and fills the Start Screen
 */
- (void)loadTiles;

/**
 Saves the current tile layout (position, size) to Redstone's preferences file
 */
- (void)saveTiles;

/**
 Returns a tile matching a specific bundle identifier \p leafIdentifer or nil of none of the pinned tiles match \p leafIdentifier

 @param leafIdentifier The bundle identifier to match a tile
 @return A tile matching \p leafIdentifier or nil of none of the pinned tiles match \p leafIdentifier
 */
- (RSTile*)tileForLeafIdentifier:(NSString*)leafIdentifier;

- (NSArray*)pinnedTiles;

/**
 Updates the Start Screen scroll view content size based on the last tile's frame
 */
- (void)updateStartContentSize;

/**
 Sets visibility of pinned tiles. Useful when messing with App Switcher
 @param visible Sets tiles visible or invisible
 */
- (void)setTilesVisible:(BOOL)visible;

/**
 Pins a tile for \p leafIdentifier on the Start Screen, or, if an application matching \p leafIdentifier doesn't exist, does nothing

 @param leafIdentifier The application bundle identifier to pin a tile with on the Start Screen
 */
- (void)pinTileWithIdentifier:(NSString*)leafIdentifier;


/**
 Removes a tile \p tile from the Start Screen

 @param tile The tile to be removed from the Start Screen
 */
- (void)unpinTile:(RSTile*)tile;

/**
 Enable/disable Start Screen's editing mode. Does not automatically set the originating tile as selected

 @param isEditing Set Start Screen's editing mode enabled or disabled
 */
- (void)setIsEditing:(BOOL)isEditing;

/**
 Sets the currently selected tile. If \p nil is passed as an argument, every tile will be scaled down, otherwise every tile except for \p selectedTile will be scaled down

 @param selectedTile The tile to be selected
 */
- (void)setSelectedTile:(RSTile*)selectedTile;

/**
 Snaps a tile \p tile into position, based on the position \p touchPosition where the touch ended

 @param tile The tile to be snapped
 @param touchPosition The position where the touch ended
 */
- (void)snapTile:(RSTile*)tile withTouchPosition:(CGPoint)touchPosition;

/**
 Moves every tile affected by a frame change from \p tile

 @param tile The tile that has been snapped into position or has been resized
 */
- (void)moveAffectedTilesForTile:(RSTile*)tile;

/**
 Clears empty space created by any tile frame changes
 */
- (void)eliminateEmptyRows;

/**
 Applies any pending frame updates and displays them in one animation
 */
- (void)applyPendingFrameUpdates;

/**
 Returns an array of tiles sorted by their position

 @return A mutable array containing every pinned tile sorted by their position
 */
- (NSMutableArray*)sortPinnedTiles;

/**
 Calculates the maximum animation delay and returns it as a float

 @return The maximum animation delay based on every pinned tile's position
 */
- (CGFloat)getMaxDelayForAnimation;

/**
 Fires the Start Screen animation from an app to the Start Screen
 */
- (void)animateIn;

/**
 Fires the Start Screen animation from the Start Screen to an app
 */
- (void)animateOut;

- (void)startLiveTiles;

- (void)stopLiveTiles;

@end
