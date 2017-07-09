#import "../Redstone.h"

@implementation RSAlertController

+ (id)alertControllerWithTitle:(NSString *)title message:(NSString *)message {
	RSAlertController* controller = [[RSAlertController alloc] initWithTitle:title message:message];
	[controller setTitle:title];
	
	return controller;
}

- (id)initWithTitle:(NSString*)title message:(NSString*)message {
	if (self = [super init]) {
		contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 100)];
		[contentView setBackgroundColor:[RSAesthetics colorsForCurrentTheme][@"BackgroundColor"]];
		[contentView.layer setBorderWidth:2];
		[contentView.layer setBorderColor:[RSAesthetics accentColor].CGColor];
		
		titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 30, screenWidth - 60, 30)];
		[titleLabel setFont:[UIFont fontWithName:@"SegoeUI" size:22]];
		[titleLabel setTextColor:[RSAesthetics colorsForCurrentTheme][@"ForegroundColor"]];
		[titleLabel setText:title];
		[titleLabel sizeToFit];
		
		messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 30 + titleLabel.frame.size.height + 5, screenWidth - 60, 30)];
		[messageLabel setFont:[UIFont fontWithName:@"SegoeUI" size:18]];
		[messageLabel setTextColor:[RSAesthetics colorsForCurrentTheme][@"ForegroundColor"]];
		[messageLabel setLineBreakMode:NSLineBreakByWordWrapping];
		[messageLabel setNumberOfLines:0];
		[messageLabel setText:message];
		[messageLabel sizeToFit];
	}
	
	return self;
}

- (void)loadView {
	self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
	[self.view setBackgroundColor:[RSAesthetics colorsForCurrentTheme][@"OpaqueBackgroundColor"]];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	actions = [NSMutableArray new];
	
	[self.view addSubview:contentView];
	[contentView addSubview:titleLabel];
	[contentView addSubview:messageLabel];
	
	[self updateAlertSize];
}

- (void)updateAlertSize {
	CGFloat height = 30 + titleLabel.frame.size.height + 5  + messageLabel.frame.size.height + 30 + (actions.count > 0 ? 38 : 0) + 30;
	
	[contentView setFrame:CGRectMake(0, screenHeight/2 - height/2, screenWidth, height)];
}

- (void)setTitle:(NSString *)title {
	[super setTitle:title];
	
	[titleLabel setText:title];
	[titleLabel sizeToFit];
}

- (void)addAction:(RSAlertAction*)action {
	if (actions.count == 3) {
		return;
	}
	
	[actions addObject:action];
	
	CGFloat buttonWidth = (self.view.frame.size.width - 60 - ((actions.count-1)*5)) / actions.count;
	for (int i=0; i<actions.count; i++) {
		RSAlertAction* action = [actions objectAtIndex:i];
		[action setFrame:CGRectMake(30 + (buttonWidth*i) + (i*5),
									30 + titleLabel.frame.size.height + 5 + messageLabel.frame.size.height + 30,
									buttonWidth,
									38)];
		[action.titleLabel setFrame:CGRectMake(0, 0, action.frame.size.width, action.frame.size.height)];
	}
	
	void (^handler)(void) = action.handler;
	action.handler = ^{
		handler();
		[self dismiss];
	};
	
	UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:action.handler action:@selector(invoke)];
	[action addGestureRecognizer:tapGestureRecognizer];
	
	[contentView addSubview:action];
	[self updateAlertSize];
}

- (void)show {
	[self.view.layer removeAllAnimations];
	[contentView.layer removeAllAnimations];
	
	[[[RSHomeScreenController sharedInstance] alertControllers] addObject:self];
	[[[RSHomeScreenController sharedInstance] window] addSubview:self.view];
	
	CAAnimation* scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"
														  function:CubicEaseOut
														 fromValue:1.35
														   toValue:1.0];
	[scale setDuration:0.4];
	[scale setRemovedOnCompletion:NO];
	[scale setFillMode:kCAFillModeForwards];
	
	CAAnimation* opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
															function:CubicEaseOut
														   fromValue:0.0
															 toValue:1.0];
	[opacity setDuration:0.3];
	[opacity setRemovedOnCompletion:NO];
	[opacity setFillMode:kCAFillModeForwards];
	
	[self.view.layer addAnimation:opacity forKey:@"opacity"];
	[contentView.layer addAnimation:scale forKey:@"scale"];
}

- (void)dismiss {
	[self.view.layer removeAllAnimations];
	[contentView.layer removeAllAnimations];
	
	CAAnimation* scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"
														  function:CubicEaseIn
														 fromValue:1.0
														   toValue:1.35];
	[scale setDuration:0.1];
	[scale setRemovedOnCompletion:NO];
	[scale setFillMode:kCAFillModeForwards];
	
	CAAnimation* opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
															function:CubicEaseIn
														   fromValue:1.0
															 toValue:0.0];
	[opacity setDuration:0.08];
	[opacity setRemovedOnCompletion:NO];
	[opacity setFillMode:kCAFillModeForwards];
	
	[self.view.layer addAnimation:opacity forKey:@"opacity"];
	[contentView.layer addAnimation:scale forKey:@"scale"];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self.view removeFromSuperview];
		[[[RSHomeScreenController sharedInstance] alertControllers] removeObject:self];
	});
}

@end
