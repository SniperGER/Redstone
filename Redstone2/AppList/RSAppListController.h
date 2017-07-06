/**
 @class RSAppListController
 @author Sniper_GER
 @discussion A class that controls Redstone's App List component
 */

#import <UIKit/UIKit.h>

@class RSAppListSection, RSApp;

@interface RSAppListController : UIViewController <UIScrollViewDelegate> {
	NSMutableArray* sections;
	NSMutableArray* apps;
	NSMutableDictionary* appsBySection;
	
	UIView* sectionBackgroundContainer;
	UIImageView* sectionBackgroundImage;
	UIView* sectionBackgroundOverlay;
	
	RSFlyoutMenu* pinMenu;
}

+ (id)sharedInstance;

- (void)updateSectionsWithOffset:(CGFloat)offset;

- (void)setSectionOverlayAlpha:(CGFloat)alpha;

- (void)updateSectionOverlayPosition;

- (void)loadApps;

- (void)layoutContentsWithSections:(BOOL)addSections;

- (void)sortAppsAndLayout:(NSArray*)_sections;

- (RSAppListSection*)sectionWithLetter:(NSString*)letter;

- (RSApp*)appForLeafIdentifier:(NSString*)leafIdentifier;

- (CGFloat)getMaxDelayForAnimation;

- (void)animateIn;

- (void)animateOut;

@end
