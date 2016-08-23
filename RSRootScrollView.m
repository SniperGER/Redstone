//
//  RSRootScrollView.m
//  Redstone
//
//  Created by Janik Schmidt on 30.07.16.
//  Copyright © 2016 FESTIVAL Development. All rights reserved.
//

//#import "RSRootScrollView.h"
#import "Headers.h"
#import "UIFont+WDCustomLoader.h"
#import "CAKeyframeAnimation+AHEasing.h"

@implementation RSRootScrollView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

NSUserDefaults *defaults;

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.delegate = self;
    
#if !TARGET_IPHONE_SIMULATOR
    [UIFont registerFontFromURL:[NSURL fileURLWithPath:@"/var/mobile/Library/Redstone/Fonts/segoeui.ttf"]];
    [UIFont registerFontFromURL:[NSURL fileURLWithPath:@"/var/mobile/Library/Redstone/Fonts/segoeuil.ttf"]];
    [UIFont registerFontFromURL:[NSURL fileURLWithPath:@"/var/mobile/Library/Redstone/Fonts/segmdl2.ttf"]];
#endif
    
    // Background
    transparentBG = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width*3, [[UIScreen mainScreen] bounds].size.height)];
    [transparentBG setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
    [transparentBG setAlpha:0];
    [self addSubview:transparentBG];
    
    // Tiles
    [self setContentSize:CGSizeMake([[UIScreen mainScreen] bounds].size.width*2, [[UIScreen mainScreen] bounds].size.height)];
    [self setPagingEnabled:YES];
    [self setShowsHorizontalScrollIndicator:NO];
    
    _startScrollView = [[RSStartScrollView alloc] initWithFrame:CGRectMake(2, 0, [[UIScreen mainScreen] bounds].size.width-4, [[UIScreen mainScreen] bounds].size.height)];
    _startScrollView.parentRootScrollView = self;
    [self addSubview:_startScrollView];
    
    // App List
    appListScrollView = [[RSAppListTable alloc] init];
    appListScrollView.parentRootScrollView = self;
    [self addSubview:appListScrollView.tableView];
    
    // Application Launch image
    launchBG = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    UIColor* actualTileColor = [self colorWithHexString:[defaults objectForKey:@"accentColor"]];
    launchBG.backgroundColor = actualTileColor;
    launchBG.hidden = YES;
    [self addSubview: launchBG];
    
    return self;
}

-(void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat width = sender.frame.size.width;
    CGFloat page = (sender.contentOffset.x  / width);
    
    launchBG.frame = CGRectMake(sender.contentOffset.x, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    
    [transparentBG setAlpha:page];
    
}

-(void)showLaunchImage:(NSString*)bundleIdentifier {
    CAAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
                                                            function:CubicEaseOut
                                                           fromValue:0.0
                                                             toValue:1.0];
    opacity.duration = 0.4;
    opacity.removedOnCompletion = NO;
    opacity.fillMode = kCAFillModeForwards;
    
    CAAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"
                                                          function:CubicEaseOut
                                                         fromValue:0.8
                                                           toValue:1.0];
    scale.duration = 0.5;
    scale.removedOnCompletion = NO;
    scale.fillMode = kCAFillModeForwards;
    
    [launchBG setHidden:NO];
    [launchBG.layer addAnimation:scale forKey:@"scale"];
    [launchBG.layer addAnimation:opacity forKey:@"opacity"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        id app = [[objc_getClass("SBApplicationController") sharedInstance] applicationWithBundleIdentifier:bundleIdentifier];
        [app setFlag:1 forActivationSetting:1];
        [[objc_getClass("SBUIController") sharedInstance] activateApplication:app];
    });
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

@end
