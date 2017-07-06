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

- (void)addActionWithTitle:(NSString*)title target:(nonnull id)target action:(nonnull SEL)action {
	RSTiltView* actionView = [[RSTiltView alloc] initWithFrame:CGRectMake(2, (actions.count * 66) + 14, self.frame.size.width - 4, 66)];
	[actionView.titleLabel setFont:[UIFont fontWithName:@"SegoeUI" size:18]];
	[actionView.titleLabel setTextColor:[RSAesthetics colorsForCurrentTheme][@"ForegroundColor"]];
	[actionView.titleLabel setTextAlignment:NSTextAlignmentLeft];
	[actionView.titleLabel setText:title];
	[actionView.titleLabel setFrame:CGRectMake(12, 0, actionView.frame.size.width - 24, actionView.frame.size.height)];
	
	[actions addObject:actionView];
	[self addSubview:actionView];
	[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, (actions.count * 66) + 28)];
}

- (void)appearAtPosition:(CGPoint)position {
	
}

@end
