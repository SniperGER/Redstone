//
//  RSRootScrollView.h
//  Redstone
//
//  Created by Janik Schmidt on 30.07.16.
//  Copyright © 2016 FESTIVAL Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSAppListTable.h"
#import "Headers.h"

@class Redstone;

@interface RSRootScrollView : UIScrollView <UIScrollViewDelegate> {
    RSStartScrollView* _startScrollView;
    RSAppListTable* appListScrollView;
    UIView* transparentBG;
    UIView* launchBG;
}

@property (retain) RSStartScrollView* startScrollView;

//-(void)didAnimateActivationForApp;
-(void)showLaunchImage:(NSString*)bundleIdentifier;

@end
