#import "CommonHeaders.h"
#import "RSRootScrollView.h"


@interface RSRootView : UIView {
	UIImageView* _homeWallpaperView;
	id currentApplication;

@public
	RSRootScrollView* rootScrollView;
}

@property (retain) UIImageView* homeWallpaperView;

-(void)setHomescreenWallpaper;
-(void)resetHomeScrollPosition;
-(BOOL)handleMenuButtonPressed;

-(void)applicationDidFinishLaunching;

-(void)setCurrentApplication:(id)arg1;

@end