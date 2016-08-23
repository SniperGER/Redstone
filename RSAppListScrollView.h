#import "CommonHeaders.h"
#import "RSAppListSection.h"
//#import "RSAppListItem.h"
#import "RSAppListItemContainer.h"
#import "RSPinMenu.h"

@class RSRootScrollView, RSAppListItem;

@interface RSAppListScrollView : UITableViewController <UITableViewDelegate> {
	NSArray* appsInList;
	NSMutableDictionary* appSections;

	NSMutableArray* appSectionHeaders;
	NSMutableArray* appSectionListItems;

	NSMutableArray* sectionKeysWithApps;

	RSPinMenu* applicationPinMenu;
	NSString* applicationAboutToPin;
}

@property (retain) RSRootScrollView* rootScrollView;
@property (assign) BOOL pinMenuIsOpen;

-(void)addAppsAndSections;

-(void)openPinMenu:(RSAppListItem*)appListItem;
-(void)closePinMenu;
-(void)triggerAppLaunch:(NSString*)applicationIdentifier sender:(RSAppListItem*)sender;
-(void)resetAppVisibility;

@end