#import "../Redstone.h"

@implementation RSJumpList

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		[self setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.8]];
		
		CGFloat deviceOffsetWidth = ([UIScreen mainScreen].bounds.size.width - 320) / 2;
		alphabetScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		[alphabetScrollView setContentInset:UIEdgeInsetsMake(88, deviceOffsetWidth, 88, deviceOffsetWidth)];
		[self addSubview:alphabetScrollView];
		
		NSString* alphabet = @"#ABCDEFGHIJKLMNOPQRSTUVWXYZ@";
		
		int sectionTag = 0;
		for (int i=0; i<7; i++) {
			for (int j=0; j<4; j++) {
				int index = ((i * 4) + (j + 1)) - 1;
				NSString* letter = [[alphabet substringWithRange:NSMakeRange(index, 1)] uppercaseString];
				
				RSTiltView* jumpListLetter = [[RSTiltView alloc] initWithFrame:CGRectMake(j*80, i*80, 80, 80)];
				[jumpListLetter setHighlightEnabled:YES];
				[alphabetScrollView addSubview:jumpListLetter];
				
				UILabel* jumpListLetterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
				[jumpListLetterLabel setTextColor:[UIColor whiteColor]];
				[jumpListLetterLabel setTextAlignment:NSTextAlignmentCenter];
				[jumpListLetterLabel setFont:[UIFont fontWithName:@"SegoeUI-Light" size:48]];
				
				if ([[RSAppListController sharedInstance] sectionWithLetter:letter] != nil) {
					UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpToLetter:)];
					[tapGestureRecognizer setCancelsTouchesInView:NO];
					[jumpListLetter addGestureRecognizer:tapGestureRecognizer];
				} else {
					[jumpListLetter setUserInteractionEnabled:NO];
					[jumpListLetterLabel setTextColor:[UIColor colorWithWhite:0.3 alpha:1.0]];
				}
				
				if ([letter isEqualToString:@"@"]) {
					letter = @"\uE12B";
					[jumpListLetterLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:30]];
				}
				[jumpListLetterLabel setText:letter];
				
				[jumpListLetter setTag:sectionTag];
				sectionTag++;
				
				[jumpListLetter addSubview:jumpListLetterLabel];
				[alphabetScrollView addSubview:jumpListLetter];
			}
		}
		
		[alphabetScrollView setUserInteractionEnabled:NO];
		[self setHidden:YES];
	}
	
	return self;
}

- (void)animateIn {
	self.isOpen = YES;
	[self setHidden:NO];
	[[[RSCore sharedInstance] rootScrollView] setScrollEnabled:NO];
	
	CAAnimation* scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"
														  function:CubicEaseOut
														 fromValue:1.2
														   toValue:1.0];
	[scale setDuration:0.4];
	[scale setRemovedOnCompletion:NO];
	[scale setFillMode:kCAFillModeForwards];
	
	CAAnimation* opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
															function:CubicEaseOut
														   fromValue:0.0
															 toValue:1.0];
	[opacity setDuration:0.25];
	[opacity setRemovedOnCompletion:NO];
	[opacity setFillMode:kCAFillModeForwards];
	
	[self.layer addAnimation:scale forKey:@"scale"];
	[self.layer addAnimation:opacity forKey:@"opacity"];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[alphabetScrollView setUserInteractionEnabled:YES];
	});
}

- (void)animateOut {
	self.isOpen = NO;
	[alphabetScrollView setUserInteractionEnabled:NO];
	
	CAAnimation* scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"
														  function:CubicEaseOut
														 fromValue:1.0
														   toValue:1.2];
	[scale setDuration:0.2];
	[scale setRemovedOnCompletion:NO];
	[scale setFillMode:kCAFillModeForwards];
	
	CAAnimation* opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
															function:CubicEaseOut
														   fromValue:1.0
															 toValue:0.0];
	[opacity setDuration:0.25];
	[opacity setRemovedOnCompletion:NO];
	[opacity setFillMode:kCAFillModeForwards];
	
	[self.layer addAnimation:scale forKey:@"scale"];
	[self.layer addAnimation:opacity forKey:@"opacity"];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self setHidden:YES];
		[[[RSCore sharedInstance] rootScrollView] setScrollEnabled:YES];
	});
}

- (void)jumpToLetter:(UITapGestureRecognizer*)gestureRecognizer {
	NSString* alphabet = @"#ABCDEFGHIJKLMNOPQRSTUVWXYZ@";
	NSString* letter = [alphabet substringWithRange:NSMakeRange(gestureRecognizer.view.tag, 1)];
	
	[[RSAppListController sharedInstance] jumpToSectionWithLetter:letter];
	[self animateOut];
}

@end
