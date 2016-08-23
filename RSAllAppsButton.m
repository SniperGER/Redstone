//
//  RSAllAppsButton.m
//  
//
//  Created by Janik Schmidt on 09.08.16.
//
//

#import "RSAllAppsButton.h"

@implementation RSAllAppsButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
       UILabel*  allAppsArrow = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-30, 0, 30, self.frame.size.height)];
        allAppsArrow.text = @"\uE0AB";
        allAppsArrow.font = [UIFont fontWithName:@"SegoeMDL2Assets" size:24];
        allAppsArrow.textAlignment = NSTextAlignmentCenter;
        allAppsArrow.textColor = [UIColor whiteColor];
        [self addSubview:allAppsArrow];
        
        self.titleLabel.frame = CGRectMake(0, 0, self.frame.size.width-40, self.frame.size.height);
        self.titleLabel.text = @"All apps";
        self.titleLabel.font = [UIFont fontWithName:@"SegoeUI" size:18];
        self.titleLabel.textAlignment = NSTextAlignmentRight;
        self.titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.titleLabel];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleLabel.hidden = NO;
}

- (void)setHighlighted:(BOOL)highlighted {
    if (highlighted) {
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    } else {
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
    }
}

@end
