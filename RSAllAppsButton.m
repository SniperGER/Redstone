//
//  RSAllAppsButton.m
//  Threshold
//
//  Created by Janik Schmidt on 30.07.16.
//  Copyright © 2016 FESTIVAL Development. All rights reserved.
//

#import "Headers.h"

@implementation RSAllAppsButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    // Arrow
    allAppsArrow = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-30, 0, 30, self.frame.size.height)];
    allAppsArrow.text = @"\uE0AB";
    allAppsArrow.font = [UIFont fontWithName:@"SegoeMDL2Assets" size:24];
    allAppsArrow.textAlignment = NSTextAlignmentCenter;
    allAppsArrow.textColor = [UIColor whiteColor];
    
    [self addSubview:allAppsArrow];
    
    // Text
    allAppsText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width-40, self.frame.size.height)];
    allAppsText.text = @"All apps";
    allAppsText.font = [UIFont fontWithName:@"SegoeUI" size:18];
    allAppsText.textAlignment = NSTextAlignmentRight;
    allAppsText.textColor = [UIColor whiteColor];
    
    [self addSubview:allAppsText];
    
    return self;
}

@end
