#import "Redstone.h"
#import "RSJumpList.h"
#import "RSAppListController.h"
#import "RSTiltView.h"
#import "RSAesthetics.h"
#import "RSAppList.h"

@implementation RSJumpList

-(id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		[self setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.8]];
		
		float deviceOffsetWidth = ([[UIScreen mainScreen] bounds].size.width-320)/2;
		
		self->alphabetScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width,self.frame.size.height)];
		self->alphabetScrollView.contentInset = UIEdgeInsetsMake(88, deviceOffsetWidth, 88, deviceOffsetWidth);
		[self addSubview:self->alphabetScrollView];
		
		NSString* alphabet = [RSAesthetics localizedStringForKey:@"ALPHABET"];
		
		int sectionTag = 0;
		for (int i=0; i<7; i++) {
			for (int j=0; j<4; j++) {
				int index = ((i*4)+(j+1))-1;
				
				NSString* letter = [[alphabet substringWithRange:NSMakeRange(index,1)] uppercaseString];
				
				RSTiltView* jumpListLetter = [[RSTiltView alloc] initWithFrame:CGRectMake(j*80, i*80, 80, 80)];
				jumpListLetter.hasHighlight = YES;
				
				[jumpListLetter setTransformOptions:@{
					@"transformAngle": @10
				}];
				
				UILabel* jumpListLetterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,80,80)];
				[jumpListLetterLabel setTextColor:[UIColor whiteColor]];
				[jumpListLetterLabel setTextAlignment:NSTextAlignmentCenter];
				[jumpListLetterLabel setFont:[UIFont fontWithName:@"SegoeUI-Light" size:48]];
				
				if ([letter isEqualToString:@"@"]) {
					letter = @"\uE12B";
					[jumpListLetterLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:30]];
				}
				[jumpListLetterLabel setText:letter];
				
				if ([(RSAppList*)[[RSAppListController sharedInstance] appList] sectionWithLetter:letter] == nil) {
					jumpListLetter.userInteractionEnabled = NO;
					[jumpListLetterLabel setTextColor:[UIColor colorWithWhite:0.3 alpha:1.0]];
				} else {
					UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpToLetter:)];
					[tap setCancelsTouchesInView:NO];
					[jumpListLetter addGestureRecognizer:tap];
				}
				jumpListLetter.tag = sectionTag;
				sectionTag++;
				
				[jumpListLetter addSubview:jumpListLetterLabel];
				
				[self->alphabetScrollView addSubview:jumpListLetter];
			}
		}
		
		[self setHidden:YES];
	}
	
	return self;
}

-(void)animateIn {
	[self setHidden:NO];
	[[[Redstone sharedInstance] rootScrollView] setScrollEnabled:NO];
//	[self.rootScrollView setScrollEnabled:NO];
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

-(void)animateOut {
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
    scale.duration = 0.2;
    scale.removedOnCompletion = NO;
    scale.fillMode = kCAFillModeForwards;
    
    [self.layer addAnimation:opacity forKey:@"opacity"];
    [self.layer addAnimation:scale forKey:@"scale"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    	[[[Redstone sharedInstance] rootScrollView] setScrollEnabled:YES];
        [self setHidden:YES];
    });
}

-(void)jumpToLetter:(UITapGestureRecognizer*)sender {
	NSString* alphabet = [RSAesthetics localizedStringForKey:@"ALPHABET"];
	NSString* letter = [[alphabet substringWithRange:NSMakeRange(sender.view.tag,1)] uppercaseString];
	
	[[[RSAppListController sharedInstance] appList] jumpToSectionWithLetter:letter];
	
	[self animateOut];
}

@end