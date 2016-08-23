//
//  RSTileView.h
//  
//
//  Created by Janik Schmidt on 06.08.16.
//
//

#import <UIKit/UIKit.h>
#import "RSTileDelegate.h"
#import "Headers.h"

@interface RSTileView : UIView {
    int _tileSize;
    float _tileX;
    float _tileY;
    RSTileScrollView* _parentView;
    UILabel* _appLabel;
    NSString* _applicationIdentifier;
    UIView* _tileInnerView;
    RSTiltButton* _tiltButton;
    UIImageView* _tileImage;
}

@property (assign) int tileSize;
@property (assign) float tileX;
@property (assign) float tileY;
@property (retain) RSTileScrollView* parentView;
@property (retain) UILabel* appLabel;
@property (retain) NSString* applicationIdentifier;
@property (retain) UIView* tileInnerView;
@property (retain) RSTiltButton* tiltButton;
@property (retain) UIImageView* tileImage;

-(id)initWithTileSize:(int)tileSize withOptions:(NSDictionary*)options;
-(void)updateTileColor;

@end
