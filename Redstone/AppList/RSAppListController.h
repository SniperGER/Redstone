#import <UIKit/UIKit.h>

@class RSAppList, RSApp, RSAppListSection, RSPinMenu, RSSearchBar, RSJumpList, SBApplication;

@interface RSAppListController : NSObject <UIScrollViewDelegate> {
	NSMutableArray* sections;
	NSMutableDictionary* appsBySection;
	
	UIView* sectionBackgroundContainer;
	UIImageView* sectionBackgroundImage;
	UIView* sectionBackgroundOverlay;
	
	UILabel* noResultsLabel;
	
	RSPinMenu* pinMenu;
}

@property (nonatomic, strong) RSSearchBar* searchBar;
@property (nonatomic, strong) RSAppList* appList;
@property (nonatomic, assign) BOOL showsPinMenu;
@property (nonatomic, assign) BOOL isSearching;
@property (nonatomic, strong) RSJumpList* jumpList;

+ (id)sharedInstance;

- (void)addAppsAndSections;
- (RSAppListSection*)sectionWithLetter:(NSString*)letter;

- (void)prepareForAppLaunch:(RSApp*)sender;
- (void)returnToHomescreen;

- (void)updateSectionOverlayPosition;
- (void)setSectionOverlayAlpha:(CGFloat)alpha;

- (void)showPinMenuForApp:(RSApp*)app;
- (void)hidePinMenu;

- (void)showAppsFittingQuery:(NSString*)query;
- (void)showNoResultsLabel:(BOOL)visible forQuery:(NSString*)query;

- (void)jumpToSectionWithLetter:(NSString*)letter;
- (void)showJumpList;
- (void)hideJumpList;

- (void)uninstallApplication:(RSApp*)app;

@end
