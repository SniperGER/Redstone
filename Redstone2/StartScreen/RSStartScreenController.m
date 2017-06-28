#import "../Redstone.h"

@interface RSStartScreenController ()

@end

@implementation RSStartScreenController

- (void)loadView {
	self.view = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
	[(UIScrollView*)self.view setContentSize:CGSizeMake(screenWidth, 1000)];
}

@end
