//
//  RSStartScrollView.m
//  Threshold
//
//  Created by Janik Schmidt on 30.07.16.
//  Copyright © 2016 FESTIVAL Development. All rights reserved.
//

//#import "RSStartScrollView.h"
#import "Headers.h"
#import "CAKeyframeAnimation+AHEasing.h"
#import <math.h>

@implementation RSStartScrollView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.contentInset = UIEdgeInsetsMake(24, 0, 4, 0);
    allTiles = [[NSMutableArray alloc] init];

    NSArray* tiles = [RSTileDelegate getTileList];
    [self createTiles:tiles];
    
    return self;
}

-(void)createTiles:(NSArray*)tiles {
    float tileGridSize = ([self bounds].size.width)/6;
    
    int row = 0;
    float lastTileSize = 0;
    
    for (int i=0; i<[tiles count]; i++) {
        NSDictionary* tileInfo = [tiles objectAtIndex:i];

        float columnPos = [[tileInfo objectForKey:@"column"] intValue]*tileGridSize;
        float rowPos = [[tileInfo objectForKey:@"row"] intValue]*tileGridSize;

        NSDictionary* options = @{
                                  @"X": [NSNumber numberWithFloat:columnPos],
                                  @"Y": [NSNumber numberWithFloat:rowPos],
                                  @"displayIdentifier": [tileInfo objectForKey:@"bundleIdentifier"],
                                  @"parentView": self
                                  };
        
        RSTile* tile = [[RSTile alloc] initWithTileSize:[[tileInfo objectForKey:@"size"] intValue]
                                            withOptions:options];
        
        if ([[tileInfo objectForKey:@"row"] intValue] > row) {
            row = [[tileInfo objectForKey:@"row"] intValue];
            lastTileSize = [tile frame].size.height;
        }
        [allTiles addObject:tile];
        [self addSubview:tile];
    }
    
    RSAllAppsButton* allAppsButton = [[RSAllAppsButton alloc] initWithFrame:CGRectMake(0, (row)*tileGridSize+lastTileSize, [self frame].size.width, tileGridSize)];

    [self addSubview:allAppsButton];
    
    [self setContentSize:CGSizeMake(self.frame.size.width, (row)*tileGridSize + lastTileSize + allAppsButton.frame.size.height)];
    
    [self appHomescreenAnimation];
}

-(void)triggerAppLaunch:(NSString*)applicationIdentifier sender:(RSTile*)sender {
    CAAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
                                                            function:CubicEaseIn
                                                           fromValue:1.0
                                                             toValue:0.0];
    opacity.duration = 0.25;
    opacity.removedOnCompletion = NO;
    opacity.fillMode = kCAFillModeForwards;
    
    CAAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"
                                                          function:CubicEaseIn
                                                         fromValue:1.0
                                                           toValue:4.0];
    scale.duration = 0.3;
    scale.removedOnCompletion = NO;
    scale.fillMode = kCAFillModeForwards;
    
    
    
    NSMutableArray* visibleTiles = [[NSMutableArray alloc] init];
    NSMutableArray* invisibleTiles = [[NSMutableArray alloc] init];
    for (RSTile* view in allTiles) {
        if (CGRectIntersectsRect(self.bounds, view.frame)) {
            [visibleTiles addObject:view];
        } else {
            [invisibleTiles addObject:view];
        }
    }
    
    for (RSTile* view in invisibleTiles) {
        [view setHidden:true];
    }
    
    int baseItemIndex = (int)[visibleTiles indexOfObject:sender];
    
    for (RSTile* view in visibleTiles) {
        float layerX = -(view.tileX-CGRectGetMidX(self.bounds))/view.frame.size.width;
        float layerY = -(view.tileY-CGRectGetMidY(self.bounds))/view.frame.size.height;
        
        float delay = [self getTransitionDelayForItemAtIndex:(int)[visibleTiles indexOfObject:view] forBaseItem:baseItemIndex forItems:visibleTiles];
        
        view.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        view.layer.anchorPoint = CGPointMake(layerX, layerY);
        
        scale.beginTime = CACurrentMediaTime()+delay;
        opacity.beginTime = CACurrentMediaTime()+delay;
        
        if (view == sender) {
            scale.beginTime = CACurrentMediaTime()+delay+0.04;
            opacity.beginTime = CACurrentMediaTime()+delay+0.03;
        }
        
        //[view addAnimation:opacity forKey:@"opacity"];
        
        [view.layer addAnimation:scale forKey:@"scale"];
        [view.layer addAnimation:opacity forKey:@"opacity"];
    }
    
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(([visibleTiles count]*0.02) + 0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (RSTile* view in visibleTiles) {
            [view.layer setOpacity:0];
            //[view.layer removeAllAnimations];
        }
#if TARGET_IPHONE_SIMULATOR
        [self appHomescreenAnimation];
#else
        [(RSRootScrollView*)self.parentRootScrollView showLaunchImage:applicationIdentifier];
        /*id app = [[objc_getClass("SBApplicationController") sharedInstance] applicationWithBundleIdentifier:applicationIdentifier];
        [app setFlag:1 forActivationSetting:1];
        [[objc_getClass("SBUIController") sharedInstance] activateApplication:app];*/
#endif
    });
    
}

