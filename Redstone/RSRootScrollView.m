#import "Redstone.h"

@implementation RSRootScrollView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		[self setDelegate:self];
		
		[self setContentSize:CGSizeMake(screenWidth*2, screenHeight)];
		[self setPagingEnabled:YES];
		[self setBounces:NO];
		
		[self setScrollEnabled:NO];
	}
	
	return self;
}

@end
