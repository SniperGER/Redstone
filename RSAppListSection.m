//
//  RSAppListSection.m
//  
//
//  Created by Janik Schmidt on 07.08.16.
//
//

#import "RSAppListSection.h"

@implementation RSAppListSection

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.sectionTitle = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, self.frame.size.width-4, self.frame.size.height)];
    self.sectionTitle.font = [UIFont fontWithName:@"SegoeUI-Light" size:30];
    self.sectionTitle.textColor = [UIColor whiteColor];
    [self addSubview:self.sectionTitle];
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openJumpList:)];
    [self addGestureRecognizer:singleFingerTap];
    
    return self;
}

-(void)openJumpList:(UITapGestureRecognizer*) sender {
    [self.parentAppList.parentRootScrollView showJumpList];
}

@end
