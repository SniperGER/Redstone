//
//  RSStartScrollView.h
//  Threshold
//
//  Created by Janik Schmidt on 30.07.16.
//  Copyright © 2016 FESTIVAL Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Headers.h"

@class Redstone;

@interface RSStartScrollView : UIScrollView {
    NSMutableArray* allTiles;
}

@property (retain) id parentRootScrollView;

+(id)sharedInstance;
-(void)triggerAppLaunch:(NSString*)applicationIdentifier sender:(id)sender;
-(void)appHomescreenAnimation;

@end
