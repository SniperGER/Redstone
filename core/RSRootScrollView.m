#import "../RedstoneHeaders.h"

@implementation RSRootScrollView

static RSRootScrollView* sharedInstance;

+ (id)sharedInstance {
	return sharedInstance;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	if (self) {
		sharedInstance = self;

		[self setContentSize:CGSizeMake(self.frame.size.width*2, self.frame.size.height)];
		[self setPagingEnabled:YES];
		[self setBounces:NO];
		[self setShowsVerticalScrollIndicator:NO];
		[self setShowsHorizontalScrollIndicator:NO];
		[self setDelaysContentTouches:NO];
		[self setMultipleTouchEnabled:NO];
		[self setDelegate:self];
	}

	return self;
}

@end