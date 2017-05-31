#import "../Redstone.h"

@implementation RSLockScreenView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
		[timeLabel setFont:[UIFont fontWithName:@"SegoeUI-Light" size:75]];
		[timeLabel setTextColor:[UIColor whiteColor]];
		[timeLabel sizeToFit];
		[self addSubview:timeLabel];
		
		dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
		[dateLabel setFont:[UIFont fontWithName:@"SegoeUI-Semilight" size:24]];
		[dateLabel setTextColor:[UIColor whiteColor]];
		[dateLabel sizeToFit];
		[self addSubview:dateLabel];
	}
	
	return self;
}

- (void)setTime:(NSString *)time {
	NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:time];
	[attributedString addAttributes:@{
									  NSBaselineOffsetAttributeName: @8.0
									  }range:[time rangeOfString:@":"]];
	
	[timeLabel setAttributedText:attributedString];
	[timeLabel sizeToFit];
	[timeLabel setFrame:CGRectMake(21, screenHeight - timeLabel.frame.size.height - (140 - 42), timeLabel.frame.size.width, timeLabel.frame.size.height)];
}

- (void)setDate:(NSString *)date {
	[dateLabel setText:date];
	[dateLabel sizeToFit];
	[dateLabel setFrame:CGRectMake(21, screenHeight - dateLabel.frame.size.height - (110 - 42), dateLabel.frame.size.width, dateLabel.frame.size.height)];
}

@end
