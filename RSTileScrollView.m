#import "RSTileScrollView.h"
#import "RSTile.h"
#import "RSRootScrollView.h"

@implementation RSTileScrollView

-(id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	[self setContentInset:UIEdgeInsetsMake(24,0,4,0)];
	[self setShowsVerticalScrollIndicator:NO];
	[self setDelaysContentTouches:NO];
	[self setClipsToBounds:NO];

	allTiles = [[NSMutableArray alloc] init];
	pinnedBundleIdentifiers = [[NSMutableArray alloc] init];

	snapPositions = [[NSMutableDictionary alloc] init];
	for (int i=0; i<10; i++) {
		NSMutableArray* objectArray = [[NSMutableArray alloc] init];
		for (int j=0; j<6; j++) {
			[objectArray addObject:[NSNull null]];
		}
		[snapPositions setObject:objectArray forKey:[NSString stringWithFormat:@"%d", i]];
	}

	NSArray* savedTiles = [RSTileDelegate getTileList];
	for (int i=0; i<[savedTiles count]; i++) {
		RSLog([savedTiles objectAtIndex:i]);
		[self displaySavedTile:[savedTiles objectAtIndex:i]];
	}

	[[NSNotificationCenter defaultCenter] addObserverForName:@"applicationPinned"
							object:nil
							 queue:[NSOperationQueue mainQueue]
						usingBlock:^(NSNotification *note){
		[self createTileWithBundleIdentifier:[note.userInfo objectForKey:@"bundleIdentifier"]];
	}];

	CGRect contentRect = CGRectZero;
	for (UIView *view in self.subviews) {
	    contentRect = CGRectUnion(contentRect, view.frame);
	}
	self.contentSize = contentRect.size;

	return self;
}

-(void)displaySavedTile:(NSDictionary*)savedTileInfo {
	if ([RSTileDelegate getTileDisplayName:[savedTileInfo objectForKey:@"bundleIdentifier"]] == nil) {
		return;
	}

	NSDictionary* options = @{
		@"X": [NSNumber numberWithInt:[[savedTileInfo objectForKey:@"column"] intValue]],
		@"Y": [NSNumber numberWithInt:[[savedTileInfo objectForKey:@"row"] intValue]],
		@"bundleIdentifier": [savedTileInfo objectForKey:@"bundleIdentifier"],
		@"parentView": self,
		@"tileSnapPositions": snapPositions
	};

	RSTile* savedTile = [[RSTile alloc] initWithTileSize:[[savedTileInfo objectForKey:@"size"] intValue] withOptions:options];
	[self addSubview:savedTile];

	[allTiles addObject:savedTile];
	[pinnedBundleIdentifiers addObject:[savedTileInfo objectForKey:@"bundleIdentifier"]];
}

-(void)createTileWithBundleIdentifier:(NSString*)bundleIdentifier {
	RSTile* testTile = [[RSTile alloc] init];
	CGPoint closestSnapPoint = [self getFirstAvailableSnapPositionForSize:2 withTile:testTile];

	NSDictionary* options = @{
		@"X": [NSNumber numberWithFloat:closestSnapPoint.x],
		@"Y": [NSNumber numberWithFloat:closestSnapPoint.y],
		@"bundleIdentifier": bundleIdentifier,
		@"parentView": self,
		@"tileSnapPositions": snapPositions
	};

	testTile = [[RSTile alloc] initWithTileSize:2 withOptions:options];
	[self addSubview:testTile];

	[allTiles addObject:testTile];
	[pinnedBundleIdentifiers addObject:bundleIdentifier];

	CGRect contentRect = CGRectZero;
	for (UIView *view in self.subviews) {
	    contentRect = CGRectUnion(contentRect, view.frame);
	}
	self.contentSize = contentRect.size;
}
-(void)unpinTile:(RSTile*)tile {
	for (NSValue* val in tile->activePositions) {
		CGPoint pos = val.CGPointValue;
		[[snapPositions objectForKey:[NSString stringWithFormat:@"%d", (int)pos.y]] setObject:[NSNull null] atIndex:pos.x];
	}
	[tile removeFromSuperview];

	CGRect contentRect = CGRectZero;
	for (UIView *view in self.subviews) {
	    contentRect = CGRectUnion(contentRect, view.frame);
	}
	self.contentSize = contentRect.size;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
	if ([view isKindOfClass:RSTiltView.class]) {
		return YES;
	}

	return [super touchesShouldCancelInContentView:view];
}

