/**
 @class RSHomeScreenController
 @author Sniper_GER
 @discussion Controls the Start Screen, App List and App Switcher components of Redstone
 */

#import <UIKit/UIKit.h>

@class RSStartScreenController, RSAppListController, RSLaunchScreenController, RSHomeScreenScrollView;

@interface RSHomeScreenController : NSObject <UIScrollViewDelegate> {
	RSStartScreenController* startScreenController;
	RSAppListController* appListController;
	RSLaunchScreenController* launchScreenController;
	
	UIImageView* wallpaperView;
	RSHomeScreenScrollView* scrollView;
}

@property (nonatomic, strong) UIWindow* window;
@property (nonatomic, strong) NSMutableArray* alertControllers;

/**
 Returns a global instance of \p RSHomeScreenController
 
 @return A global instance of \p RSHomeScreenController
 */
+ (id)sharedInstance;


/**
 Returns the Home Screen scroll view

 @return The Home Screen scroll view
 */
- (RSHomeScreenScrollView*)scrollView;

/**
 Returns the current parallax position of the Home Screen wallpaper

 @return The current parallax position
 */
- (CGFloat)parallaxPosition;

/**
 Sets the parallax value of \p wallpaperView based on \p RSStartScreenController's scroll view offset
 */
- (void)setParallaxPosition;

/**
 Fires a fade in animation if the device has been unlocked before
 */
- (void)deviceHasBeenUnlocked;

/**
 Launches an app either from Start Screen or App List, fires the launch animation and returns the calculated animation delay

 @return The current animation delay, based on Home Screen scroll view position
 */
- (CGFloat)launchApplication;

/**
 Enables or disables the scrolling behavior of the Home Screen Controller scroll view

 @param scrollEnabled The desired scrolling state
 */
- (void)setScrollEnabled:(BOOL)scrollEnabled;

/**
 Returns the current offset of the Home Screen scroll view

 @return The current Home Screen scroll view content offset
 */
- (CGPoint)contentOffset;

/**
 Sets the new offset of the Home Screen scroll view

 @param offset The new Home Screen scroll view content offset
 */
- (void)setContentOffset:(CGPoint)offset;

/**
 Sets the new offset of the Home Screen scroll view
 
 @param offset The new Home Screen scroll view content offset
 @param animated \p YES to animate the transition at a constant velocity to the new offset, \p NO to make the transition immediate.
 */
- (void)setContentOffset:(CGPoint)offset animated:(BOOL)animated;

@end
