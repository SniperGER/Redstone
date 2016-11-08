/*
  Redstone
  A Windows 10 Mobile experience for iOS
  Compatible with iOS 9 (tested with iOS 9.3.3 and iOS 6.1.3);

  Licensed under GNU GPLv3

  © 2016 Sniper_GER, FESTIVAL Development
  All rights reserved.
*/

#import <UIKit/UIKit.h>

//@class RSAppListController, RSStartScreenController, RSRootScrollView;
@class RSRootScrollView, RSStartScreenController, RSAppListController, RSLaunchScreenController;

@interface Redstone : NSObject {
	UIWindow* _window;
	RSAppListController* _appListController;
	RSStartScreenController* _startScreenController;
	RSRootScrollView* _rootScrollView;
}

@property (assign,nonatomic) UIWindow* window;
@property (nonatomic,retain) RSRootScrollView* rootScrollView;
@property (nonatomic,retain) RSStartScreenController* startScreenController;
@property (nonatomic,retain) RSAppListController* appListController;
@property (nonatomic,retain) RSLaunchScreenController* launchScreenController;


+(Redstone*)sharedInstance;
+(void)hideAllExcept:(id)arg1;
+(void)showAllExcept:(id)arg1;

-(id)initWithWindow:(id)arg1;
-(void)setWindow:(UIWindow*)arg1;
-(UIWindow*)window;
-(void)updatePreferences;
-(void)loadFonts;
-(BOOL)hanldeMenuButtonPressed;
-(void)setCurrentApplication:(id)app;
-(UIImageView*)wallpaperView;

@end