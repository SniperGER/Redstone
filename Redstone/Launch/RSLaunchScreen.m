#import "../Redstone.h"

@implementation RSLaunchScreen

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		[self setBackgroundColor:[UIColor colorWithRed:0.0 green:0.47 blue:0.843 alpha:1.0]];
		
		self.launchImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 76, 76)];
		[self.launchImageView setCenter:CGPointMake(screenWidth/2, screenHeight/2)];
		[self.launchImageView setTintColor:[UIColor whiteColor]];
		[self addSubview:self.launchImageView];
	}
	
	return self;
}

@end
