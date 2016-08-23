#import "CommonHeaders.h"
#import "RSTiltView.h"

@class RSRootScrollView;

@interface RSJumpListView : UIScrollView {
	NSArray* appsInList;
	NSMutableDictionary* appSections;
	NSMutableArray* sectionKeysWithApps;

@public
	BOOL isOpen;
}

@property (retain) RSRootScrollView* rootScrollView;

-(void)show;
-(void)hide:(id)sender;

@end