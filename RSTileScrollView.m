//
//  RSTileScrollView.m
//  
//
//  Created by Janik Schmidt on 06.08.16.
//
//

#import "Headers.h"
#include <notify.h>

@implementation RSTileScrollView

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    [self setContentInset:UIEdgeInsetsMake(24,0,4,0)];
    [self setShowsVerticalScrollIndicator:NO];
    allTiles = [[NSMutableArray alloc] init];
    
    NSArray* tiles = [RSTileDelegate getTileList];
    [self createTiles:tiles];

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), //center
                                    (void*)self, // observer
                                    onPreferencesChanged, // callback
                                    CFSTR("ml.festival.redstone-PreferencesChanged"), // event name
                                    NULL, // object
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    
    return self;
}

static void onPreferencesChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    [(id)observer updateTileColor];
}

-(void)updateTileColor {
    [allTiles makeObjectsPerformSelector:@selector(updateTileColor)];
}

-(void)createTiles:(NSArray*)tiles {
    float tileGridSize = (self.bounds.size.width/6);
    NSLog(@"[Redstone] %f", tileGridSize);
    
    int row = 0;
    float lastTileSize = 0;
    
    for (int i=0; i<[tiles count]; i++) {
        NSDictionary* tileInfo = [tiles objectAtIndex:i];
        
        float columnPos = [[tileInfo objectForKey:@"column"] intValue] * tileGridSize;
        float rowPos = [[tileInfo objectForKey:@"row"] intValue] * tileGridSize;
        
        NSDictionary* options = @{
                                  @"X": [NSNumber numberWithFloat:columnPos],
                                  @"Y": [NSNumber numberWithFloat:rowPos],
                                  @"bundleIdentifier": [tileInfo objectForKey:@"bundleIdentifier"],
                                  @"parentView": self
                                  };
        RSTileView* tile = [[RSTileView alloc] initWithTileSize:[[tileInfo objectForKey:@"size"] intValue] withOptions:options];
        tile.frame = CGRectIntegral(tile.frame);
        
        if ([[tileInfo objectForKey:@"row"] intValue] > row) {
            row = [[tileInfo objectForKey:@"row"] intValue];
            lastTileSize = tile.frame.size.height;
        }
        
        [allTiles addObject:tile];

        [self addSubview:tile];
    }
    
    RSAllAppsButton* allAppsButton = [[RSAllAppsButton alloc] initWithFrame:CGRectMake(0, (row)*tileGridSize+lastTileSize, [self frame].size.width, tileGridSize)];
    [allAppsButton addTarget:self action:@selector(moveRootScrollViewToAppList) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:allAppsButton];
    
    //[self setContentSize:CGSizeMake(self.frame.size.width, (row*tileGridSize) + lastTileSize)];
    [self setContentSize:CGSizeMake(self.frame.size.width, (row)*tileGridSize + lastTileSize + allAppsButton.frame.size.height)];
}

-(void)moveRootScrollViewToAppList {
    [self.parentRootScrollView setContentOffset:CGPointMake([[UIScreen mainScreen] bounds].size.width, 0) animated:YES];
}

-(void)tileEntryAnimation {
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
    for (RSTileView* view in allTiles) {
        if (CGRectIntersectsRect(self.bounds, view.frame)) {
            [visibleTiles addObject:view];
        } else {
            [invisibleTiles addObject:view];
        }
    }
    
    for (RSTileView* view in invisibleTiles) {
        [view.layer setOpacity:1];
    }
    
    for (RSTileView* view in visibleTiles) {
        [view.layer setOpacity:0];
        [view setHidden:NO];
        
        float layerX = -(view.tileX-CGRectGetMidX(self.bounds))/view.frame.size.width;
        float layerY = -(view.tileY-CGRectGetMidY(self.bounds))/view.frame.size.height;
        
        float delay = (((int)[visibleTiles count]-1) - (int)[visibleTiles indexOfObject:view]) * 0.008;
        
        view.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        view.layer.anchorPoint = CGPointMake(layerX, layerY);
        
        scale.beginTime = CACurrentMediaTime()+delay;
        opacity.beginTime = CACurrentMediaTime()+delay;
        
        [view.layer addAnimation:scale forKey:@"scale"];
        [view.layer addAnimation:opacity forKey:@"opacity"];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(([visibleTiles count] * 0.01)+0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (RSTileView* view in visibleTiles) {
            [view.layer setOpacity:1];
        }
    });
}
-(void)tileExitAnimation:(RSTileView*)sender {
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
    for (RSTileView* view in allTiles) {
        if (CGRectIntersectsRect(self.bounds, view.frame)) {
            [visibleTiles addObject:view];
        } else {
            [invisibleTiles addObject:view];
        }
    }
    
    for (RSTileView* view in invisibleTiles) {
        [view setHidden:YES];
    }
    
    int baseItemIndex = (int)[visibleTiles indexOfObject:sender];
    
    for (RSTileView* view in visibleTiles) {
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
        
        [view.layer addAnimation:scale forKey:@"scale"];
        [view.layer addAnimation:opacity forKey:@"opacity"];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(([visibleTiles count]*0.02) + 0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (RSTileView* view in visibleTiles) {
            [view.layer setOpacity:0];
        }
        
        [(RSRootScrollView*)self.parentRootScrollView showLaunchImage:sender.applicationIdentifier];
    });
}

-(void)resetTileVisibility {
    for (RSTileView* view in [self subviews]) {
        [view setHidden:NO];
        [view.layer setOpacity:1];
        [view.layer removeAllAnimations];
    }
}

-(float)getTransitionDelayForItemAtIndex:(int)itemIndex forBaseItem:(int)baseItemIndex forItems:(NSArray*)items {
    int baseIndex = abs(baseItemIndex-itemIndex);
    
    
    int maxIndex = MAX((int)[items count]-(baseItemIndex+1), baseItemIndex);
    int calculatedIndex = maxIndex-baseIndex;
    
    float delay = calculatedIndex*0.02;
    return delay;
}

@end
