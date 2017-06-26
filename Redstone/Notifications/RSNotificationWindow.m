#import "../Redstone.h"

@implementation RSNotificationWindow

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self setWindowLevel:1500];
	}
	
	return self;
}

@end
