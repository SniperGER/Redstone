#import <UIKit/UIKit.h>

@class RSAppList, RSApp, RSPinMenu;

@interface RSAppListController : NSObject <UIScrollViewDelegate> {
	RSAppList* _appList;
	NSMutableArray* sections;
	NSMutableDictionary* appsBySection;
	
	UIView* sectionBackgroundContainer;
	UIImageView* sectionBackgroundImage;
	UIView* sectionBackgroundOverlay;
	
	RSPinMenu* pinMenu;
	BOOL showsPinMenu;
}

@property (nonatomic, retain) RSAppList* appList;

+ (id)sharedInstance;
- (void)prepareForAppLaunch:(RSApp*)sender;

- (void)updateSectionOverlayPosition;
- (void)setSectionOverlayAlpha:(CGFloat)alpha;

- (void)showPinMenuForApp:(RSApp*)app;
- (void)hidePinMenu;

@end
