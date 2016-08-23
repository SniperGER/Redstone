//
//  RSRootScrollView.h
//  
//
//  Created by Janik Schmidt on 06.08.16.
//
//

#import <UIKit/UIKit.h>
#import "UIFont+WDCustomLoader.h"
#import "RSAppList.h"
#import "Headers.h"

@interface RSRootScrollView : UIScrollView <UIScrollViewDelegate> {
    RSTileScrollView* _startScrollView;
    RSAppList* _appListScrollView;
    RSJumpListView* _jumpListView;
    UIView* _transparentBG;
    UIView* _launchBG;
}

@property (retain) RSTileScrollView* startScrollView;
@property (retain) RSAppList* appListScrollView;
@property (retain) RSJumpListView* jumpListView;
@property (retain) UIView* transparentBG;
@property (retain) UIView* launchBG;

-(void)showLaunchImage:(NSString*)bundleIdentifier;
-(void)showJumpList;

-(void)willAnimateDeactivation;
-(void)deckSwitcherDidAppear;
-(void)applicationDidFinishLaunching;
-(void)hanldeHomeButtonPress;

@end
