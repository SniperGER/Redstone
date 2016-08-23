#import <UIKit/UIKit.h>
#import "CommonHeaders.h"
#import "RSTileScrollView.h"
#import "RSAppListScrollView.h"
#import "RSSearchBar.h"
#import "RSJumpListView.h"

@class RSAppListScrollView;

@interface RSRootScrollView : UIScrollView <UIScrollViewDelegate> {
	@public 
		UIView* transparentBG;
		RSTileScrollView* tileScrollView;
		RSAppListScrollView* appListScrollView;
		RSJumpListView* jumpListView;
		UIView* launchBG;

		RSSearchBar* searchInput;
}

-(void)showLaunchImage:(NSString*)bundleIdentifier;
-(void)resetScrollPosition;

@end