-(CGPoint)getFirstAvailableSnapPositionForSize:(NSInteger)size withTile:(RSTile*)tile {
	NSInteger width = 0, height = 0;
	switch (size) {
		case 1:
			width = 1;
			height = 1;
			break;
		case 2:
			width = 2;
			height = 2;
			break;
		case 3:
			width = 4;
			height = 2;
			break;
		default: break;
	}


	NSInteger x = 0, y = 0;
	BOOL snapIsFree = NO;
	for (int i=0; i<[snapPositions count]; i++) {
		if (snapIsFree) {
			break;
		}
		/*if ((i-1) + height >= [snapPositions count]) {
			NSMutableArray* objectArray = [[NSMutableArray alloc] init];
			for (int j=0; j<6; j++) {
				[objectArray addObject:[NSNull null]];
			}
			[snapPositions setObject:objectArray forKey:[NSString stringWithFormat:@"%d", ((i-1) + height)]];
		}*/

		for (int j=0; j<6; j++) {
		 	if ((j-1) + width < 6) {
		 		if ([[snapPositions objectForKey:[NSString stringWithFormat:@"%d", i]] objectAtIndex:j] == [NSNull null]) {
		 			if (size > 1) {
		 				for (int k=0; k<width; k++) {
		 					if ((j+k) < 6 && [[snapPositions objectForKey:[NSString stringWithFormat:@"%d", i]] objectAtIndex:j+k] == [NSNull null]) {
		 						snapIsFree = YES;
		 					} else {
		 						snapIsFree = NO;
		 					}
		 				}
		 				if (snapIsFree) {
		 					for (int k=0; k<height; k++) {
		 						for (int l=0; l<width; l++) {
		 							[[snapPositions objectForKey:[NSString stringWithFormat:@"%d", i+k]] setObject:tile atIndex:j+l];
		 						}
		 					}
		 					
		 					x = j; y = i;
		 					break;
		 				}
		 			} else {
		 				x = j; y = i;
		 			}
		 		}
		 	}
		}
	}

	return CGPointMake(x,y);
}

-(NSArray*)tilesInRow:(NSInteger)row {
	return [snapPositions objectForKey:[NSString stringWithFormat:@"%d", row]];
}

-(void)enterEditModeWithTile:(RSTile*)tile {
	isEditing = YES;
	self.parentRootScrollView.scrollEnabled = NO;

	self.transform = CGAffineTransformMakeScale(0.9, 0.9);
	[self.parentRootScrollView->transparentBG setAlpha:1.0];

	for (RSTile* _tile in allTiles) {
		_tile.layer.anchorPoint = CGPointMake(0.5,0.5);
		_tile.center = _tile->originalCenter;
		if (_tile != tile) {
			_tile.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1);
			_tile.alpha = 0.8;
			_tile.layer.zPosition = 0;
			[_tile exitEditMode];
		} else {
			_tile.layer.transform = CATransform3DMakeScale(1.1, 1.1, 1);
			_tile.alpha = 1.0;
			_tile.layer.zPosition = 1;
		}
	}
}

-(void)changeEditingTileFocus:(RSTile*)tile {
	for (RSTile* _tile in allTiles) {
		_tile.layer.anchorPoint = CGPointMake(0.5,0.5);
		_tile.center = _tile->originalCenter;
		if (_tile != tile) {
			_tile.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1);
			_tile.alpha = 0.8;
			_tile.layer.zPosition = 0;
			[_tile exitEditMode];
		} else {
			_tile.layer.transform = CATransform3DMakeScale(1.1, 1.1, 1);
			_tile.alpha = 1.0;
			_tile.layer.zPosition = 1;
		}
	}
}

