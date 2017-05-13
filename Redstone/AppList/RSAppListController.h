#import <UIKit/UIKit.h>

@class RSAppList, RSApp, RSPinMenu, RSSearchBar;

@interface RSAppListController : NSObject <UIScrollViewDelegate> {
	RSSearchBar* _searchBar;
	BOOL _isSearching;
	
	RSAppList* _appList;
	NSMutableArray* sections;
	NSMutableDictionary* appsBySection;
	
	UIView* sectionBackgroundContainer;
	UIImageView* sectionBackgroundImage;
	UIView* sectionBackgroundOverlay;
	
	RSPinMenu* pinMenu;
	BOOL showsPinMenu;
}

@property (nonatomic, retain) RSSearchBar* searchBar;
@property (nonatomic, retain) RSAppList* appList;

+ (id)sharedInstance;
- (void)prepareForAppLaunch:(RSApp*)sender;

- (void)updateSectionOverlayPosition;
- (void)setSectionOverlayAlpha:(CGFloat)alpha;

- (void)showPinMenuForApp:(RSApp*)app;
- (void)hidePinMenu;

- (BOOL)isSearching;
- (void)setIsSearching:(BOOL)isSearching;
- (void)showAppsFittingQuery:(NSString*)query;

@end
