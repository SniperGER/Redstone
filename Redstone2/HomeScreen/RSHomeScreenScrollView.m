#import "../Redstone.h"

@implementation RSHomeScreenScrollView

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		
		[self setPagingEnabled:YES];
		[self setBounces:NO];
		[self setShowsVerticalScrollIndicator:NO];
		[self setShowsHorizontalScrollIndicator:NO];
		
		if ([[[RSPreferences preferences] objectForKey:@"debugAppList"] boolValue]) {
			[self setContentSize:CGSizeMake(frame.size.width*2, frame.size.height)];
		} else {
			[self setContentSize:CGSizeMake(frame.size.width, frame.size.height)];
		}
	}
	
	return self;
}

@end
