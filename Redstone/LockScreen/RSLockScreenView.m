#import "../Redstone.h"

@implementation RSLockScreenView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
		[timeLabel setFont:[UIFont fontWithName:@"SegoeUI-Light" size:90]];
		[timeLabel setTextColor:[UIColor whiteColor]];
		[timeLabel sizeToFit];
		[self addSubview:timeLabel];
		
		dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
		[dateLabel setFont:[UIFont fontWithName:@"SegoeUI-Semilight" size:30]];
		[dateLabel setTextColor:[UIColor whiteColor]];
		[dateLabel sizeToFit];
		[self addSubview:dateLabel];
	}
	
	return self;
}

- (void)setTime:(NSString *)time {
	[timeLabel setText:time];
	[timeLabel sizeToFit];
	[timeLabel setFrame:CGRectMake(24, screenHeight - timeLabel.frame.size.height - 135, timeLabel.frame.size.width, timeLabel.frame.size.height)];
}

- (void)setDate:(NSString *)date {
	[dateLabel setText:date];
	[dateLabel sizeToFit];
	[dateLabel setFrame:CGRectMake(24, screenHeight - dateLabel.frame.size.height - 95, dateLabel.frame.size.width, dateLabel.frame.size.height)];
}

@end
