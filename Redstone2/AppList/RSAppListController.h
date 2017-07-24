/**
 @class RSAppListController
 @author Sniper_GER
 @discussion A class that controls Redstone's App List component
 */

#import <UIKit/UIKit.h>

@class RSTextField, RSAppListSection, RSApp, SBLeafIcon, RSFlyoutMenu, RSJumpList;

@interface RSAppListController : UIViewController <UIScrollViewDelegate> {
	NSMutableArray* sections;
	NSMutableArray* apps;
	NSMutableDictionary* appsBySection;

	UILabel* noResultsLabel;
	
	UIView* sectionBackgroundContainer;
	UIImageView* sectionBackgroundImage;
	UIView* sectionBackgroundOverlay;
	
	UITapGestureRecognizer* dismissRecognizer;
}

@property (nonatomic, strong) RSApp* selectedApp;
@property (nonatomic, strong) RSFlyoutMenu* pinMenu;
@property (nonatomic, strong) RSJumpList* jumpList;
@property (nonatomic, strong) RSTextField* searchBar;
@property (nonatomic, assign) BOOL isUninstallingApp;

- (CGPoint)contentOffset;

- (void)setContentOffset:(CGPoint)contentOffset;

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated;

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
 Moves the App List scroll view to a given section header

 @param letter The letter matching the section header
 */
- (void)jumpToSectionWithLetter:(NSString*)letter;

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

/**
 Adds a new entry to App List when SpringBoard adds a new icon to iOS' home screen

 @param icon The icon SpringBoard added to the home screen
 */
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

/**
 Sets the download state and progress for an App List entry matching \p leafIdentifier

 @param leafIdentifier The bundle identifier to match an App List entry with
 @param progress The current download progress
 @param state The current download state
 */
- (void)setDownloadProgressForIcon:(NSString*)leafIdentifier progress:(float)progress state:(int)state;

/**
 Receives the text entered in App List's search bar and shows all entries fitting this query. If the search bar contains no text, all apps are shown again.
 */
- (void)showAppsFittingQuery;

/**
 Sets the visibilty of the "No results for" label and sets its query text

 @param visible The visibility state of the "No results for" label
 @param query The query to show in the label
 */
- (void)showNoResultsLabel:(BOOL)visible forQuery:(NSString*)query;

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

/**
 Shows App List's Jump List
 */
- (void)showJumpList;

/**
 Hides App List's Jump List
 */
- (void)hideJumpList;

@end
