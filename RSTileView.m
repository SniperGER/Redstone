//
//  RSTileView.m
//  
//
//  Created by Janik Schmidt on 06.08.16.
//
//

#import "Headers.h"

@implementation RSTileView

-(id)initWithTileSize:(int)tileSize withOptions:(NSDictionary*)options {
    float x = [[options objectForKey:@"X"] floatValue];
    float y = [[options objectForKey:@"Y"] floatValue];
    
    self.parentView = [options objectForKey:@"parentView"];
    self.tileSize = tileSize;
    self.applicationIdentifier = [options objectForKey:@"bundleIdentifier"];
    
    self = [super initWithFrame:[self makeTileSize:x forY:y]];
    
    float factor = [[UIScreen mainScreen] bounds].size.width/414;
    
    // Colored Inside
    self.tileInnerView = [[UIView alloc] initWithFrame:CGRectIntegral(CGRectMake(2, 2, [self bounds].size.width-4, [self bounds].size.height-4))];
    
    //self.tiltButton = [[RSTiltButton alloc] initWithFrame:CGRectIntegral(CGRectMake(0, 0, self.tileInnerView.frame.size.width, self.tileInnerView.frame.size.height))];
    [self.tileInnerView addSubview:self.tiltButton];
    [self.tileInnerView setBackgroundColor:[RSTileDelegate getIndividualTileColor:self.applicationIdentifier]];
    
    // - Set Alpha to Global Transparency setting
    if ([[[RSTileDelegate getTileInfo:self.applicationIdentifier] objectForKey:@"usesGlobalAccentColor"] boolValue]) {
        [self.tileInnerView setBackgroundColor:[self.tileInnerView.backgroundColor colorWithAlphaComponent:[RSTileDelegate getTileOpacity]]];
    }
    [self addSubview:self.tileInnerView];
    
    // Application Label
    if (tileSize > 1) {
        self.appLabel = [[UILabel alloc] initWithFrame:CGRectIntegral(CGRectMake(0,0, self.tileInnerView.frame.size.width-20, 20))];
        self.appLabel.text = [NSString stringWithFormat:@"%@", [RSTileDelegate getTileDisplayName:[options objectForKey:@"bundleIdentifier"]]];
        self.appLabel.center = CGPointMake(12*factor, self.tileInnerView.frame.size.height-(5*factor));
        self.appLabel.layer.anchorPoint = CGPointMake(0, 1);
        self.appLabel.font = [UIFont fontWithName:@"SegoeUI" size:14];
        self.appLabel.textColor = [UIColor whiteColor];
        [self.tileInnerView addSubview:self.appLabel];
    }
    [self.appLabel setTransform:CGAffineTransformMakeScale(factor, factor)];
    
    // Application Image
    if (tileSize < 2) {
        UIImage* tileImageData = [RSTileDelegate getTileImage:self.applicationIdentifier withSize:@"small"];
        self.tileImage = [[UIImageView alloc] initWithImage:tileImageData];
        [self.tileImage setFrame:CGRectMake(CGRectGetMidX(self.tileInnerView.bounds)-16, CGRectGetMidY(self.tileInnerView.bounds)-16, 32, 32)];
    } else {
        UIImage* tileImageData = [RSTileDelegate getTileImage:self.applicationIdentifier withSize:@"large"];
        self.tileImage = [[UIImageView alloc] initWithImage:tileImageData];
        [self.tileImage setFrame:CGRectMake(CGRectGetMidX(self.tileInnerView.bounds)-24, CGRectGetMidY(self.tileInnerView.bounds)-24, 48, 48)];
    }
    [self.tileInnerView addSubview:self.tileImage];
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(launchApp:)];
    [self addGestureRecognizer:singleFingerTap];
    
    return self;
}

-(void)updateTileColor {
    [self.tileInnerView setBackgroundColor:[RSTileDelegate getIndividualTileColor:self.applicationIdentifier]];
    if ([[[RSTileDelegate getTileInfo:self.applicationIdentifier] objectForKey:@"usesGlobalAccentColor"] boolValue]) {
        [self.tileInnerView setBackgroundColor:[self.tileInnerView.backgroundColor colorWithAlphaComponent:[RSTileDelegate getTileOpacity]]];
    }
}

-(CGRect)makeTileSize:(float)X forY:(float)Y {
    CGRect tileSizeRect;
    
    self.tileX = X;
    self.tileY = Y;
    
    switch (self.tileSize) {
        case 1: {
            CGFloat size = (([self.parentView frame].size.width)/6);
            tileSizeRect = CGRectMake(X, Y, size, size);
            break;
        }
        case 2: {
            CGFloat size = (([self.parentView frame].size.width)/6)*2;
            tileSizeRect = CGRectMake(X, Y, size, size);
            break;
        }
        case 3: {
            CGFloat height = (([self.parentView frame].size.width)/6)*2;
            CGFloat width = (height*2);
            
            tileSizeRect = CGRectMake(X, Y, width, height);
            break;
        }
        default:
            tileSizeRect = CGRectZero;
            break;
    }
    
    return tileSizeRect;
}

-(void)launchApp:(UITapGestureRecognizer *)recognizer {
    [self.parentView tileExitAnimation:self];
    [self.tiltButton resetTransform];
}

@end
