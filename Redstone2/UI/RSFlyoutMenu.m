#import "../Redstone.h"

@implementation RSFlyoutMenu

- (id)init {
	if (self = [super init]) {
		[self setFrame:CGRectMake(0, 0, MIN(screenWidth, 364), 28)];
		[self setBackgroundColor:[RSAesthetics colorsForCurrentTheme][@"BackgroundColor"]];
		[self.layer setBorderWidth:2];
		[self.layer setBorderColor:[[RSAesthetics colorsForCurrentTheme][@"BorderColor"] CGColor]];
		
		actions = [NSMutableArray new];
	}
	
	return self;
}

- (void)updateFlyoutSize {
	NSInteger visibleActions = 0;
	for (RSTiltView* action in actions) {
		if (![action isHidden]) {
			[action setFrame:CGRectMake(2, visibleActions * 66 + 14, self.frame.size.width-4, 66)];
			
			visibleActions++;
		}
	}
	
	[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, (visibleActions * 66) + 28)];
}

- (void)addActionWithTitle:(NSString*)title target:(id)target action:(SEL)action {
	RSTiltView* actionView = [[RSTiltView alloc] initWithFrame:CGRectMake(2, (actions.count * 66) + 14, self.frame.size.width - 4, 66)];
	[actionView setHighlightEnabled:YES];
	[actionView.titleLabel setFont:[UIFont fontWithName:@"SegoeUI" size:18]];
	[actionView.titleLabel setTextColor:[RSAesthetics colorsForCurrentTheme][@"ForegroundColor"]];
	[actionView.titleLabel setTextAlignment:NSTextAlignmentLeft];
	[actionView.titleLabel setText:title];
	[actionView.titleLabel setFrame:CGRectMake(12, 0, actionView.frame.size.width - 24, actionView.frame.size.height)];
	
	if (target != nil && action != nil) {
		UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
		[actionView addGestureRecognizer:tapGestureRecognizer];
	}
	
	[actions addObject:actionView];
	[self addSubview:actionView];
	[self updateFlyoutSize];
}

- (void)setActionHidden:(BOOL)hidden atIndex:(NSInteger)index {
	if (index >= 0 && index < actions.count) {
		[[actions objectAtIndex:index] setHidden:hidden];
	}
	
	[self updateFlyoutSize];
}

- (void)setActionDisabled:(BOOL)disabled atIndex:(NSInteger)index {
	if (index >= 0 && index < actions.count) {
		[[actions objectAtIndex:index] setAlpha:(disabled ? 0.4 : 1.0)];
		[[actions objectAtIndex:index] setUserInteractionEnabled:!disabled];
	}
}

- (void)appearAtPosition:(CGPoint)position {
	[self.layer removeAllAnimations];
	AudioServicesPlaySystemSound(1520);
	
	self.open = YES;
	
	if (position.x <= screenWidth / 3) {
		CGRect baseFrame = CGRectMake(0,
									  MAX(0, position.y - self.frame.size.height),
									  self.frame.size.width,
									  self.frame.size.height);
		[self setFrame:baseFrame];
	} else if (position.x > screenWidth/3 && position.x <= (screenWidth/3) * 2) {
		CGRect baseFrame = CGRectMake(screenWidth/2 - self.frame.size.width/2,
									  MAX(0, position.y - self.frame.size.height),
									  self.frame.size.width,
									  self.frame.size.height);
		[self setFrame:baseFrame];
	} else if (position.x > (screenWidth/3) * 2) {
		CGRect baseFrame = CGRectMake(screenWidth - self.frame.size.width,
									  MAX(0, position.y - self.frame.size.height),
									  self.frame.size.width,
									  self.frame.size.height);
		[self setFrame:baseFrame];
	}
	
	[[[RSHomeScreenController sharedInstance] window] addSubview:self];
	[self setHidden:NO];
	
	CAAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
															function:ExponentialEaseOut
														   fromValue:0.0
															 toValue:1.0];
	opacity.duration = 0.2;
	opacity.removedOnCompletion = NO;
	opacity.fillMode = kCAFillModeForwards;
	
	CAAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"
											 function:ExponentialEaseOut
											fromValue:50
											  toValue:0.0];
	
	scale.duration = 0.225;
	scale.removedOnCompletion = NO;
	scale.fillMode = kCAFillModeForwards;
	
	[self.layer addAnimation:opacity forKey:@"opacity"];
	[self.layer addAnimation:scale forKey:@"scale"];
}

- (void)disappear {
	self.open = NO;
	[self setHidden:YES];
}

@end
