#import "../Redstone.h"

@implementation RSPinMenu

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		[self setBackgroundColor:[UIColor colorWithWhite:0.18 alpha:1.0]];
		[self.layer setBorderColor:[UIColor colorWithWhite:0.46 alpha:1.0].CGColor];
		[self.layer setBorderWidth:2.0];
		
		UILabel* pinLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 14, self.frame.size.width-24, 66)];
		[pinLabel setText:@"PIN_TO_START"];
		[pinLabel setFont:[UIFont fontWithName:@"SegoeUI" size:18]];
		[pinLabel setTextColor:[UIColor whiteColor]];
		[pinLabel setUserInteractionEnabled:YES];
		[self addSubview:pinLabel];
		
		UITapGestureRecognizer* pinGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pin)];
		[pinLabel addGestureRecognizer:pinGestureRecognizer];
	}
	
	return self;
}

- (void)pin {
	if (self.handlingApp) {
		[[RSStartScreenController sharedInstance] pinTileWithId:[[[self.handlingApp icon] application] bundleIdentifier]];
	}
}

@end
