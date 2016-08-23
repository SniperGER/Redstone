//
//  RSTileScrollView.h
//  
//
//  Created by Janik Schmidt on 06.08.16.
//
//

#import <UIKit/UIKit.h>
#import "RSTileDelegate.h"


@interface RSTileScrollView : UIScrollView {
    NSMutableArray* allTiles;
    id _parentRootScrollView;
}

@property (retain) id parentRootScrollView;

-(void)tileExitAnimation:(RSTileView*)sender;
-(void)tileEntryAnimation;
-(void)resetTileVisibility;

@end