-(void)exitEditMode {
	isEditing = NO;
	self.parentRootScrollView.scrollEnabled = YES;
	self.transform = CGAffineTransformMakeScale(1, 1);
	[self.parentRootScrollView->transparentBG setAlpha:0.0];

	for (RSTile* tile in allTiles) {
		[tile exitEditMode];
		tile.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1);
		tile.alpha = 1.0;
		tile.layer.zPosition = 0;
	}

	CGRect contentRect = CGRectZero;
	for (UIView *view in self.subviews) {
	    contentRect = CGRectUnion(contentRect, view.frame);
	}
	self.contentSize = contentRect.size;
}

-(void)moveTilesBeginningAtRow:(NSInteger)row withAmount:(NSInteger)amount fromTile:(RSTile*)tile {
	for (int i=[allTiles count]-1; i>=row; i--) {
		for (int j=0; j<6; j++) {
			//RSTile* tileInArray = [allTiles objectForKey]
		}
		//RSTile* tileInArray = [allTiles obj]
	}
}

-(void)resetTileVisibility {
    for (RSTile* view in [self subviews]) {
    	if ([view isKindOfClass:[RSTile class]]) {
    		[view updateTileColor];
    	}
        [view setHidden:NO];
        [view.layer setOpacity:1];
        [view.layer removeAllAnimations];
    }
}

-(void)prepareForEntryAnimation {
	for (RSTile* view in [self subviews]) {
		if ([view isKindOfClass:[RSTile class]]) {
    		[view updateTileColor];
    	}
        [view.layer setOpacity:0];
    }
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
    for (RSTile* view in allTiles) {
    	[view updateTileColor];
        if (CGRectIntersectsRect(self.bounds, view.frame)) {
            [visibleTiles addObject:view];
        } else {
            [invisibleTiles addObject:view];
        }
    }
    
    for (RSTile* view in invisibleTiles) {
        [view.layer setOpacity:1];
    }
    
    for (RSTile* view in visibleTiles) {
        [view.layer setOpacity:0];
        [view setHidden:NO];
        
        float layerX = -(view.tileX-CGRectGetMidX(self.bounds))/view.frame.size.width;
        float layerY = -(view.tileY-CGRectGetMidY(self.bounds))/view.frame.size.height;
        
        float delay = (((int)[visibleTiles count]-1) - (int)[visibleTiles indexOfObject:view]) * 0.01;
        
        view.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        view.layer.anchorPoint = CGPointMake(layerX, layerY);
        
        scale.beginTime = CACurrentMediaTime()+delay;
        opacity.beginTime = CACurrentMediaTime()+delay;
        
        [view.layer addAnimation:scale forKey:@"scale"];
        [view.layer addAnimation:opacity forKey:@"opacity"];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(([visibleTiles count] * 0.01)+0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (RSTile* view in visibleTiles) {
            [view.layer setOpacity:1];
            view.layer.anchorPoint = CGPointMake(0.5,0.5);
            view.center = view->originalCenter;
        }
    });
}

-(void)tileExitAnimation:(RSTile*)sender {
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
        [view setHidden:YES];
    }
    
    int baseItemIndex = (int)[visibleTiles indexOfObject:sender];
    
    for (RSTile* view in visibleTiles) {
    	[view.layer setShouldRasterize:YES];
		view.layer.rasterizationScale = [[UIScreen mainScreen] scale];
		view.layer.contentsScale = [[UIScreen mainScreen] scale];

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
        for (RSTile* view in visibleTiles) {
            [view.layer setOpacity:0];
        }
        
        [(RSRootScrollView*)self.parentRootScrollView showLaunchImage:sender.applicationIdentifier];
    });
}

-(float)getTransitionDelayForItemAtIndex:(int)itemIndex forBaseItem:(int)baseItemIndex forItems:(NSArray*)items {
    int baseIndex = abs(baseItemIndex-itemIndex);
    
    
    int maxIndex = MAX((int)[items count]-(baseItemIndex+1), baseItemIndex);
    int calculatedIndex = maxIndex-baseIndex;
    
    float delay = calculatedIndex*0.02;
    return delay;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {   
    if (!self.clipsToBounds && !self.hidden && self.alpha > 0) {
        for (UIView *subview in self.subviews.reverseObjectEnumerator) {
            CGPoint subPoint = [subview convertPoint:point fromView:self];
            UIView *result = [subview hitTest:subPoint withEvent:event];
            if (result != nil) {
                return result;
            }
        }
    }

    return self;
}

@end