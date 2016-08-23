//
//  RSAppListSection.m
//  Redstone
//
//  Created by Janik Schmidt on 02.08.16.
//  Copyright © 2016 FESTIVAL Development. All rights reserved.
//

#import "Headers.h"

@implementation RSAppListSection

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    _sectionTitle = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, self.frame.size.width-4, self.frame.size.height)];
    _sectionTitle.font = [UIFont fontWithName:@"SegoeUI-Light" size:30];
    
    _sectionTitle.textColor = [UIColor whiteColor];
    [self addSubview:_sectionTitle];
    
    return self;
}

@end
