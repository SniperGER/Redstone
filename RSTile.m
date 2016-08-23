//
//  RSTile.m
//  Threshold
//
//  Created by Janik Schmidt on 30.07.16.
//  Copyright © 2016 FESTIVAL Development. All rights reserved.
//

#import "Headers.h"
#import "CAKeyframeAnimation+AHEasing.h"

@implementation RSTile

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

NSUserDefaults *defaults;

-(id)initWithTileSize:(int)_tileSize withOptions:(NSDictionary*)options {
    UIColor* actualTileColor = [self colorWithHexString:[defaults objectForKey:@"accentColor"]];
    
    parentView = [options objectForKey:@"parentView"];
    tileSize = _tileSize;
    self.applicationIdentifier = [options objectForKey:@"displayIdentifier"];
    
    float x = [[options objectForKey:@"X"] floatValue];
    float y = [[options objectForKey:@"Y"] floatValue];
    
    float factor = [[UIScreen mainScreen] bounds].size.width/414;
    
    self = [super initWithFrame:[self makeTileSize:x forY:y]];
    
    // Colored Inside
    UIView* tileInnerView = [[UIView alloc] initWithFrame:CGRectMake(2, 2, [self bounds].size.width-4, [self bounds].size.height-4)];
    [tileInnerView setBackgroundColor:[actualTileColor colorWithAlphaComponent:[defaults floatForKey:@"tileOpacity"]]];
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(launchApp:)];
    [self addGestureRecognizer:singleFingerTap];
    
    [self addSubview:tileInnerView];
    
    // Application Label
    if (tileSize > 1) {
        self.appLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, tileInnerView.frame.size.width-20, 20)];
        self.appLabel.text = [NSString stringWithFormat:@"%@", [self getAppTitleForIdentifier:[options objectForKey:@"displayIdentifier"]]];
        self.appLabel.center = CGPointMake(12*factor, tileInnerView.frame.size.height-(5*factor));
        self.appLabel.layer.anchorPoint = CGPointMake(0, 1);
        self.appLabel.font = [UIFont fontWithName:@"SegoeUI" size:14];
        self.appLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.appLabel];
    }
    [self.appLabel setTransform:CGAffineTransformMakeScale(factor, factor)];
    
    // Application Image
#if TARGET_IPHONE_SIMULATOR
    tileImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.applicationIdentifier]];
#else
    NSURL* tileImageDataURL = [NSURL URLWithString:[[NSString stringWithFormat:@"file:///private/var/mobile/Library/Redstone/Tiles/%@@2x.png", self.applicationIdentifier] stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet]];
    UIImage* tileImageData = [UIImage imageWithData:[NSData dataWithContentsOfURL:tileImageDataURL]];
    tileImage = [[UIImageView alloc] initWithImage:tileImageData];
#endif
    if (tileSize > 1) {
        [tileImage setFrame:CGRectMake(CGRectGetMidX(tileInnerView.bounds) - 32, CGRectGetMidY(tileInnerView.bounds) - 32, 64, 64)];
    } else {
        [tileImage setFrame:CGRectMake(CGRectGetMidX(tileInnerView.bounds) - 21, CGRectGetMidY(tileInnerView.bounds) - 21, 42, 42)];
    }
    //[tileImage setTransform:CGAffineTransformMakeScale([[UIScreen mainScreen] bounds].size.width/414, [[UIScreen mainScreen] bounds].size.width/414)];
    
    
    [tileInnerView addSubview:tileImage];
    
    //[self setCenter:CGPointMake([[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.height/2)];
    //NSLog(@"%f", CGRectGetMidX(parentView.bounds));
    
    float layerX = -(self.tileX-CGRectGetMidX(parentView.bounds))/self.frame.size.width;
    float layerY = -(self.tileY-CGRectGetMidY(parentView.bounds))/self.frame.size.height;
    
    self.center = CGPointMake(CGRectGetMidX(parentView.bounds), CGRectGetMidY(parentView.bounds));
    self.layer.anchorPoint = CGPointMake(layerX, layerY);
    
    self.layer.opacity = 0;
    
    return self;
}

-(CGRect)makeTileSize:(float)X forY:(float)Y {
    CGRect tileSizeRect;
    
    self.tileX = X;
    self.tileY = Y;
    
    switch (tileSize) {
        case 1: {
            CGFloat size = (([parentView bounds].size.width)/6);
            tileSizeRect = CGRectMake(X, Y, size, size);
            break;
        }
        case 2: {
            CGFloat size = (([parentView bounds].size.width)/6)*2;
            tileSizeRect = CGRectMake(X, Y, size, size);
            break;
        }
        case 3: {
            CGFloat height = (([parentView bounds].size.width)/6)*2;
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

-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

-(NSString*)getAppTitleForIdentifier:(NSString*)appIdentifier {
    Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
    NSObject* workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
    for (LSApplicationProxy* apps in [workspace performSelector:@selector(allApplications)]) {
        if ([apps.applicationIdentifier isEqualToString:appIdentifier]) {
            return apps.localizedName;
        }
    }
    
    return nil;
}

-(void)launchApp:(UITapGestureRecognizer *)recognizer {
    NSLog(@"Launching %@",self.applicationIdentifier);
    
    float layerX = -(self.tileX-CGRectGetMidX(parentView.bounds))/self.frame.size.width;
    float layerY = -(self.tileY-CGRectGetMidY(parentView.bounds))/self.frame.size.height;
    
    self.center = CGPointMake(CGRectGetMidX(parentView.bounds), CGRectGetMidY(parentView.bounds));
    self.layer.anchorPoint = CGPointMake(layerX, layerY);
    
    [parentView triggerAppLaunch:self.applicationIdentifier sender:self];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
    });
    //[[UIApplication sharedApplication] launchApplicationWithIdentifier:applicationIdentifier suspended:NO];
}

@end
