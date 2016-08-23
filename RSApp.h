//
//  RSApp.h
//  Redstone
//
//  Created by Janik Schmidt on 02.08.16.
//  Copyright © 2016 FESTIVAL Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <objc/runtime.h>

@class Redstone;

@interface RSApp : UITableViewCell {
    UIImageView* _appImage;
    UIView* _appImageTile;
    UILabel* _appTitle;
    NSString* _appIdentifier;
}

@property (retain) NSString* appIdentifier;

-(id)initWithFrame:(CGRect)frame withApp:(LSApplicationProxy*)app;
-(void)launchApp;

@end
