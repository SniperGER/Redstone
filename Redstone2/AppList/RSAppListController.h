/**
 @class RSAppListController
 @author Sniper_GER
 @discussion A class that controls Redstone's App List component
 */

#import <UIKit/UIKit.h>

@class RSAppListSection, RSApp, SBLeafIcon;

@interface RSAppListController : UIViewController <UIScrollViewDelegate> {
	NSMutableArray* sections;
	NSMutableArray* apps;
	NSMutableDictionary* appsBySection;
	
	UIView* sectionBackgroundContainer;
	UIImageView* sectionBackgroundImage;
	UIView* sectionBackgroundOverlay;
	
	UITapGestureRecognizer* dismissRecognizer;
}

@property (nonatomic, strong) RSApp* selectedApp;
@property (nonatomic, strong) RSFlyoutMenu* pinMenu;

/**
 Returns a global instance of \p RSAppListController
 
 @return A global instance of \p RSAppListController
 */
+ (id)sharedInstance;

/**
 App List's scroll view has moved, update section header positions

 @param offset App List's scroll view content offset
 */
- (void)updateSectionsWithOffset:(CGFloat)offset;

/**
 The Home Screen controller has moved, update App List's darkening overlay

 @param alpha Home Screen's scroll view content offset
 */
- (void)setSectionOverlayAlpha:(CGFloat)alpha;

/**
 Updates the section background's frame
 */
- (void)updateSectionOverlayPosition;

/**
 Load all installed apps into App List
 */
- (void)loadApps;

/**
 Add every RSApp and RSAppListSection to App Lost

 @param addSections \p YES to include section headers, \p NO to hide them (no effect)
 */
- (void)layoutContentsWithSections:(BOOL)addSections;

/**
 Sorts every RSApp into its designated section and sets frames of all subviews

 @param _sections The current section dictionary
 */
- (void)sortAppsAndLayout:(NSArray*)_sections;

- (void)addAppForIcon:(SBLeafIcon*)icon;

/**
 Returns an instance of RSAppListSection matching a specific letter

 @param letter The letter to look up section headers with
 @return An instance of RSAppListSection matching \p letter, \p nil if nothing matches
 */
- (RSAppListSection*)sectionWithLetter:(NSString*)letter;

/**
 Returns an instance of RSApp matching a specific bundle identifier
 
 @param leafIdentifier The bundle identifier to look up App List entries with
 @return An instance of RSApp matching \p leafIdentifier, \p nil if nothing matches
 */
- (RSApp*)appForLeafIdentifier:(NSString*)leafIdentifier;

/**
 Shows the pin menu Flyout for a specific app and position

 @param app The app to open the pin menu for
 @param point The current position of the App List entry relative to the main window
 */
- (void)showPinMenuForApp:(RSApp*)app withPoint:(CGPoint)point;

/**
 Hides the pin menu Flyout
 */
- (void)hidePinMenu;

- (void)setDownloadProgressForIcon:(NSString*)leafIdentifier progress:(float)progress state:(int)state;

/**
 Calculates the maximum animation delay and returns it as a float
 
 @return The maximum animation delay based on every app list entry
 */
- (CGFloat)getMaxDelayForAnimation;

/**
 Fires the App List animation from an app to the App List
 */
- (void)animateIn;

/**
 Fires the App List animation from the App List to an app
 */
- (void)animateOut;

@end
