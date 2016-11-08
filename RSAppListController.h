#import <UIKit/UIKit.h>

@class RSAppList, RSApp, RSJumpList, RSPinMenu, RSSearchBar;

@interface RSAppListController : NSObject <UIScrollViewDelegate, UITextFieldDelegate> {
	UIView* baseView;
	RSAppList* appList;
	RSJumpList* jumpList;
	RSPinMenu* pinMenu;
	RSSearchBar* searchBar;
	UILabel* noResultsLabel;
	BOOL isSearching;
}

+(id)sharedInstance;
-(void)showNoResultsLabel:(BOOL)visible forQuery:(NSString*)query;
-(RSAppList*)appList;
-(void)showPinMenuForApp:(RSApp*)app;
-(void)hidePinMenu;
-(RSPinMenu*)pinMenu;
-(void)showJumpList;
-(void)hideJumpList;
-(RSJumpList*)jumpList;
-(void)searchBarTextChanged;
-(BOOL)isSearching;
-(void)setIsSearching:(BOOL)searching;
-(void)prepareForAppLaunch:(id)sender;
-(void)resetAppVisibility;
-(void)updateTileColors;
-(void)updatePreferences;

@end