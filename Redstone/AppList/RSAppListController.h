#import <UIKit/UIKit.h>

@class RSAppList, RSApp;

@interface RSAppListController : NSObject <UIScrollViewDelegate> {
	RSAppList* _appList;
	NSMutableArray* sections;
	NSMutableDictionary* appsBySection;
	
	UIView* sectionBackgroundContainer;
	UIImageView* sectionBackgroundImage;
	UIView* sectionBackgroundOverlay;
}

@property (nonatomic, retain) RSAppList* appList;

+ (id)sharedInstance;
- (void)prepareForAppLaunch:(RSApp*)sender;

- (void)updateSectionOverlayPosition;
- (void)setSectionOverlayAlpha:(CGFloat)alpha;

@end
