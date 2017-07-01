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

- (RSTile*)tileForLeafIdentifier:(NSString*)leafIdentifier;

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

- (void)snapTile:(RSTile*)tile withTouchPosition:(CGPoint)touchPosition;

- (CGFloat)getMaxDelayForAnimation;

- (void)animateIn;

- (void)animateOut;

@end
