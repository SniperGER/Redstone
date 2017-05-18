#import <UIKit/UIKit.h>

@class RSAppList, RSApp, RSAppListSection, RSPinMenu, RSSearchBar, RSJumpList, SBApplication;

@interface RSAppListController : NSObject <UIScrollViewDelegate> {
	RSSearchBar* _searchBar;
	BOOL _isSearching;
	
	RSAppList* _appList;
	NSMutableArray* sections;
	NSMutableDictionary* appsBySection;
	
	UIView* sectionBackgroundContainer;
	UIImageView* sectionBackgroundImage;
	UIView* sectionBackgroundOverlay;
	
	UILabel* noResultsLabel;
	
	RSPinMenu* pinMenu;
	BOOL _showsPinMenu;
	
	RSJumpList* _jumpList;
}

@property (nonatomic, retain) RSSearchBar* searchBar;
@property (nonatomic, retain) RSAppList* appList;
@property (nonatomic, assign) BOOL showsPinMenu;
@property (nonatomic, retain) RSJumpList* jumpList;

+ (id)sharedInstance;

- (RSAppListSection*)sectionWithLetter:(NSString*)letter;

- (void)prepareForAppLaunch:(RSApp*)sender;

- (void)updateSectionOverlayPosition;
- (void)setSectionOverlayAlpha:(CGFloat)alpha;

- (void)showPinMenuForApp:(RSApp*)app;
- (void)hidePinMenu;

- (BOOL)isSearching;
- (void)setIsSearching:(BOOL)isSearching;
- (void)showAppsFittingQuery:(NSString*)query;
- (void)showNoResultsLabel:(BOOL)visible forQuery:(NSString*)query;

- (void)jumpToSectionWithLetter:(NSString*)letter;
- (void)showJumpList;
- (void)hideJumpList;

- (void)uninstallApplication:(RSApp*)app;

@end
