#import "../Redstone.h"

@implementation RSNotificationView

- (id)notificationWithTitle:(NSString*)title subtitle:(NSString*)subtitle message:(NSString*)message {
	self = [super initWithFrame:CGRectMake(0, 0, screenWidth, 80)];
	
	if (self) {
		[self setBackgroundColor:[UIColor colorWithWhite:0.22 alpha:1.0]];
		
		titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		[titleLabel setFont:[UIFont fontWithName:@"SegoeUI-Semibold" size:15]];
		[titleLabel setTextColor:[UIColor whiteColor]];
		[titleLabel setText:title];
		[titleLabel sizeToFit];
		[titleLabel setFrame:CGRectMake(12, 15, screenWidth - 24, titleLabel.frame.size.height)];
		[self addSubview:titleLabel];
		
		subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		[subtitleLabel setFont:[UIFont fontWithName:@"SegoeUI-Semibold" size:15]];
		[subtitleLabel setTextColor:[UIColor whiteColor]];
		[subtitleLabel setText:subtitle];
		[subtitleLabel sizeToFit];
		[subtitleLabel setFrame:CGRectMake(12, 15 + titleLabel.frame.size.height, screenWidth - 24, subtitleLabel.frame.size.height)];
		[self addSubview:subtitleLabel];
		
		messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		[messageLabel setFont:[UIFont fontWithName:@"SegoeUI" size:15]];
		[messageLabel setTextColor:[UIColor whiteColor]];
		[messageLabel setText:message];
		[messageLabel setNumberOfLines:2];
		[messageLabel setLineBreakMode:NSLineBreakByWordWrapping];
		[messageLabel sizeToFit];
		[messageLabel setFrame:CGRectMake(12, 15 + subtitleLabel.frame.size.height + titleLabel.frame.size.height, screenWidth - 24, messageLabel.frame.size.height)];
		[self addSubview:messageLabel];
		
		[self setFrame:CGRectMake(0, 0, screenWidth, titleLabel.frame.size.height + subtitleLabel.frame.size.height + messageLabel.frame.size.height + 50)];
		
		UIView* grabberView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-20, screenWidth, 20)];
		[grabberView setBackgroundColor:[RSAesthetics accentColor]];
		[self addSubview:grabberView];
	}
	
	return self;
}

- (void)show {
	[self.layer removeAllAnimations];
	CAAnimation* transformIn = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"
																function:CubicEaseOut
															   fromValue:-self.frame.size.height
																 toValue:0];
	[transformIn setDuration:0.3];
	[transformIn setRemovedOnCompletion:NO];
	[transformIn setFillMode:kCAFillModeForwards];
	
	[self.layer addAnimation:transformIn forKey:@"transform"];
}

- (void)hide {
	[self.layer removeAllAnimations];
	
	CAAnimation* transformOut = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"
																 function:CubicEaseIn
																fromValue:0
																  toValue:-self.frame.size.height];
	[transformOut setDuration:0.3];
	[transformOut setRemovedOnCompletion:NO];
	[transformOut setFillMode:kCAFillModeForwards];
	
	[self.layer addAnimation:transformOut forKey:@"transform"];
}

@end
