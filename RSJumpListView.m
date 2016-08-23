#import "Headers.h"

@implementation RSJumpListView

-(id)initWithFrame:(CGRect)frame withAppList:(RSAppList*)appList {
    self = [super initWithFrame:frame];
    
    self.parentAppListView = appList;
    
    [self setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.8]];
    
    float deviceOffsetWidth = ([[UIScreen mainScreen] bounds].size.width-320)/2;
    self.contentInset = UIEdgeInsetsMake(88, deviceOffsetWidth, 88, deviceOffsetWidth);
    
    NSString *alphabet = @"#ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    
    sections = [[NSMutableDictionary alloc] init];
    for (int i=0; i<7; i++) {
        for (int j=0; j<4; j++) {
            int index =
            
            NSString* currentString = [alphabet substringWithRange:NSMakeRange(index, 1)];
            
            UIView* jumpListLetter = [[UIView alloc] initWithFrame:CGRectMake(j*80, i*80, 80, 80)];
            
            UILabel* jumpListLetterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
            
            
            if ([currentString isEqualToString:@""]) {
                jumpListLetterLabel.font = [UIFont fontWithName:@"SegoeMDL2Assets" size:30];
            } else {
                jumpListLetterLabel.font = [UIFont fontWithName:@"SegoeUI-Light" size:48];
            }
            
            jumpListLetterLabel.textColor = [UIColor colorWithWhite:0.3 alpha:1];
            jumpListLetterLabel.textAlignment = NSTextAlignmentCenter;
            jumpListLetterLabel.text = currentString;
            [jumpListLetter addSubview:jumpListLetterLabel];
            
            [sections setObject:jumpListLetter forKey:currentString];
            
            [jumpListLetter setUserInteractionEnabled:NO];
            UITapGestureRecognizer *singleFingerTap =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moveAppListToSection:)];
            [jumpListLetter addGestureRecognizer:singleFingerTap];
            
            [self addSubview:jumpListLetter];
        }
    }
    
    return self;
}

-(void)moveAppListToSection:(UITapGestureRecognizer*)sender {
    [self hide];
    [self.parentAppListView.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sender.view.tag] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

-(void)show {
    [self setHidden:NO];
    CAAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
                                                            function:CubicEaseOut
                                                           fromValue:0.0
                                                             toValue:1.0];
    opacity.duration = 0.25;
    opacity.removedOnCompletion = NO;
    opacity.fillMode = kCAFillModeForwards;
    
    CAAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"
                                                          function:CubicEaseOut
                                                         fromValue:1.2
                                                           toValue:1.0];
    scale.duration = 0.4;
    scale.removedOnCompletion = NO;
    scale.fillMode = kCAFillModeForwards;
    
    [self.layer addAnimation:opacity forKey:@"opacity"];
    [self.layer addAnimation:scale forKey:@"scale"];
}

-(void)hide {
    [self.layer removeAllAnimations];
    CAAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
                                                            function:CubicEaseOut
                                                           fromValue:1.0
                                                             toValue:0.0];
    opacity.duration = 0.25;
    opacity.removedOnCompletion = NO;
    opacity.fillMode = kCAFillModeForwards;
    
    CAAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"
                                                          function:CubicEaseOut
                                                         fromValue:1.0
                                                           toValue:1.2];
    scale.duration = 0.3;
    scale.removedOnCompletion = NO;
    scale.fillMode = kCAFillModeForwards;
    
    [self.layer addAnimation:opacity forKey:@"opacity"];
    [self.layer addAnimation:scale forKey:@"scale"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setHidden:YES];
    });
}

-(void)setCategoriesWithApps:(NSDictionary*)sectionsWithApps {
    NSString *alphabet = @"#ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    
    int sectionTag = 0;

    for (int i=0; i<28; i++) {
        NSString* letter = [alphabet substringWithRange:NSMakeRange(i, 1)];
    
        NSArray *apps = [sectionsWithApps objectForKey:letter];
        if ([apps count] > 0) {
            UIView* jumpListLetter = (UIView*)[sections objectForKey:letter];
            [jumpListLetter setUserInteractionEnabled:YES];
            jumpListLetter.tag = sectionTag;
            
            UILabel* jumpListLetterLabel = (UILabel*)[[jumpListLetter subviews] objectAtIndex:0];
            jumpListLetterLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
            
            sectionTag++;
        }
    }
}

@end
