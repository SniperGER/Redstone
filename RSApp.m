//
//  RSApp.m
//  Redstone
//
//  Created by Janik Schmidt on 02.08.16.
//  Copyright © 2016 FESTIVAL Development. All rights reserved.
//

#import "Headers.h"

@implementation RSApp

NSUserDefaults *defaults;

-(id)initWithFrame:(CGRect)frame withApp:(LSApplicationProxy*)app {
    self = [super initWithFrame:frame];
    [self setClipsToBounds:YES];
    
    UIColor* actualTileColor = [self colorWithHexString:[defaults objectForKey:@"accentColor"]];
    
    self.appIdentifier = [app bundleIdentifier];
    
    _appTitle = [[UILabel alloc] initWithFrame:CGRectMake(64, 2, self.frame.size.width-54, 50)];
    _appTitle.text = app.localizedName;
    _appTitle.font = [UIFont fontWithName:@"SegoeUI" size:18];
    _appTitle.textColor = [UIColor whiteColor];
    [self addSubview:_appTitle];
    
    _appImageTile = [[UIView alloc] initWithFrame:CGRectMake(2, 2, 50, 50)];
    [_appImageTile setBackgroundColor:actualTileColor];
    [self addSubview:_appImageTile];
    
#if TARGET_IPHONE_SIMULATOR
    _appImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.appIdentifier]];
#else
    NSURL* tileImageDataURL = [NSURL URLWithString:[[NSString stringWithFormat:@"file:///private/var/mobile/Library/Redstone/Tiles/%@@2x.png", self.appIdentifier] stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet]];
    UIImage* tileImageData = [UIImage imageWithData:[NSData dataWithContentsOfURL:tileImageDataURL]];
    _appImage = [[UIImageView alloc] initWithImage:tileImageData];
#endif
    [_appImage setFrame:CGRectMake(4, 4, 42, 42)];
    [_appImageTile addSubview:_appImage];
    
    [self.layer setAnchorPoint:CGPointMake(0,0)];
    
    return self;
}

- (UIEdgeInsets)layoutMargins {
    return UIEdgeInsetsZero;
}

-(void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    
    UIColor* actualTileColor = [self colorWithHexString:[defaults objectForKey:@"accentColor"]];
    [_appImageTile setBackgroundColor:actualTileColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (selected){
        UIColor* actualTileColor = [self colorWithHexString:[defaults objectForKey:@"accentColor"]];
        [_appImageTile setBackgroundColor:actualTileColor];
    }
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted){
        UIColor* actualTileColor = [self colorWithHexString:[defaults objectForKey:@"accentColor"]];
        [_appImageTile setBackgroundColor:actualTileColor];
    }
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
