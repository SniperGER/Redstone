//
//  RSAppListApp.m
//  
//
//  Created by Janik Schmidt on 07.08.16.
//
//

#import "Headers.h"

@implementation RSAppListApp

-(id)initWithFrame:(CGRect)frame withApp:(LSApplicationProxy*)app {
    self = [super initWithFrame:frame];
    
    self.bundleIdentifier = [app bundleIdentifier];
    
    _appTitle = [[UILabel alloc] initWithFrame:CGRectMake(64, 2, self.frame.size.width-54, 50)];
    _appTitle.text = app.localizedName;
    _appTitle.font = [UIFont fontWithName:@"SegoeUI" size:18];
    _appTitle.textColor = [UIColor whiteColor];
    [self addSubview:_appTitle];
    
    _appImageTile = [[UIView alloc] initWithFrame:CGRectMake(2, 2, 50, 50)];
    [_appImageTile setBackgroundColor:[RSTileDelegate getIndividualTileColor:self.bundleIdentifier]];
    [self addSubview:_appImageTile];
    
    _appImage = [[UIImageView alloc] initWithImage:[RSTileDelegate getTileImage:self.bundleIdentifier withSize:@"small"]];
    [_appImage setFrame:CGRectMake(9, 9, 32, 32)];
    [_appImageTile addSubview:_appImage];
    
    return self;
}

-(void)updateTileColor {
    [_appImageTile setBackgroundColor:[RSTileDelegate getIndividualTileColor:self.bundleIdentifier]];
}

-(void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    
    [_appImageTile setBackgroundColor:[RSTileDelegate getIndividualTileColor:self.bundleIdentifier]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (selected){
        [_appImageTile setBackgroundColor:[RSTileDelegate getIndividualTileColor:self.bundleIdentifier]];
    }
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted){
        [_appImageTile setBackgroundColor:[RSTileDelegate getIndividualTileColor:self.bundleIdentifier]];
    }
}

@end
