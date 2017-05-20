#import "../Redstone.h"

@implementation RSLockScreen

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		[self setContentSize:CGSizeMake(screenWidth, screenHeight*2)];
		[self setPagingEnabled:YES];
		[self setBounces:NO];
		[self setShowsVerticalScrollIndicator:NO];
		[self setShowsHorizontalScrollIndicator:NO];
		
		self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth-48, screenHeight)];
		[self.timeLabel setFont:[UIFont fontWithName:@"SegoeUI-Light" size:114]];
		[self.timeLabel setTextColor:[UIColor whiteColor]];
		[self addSubview:self.timeLabel];
		
		self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth-48, screenHeight)];
		[self.dateLabel setFont:[UIFont fontWithName:@"SegoeUI-Semilight" size:36]];
		[self.dateLabel setTextColor:[UIColor whiteColor]];
		[self addSubview:self.dateLabel];
	}
	
	return self;
}

@end
