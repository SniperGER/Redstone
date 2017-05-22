#import "../Redstone.h"

@implementation RSModalAlert

- (id)modalAlertWithTitle:(NSString*)title message:(NSString*)message {
	self = [super init];
	
	if (self) {
		actionButtons = [NSMutableArray new];
		actionHandlers = [NSMutableArray new];
		
		[self setFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
		[self setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.8]];
		
		alertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 0)];
		[alertView setBackgroundColor:[UIColor colorWithWhite:0.23 alpha:1.0]];
		[alertView.layer setBorderWidth:2.0];
		[alertView.layer setBorderColor:[RSAesthetics accentColor].CGColor];
		[self addSubview:alertView];
		
		alertTitle = [[UILabel alloc] initWithFrame:CGRectMake(38, 38, screenWidth-76, 38)];
		[alertTitle setFont:[UIFont fontWithName:@"SegoeUI" size:26]];
		[alertTitle setText:title];
		[alertTitle sizeToFit];
		[alertTitle setTextColor:[UIColor whiteColor]];
		[alertView addSubview:alertTitle];
		
		alertMessage = [[UILabel alloc] initWithFrame:CGRectMake(38, alertTitle.frame.origin.y + alertTitle.frame.size.height + 5, screenWidth-76, 164)];
		[alertMessage setFont:[UIFont fontWithName:@"SegoeUI" size:20]];
		[alertMessage setLineBreakMode:NSLineBreakByWordWrapping];
		[alertMessage setNumberOfLines:0];
		[alertMessage setText:message];
		[alertMessage sizeToFit];
		[alertMessage setTextColor:[UIColor whiteColor]];
		[alertView addSubview:alertMessage];
		
		CGFloat alertHeight = alertMessage.frame.origin.y + alertMessage.frame.size.height + 38;
		[alertView setFrame:CGRectMake(0, screenHeight/2 - alertHeight/2, screenWidth, alertHeight)];
	}
	
	return self;
}

- (void)addActionWithTitle:(NSString *)title handler:(void (^)(void))callback {
	RSTiltView* button = [[RSTiltView alloc] initWithFrame:CGRectMake(38, 0, ((screenWidth-76)-6) / 2, 38)];
	[button setBackgroundColor:[UIColor colorWithWhite:0.38 alpha:1.0]];
	
	if ([actionButtons count] % 2 == 0) {
		if ([actionButtons count] > 0) {
			UIView* lastButton = [actionButtons lastObject];
			[button setFrame:CGRectMake(38, lastButton.frame.origin.y + lastButton.frame.size.height+6, ((screenWidth-76)-6) / 2, 38)];
		} else {
			[button setFrame:CGRectMake(38, alertMessage.frame.origin.y + alertMessage.frame.size.height + 30, ((screenWidth-76)-6) / 2, 38)];
		}
	} else {
		UIView* lastButton = [actionButtons lastObject];
		[button setFrame:CGRectMake(self.frame.size.width - button.frame.size.width - 38, lastButton.frame.origin.y, ((screenWidth-76)-6) / 2, 38)];
	}
	
	UILabel* buttonLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, button.frame.size.width, button.frame.size.height)];
	[buttonLabel setText:title];
	[buttonLabel setFont:[UIFont fontWithName:@"SegoeUI" size:17]];
	[buttonLabel setTextColor:[UIColor whiteColor]];
	[buttonLabel setTextAlignment:NSTextAlignmentCenter];
	[button addSubview:buttonLabel];
	
	if (callback != nil) {
		UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:[callback copy] action:@selector(invoke)];
		[button addGestureRecognizer:tap];
	}
	
	[alertView addSubview:button];
	[actionButtons addObject:button];
	
	CGFloat alertHeight = button.frame.origin.y + button.frame.size.height + 38;
	[alertView setFrame:CGRectMake(0, screenHeight/2 - alertHeight/2, screenWidth, alertHeight)];
}

- (void)show {
	for (UIView* subview in [[[RSCore sharedInstance] window] subviews]) {
		if ([subview isKindOfClass:NSClassFromString(@"RSModalAlert")]) {
			return;
		}
	}
	
	[[[RSCore sharedInstance] window] addSubview:self];
	[self setHidden:NO];
	
	CAAnimation* scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"
														  function:CubicEaseOut
														 fromValue:1.35
														   toValue:1.0];
	[scale setDuration:0.25];
	[scale setRemovedOnCompletion:NO];
	[scale setFillMode:kCAFillModeForwards];
	
	CAAnimation* opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
															function:CubicEaseOut
														   fromValue:0.0
															 toValue:1.0];
	[opacity setDuration:0.2];
	[opacity setRemovedOnCompletion:NO];
	[opacity setFillMode:kCAFillModeForwards];
	
	[alertView.layer addAnimation:scale forKey:@"scale"];
	[alertView.layer addAnimation:opacity forKey:@"opacity"];
}

- (void)hide {
	// ANIMATION
	NSLog(@"[Redstone] hiding");
	
	CAAnimation* scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"
														  function:CubicEaseOut
														 fromValue:1.0
														   toValue:1.35];
	[scale setDuration:0.1];
	[scale setRemovedOnCompletion:NO];
	[scale setFillMode:kCAFillModeForwards];
	
	CAAnimation* opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
															function:CubicEaseOut
														   fromValue:1.0
															 toValue:0.0];
	[opacity setDuration:0.08];
	[opacity setRemovedOnCompletion:NO];
	[opacity setFillMode:kCAFillModeForwards];
	
	[alertView.layer addAnimation:scale forKey:@"scale"];
	[alertView.layer addAnimation:opacity forKey:@"opacity"];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self setHidden:YES];
		[self removeFromSuperview];
	});
}

@end
