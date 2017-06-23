#import "../Redstone.h"

@implementation RSVolumeView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setBackgroundColor:[UIColor colorWithWhite:0.18 alpha:1.0]];
		[self setClipsToBounds:YES];
		[self.layer setAnchorPoint:CGPointMake(0.5, 0)];
    }
    
    return self;
}

@end