-(void)appHomescreenAnimation {
    [self setContentOffset:CGPointMake(0, -24)];
    
    CAAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
                                                            function:CubicEaseOut
                                                           fromValue:0.0
                                                             toValue:1.0];
    opacity.duration = 0.4;
    opacity.removedOnCompletion = NO;
    opacity.fillMode = kCAFillModeForwards;
    
    CAAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"
                                                          function:CubicEaseOut
                                                         fromValue:0.9
                                                           toValue:1.0];
    scale.duration = 0.5;
    scale.removedOnCompletion = NO;
    scale.fillMode = kCAFillModeForwards;
    
    
    NSMutableArray* visibleTiles = [[NSMutableArray alloc] init];
    NSMutableArray* invisibleTiles = [[NSMutableArray alloc] init];
    for (RSTile* view in allTiles) {
        if (CGRectIntersectsRect(self.bounds, view.frame)) {
            [visibleTiles addObject:view];
        } else {
            [invisibleTiles addObject:view];
        }
    }
    
    for (RSTile* view in invisibleTiles) {
        [view.layer setOpacity:0];
    }

    
    for (RSTile* view in visibleTiles) {
        [view.layer setOpacity:0];
        [view setHidden:NO];
        
        float layerX = -(view.tileX-CGRectGetMidX(self.bounds))/view.frame.size.width;
        float layerY = -(view.tileY-CGRectGetMidY(self.bounds))/view.frame.size.height;
        
        float delay = (((int)[visibleTiles count]-1) - (int)[visibleTiles indexOfObject:view]) * 0.008;
        
        view.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        view.layer.anchorPoint = CGPointMake(layerX, layerY);
        
        scale.beginTime = CACurrentMediaTime()+delay;
        opacity.beginTime = CACurrentMediaTime()+delay;

        
        //[view addAnimation:opacity forKey:@"opacity"];
        
        [view.layer addAnimation:scale forKey:@"scale"];
        [view.layer addAnimation:opacity forKey:@"opacity"];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(([visibleTiles count] * 0.01)+0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (RSTile* view in visibleTiles) {
            [view.layer setOpacity:1];
            //[view.layer removeAllAnimations];
        }
    });
}

-(float)getTransitionDelayForItemAtIndex:(int)itemIndex forBaseItem:(int)baseItemIndex forItems:(NSArray*)items {
    int baseIndex = abs(baseItemIndex-itemIndex);
    
    
    int maxIndex = MAX((int)[items count]-(baseItemIndex+1), baseItemIndex);
    int calculatedIndex = maxIndex-baseIndex;
    
    float delay = calculatedIndex*0.02;
    return delay;
}

+ (id)sharedInstance
{
    // 1
    static RSStartScrollView *_sharedInstance = nil;
    
    // 2
    static dispatch_once_t oncePredicate;
    
    // 3
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[RSStartScrollView alloc] init];
    });
    return _sharedInstance;
}

@end
