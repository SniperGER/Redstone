//
//  RSTile.h
//  Threshold
//
//  Created by Janik Schmidt on 30.07.16.
//  Copyright © 2016 FESTIVAL Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSStartScrollView.h"
#import "Headers.h"
#include <objc/runtime.h>

@class Redstone;

@interface RSTile : UIView {
    int tileSize;
    RSStartScrollView* parentView;
    //UILabel* appLabel;
    //NSString* applicationIdentifier;
    UIImageView* tileImage;
}

@property float tileX;
@property float tileY;
@property (retain) UILabel* appLabel;
@property (retain) NSString* applicationIdentifier;

-(id)initWithTileSize:(int)tileSize withOptions:(NSDictionary*)options;

@end


