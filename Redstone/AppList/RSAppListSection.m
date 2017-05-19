#import "../Redstone.h"

@implementation RSAppListSection

- (id)initWithFrame:(CGRect)frame letter:(NSString *)letter {
	self = [super initWithFrame:frame];
	
	if (self) {
		[self setClipsToBounds:YES];
		[self setHighlightEnabled:YES];
		
		self.displayName = letter;
	
		self->sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 60, 60)];
		[self->sectionLabel setText:letter];
		[self->sectionLabel setTextColor:[UIColor whiteColor]];
		[self->sectionLabel setFont:[UIFont fontWithName:@"SegoeUI-Light" size:30]];
		[self addSubview:self->sectionLabel];
		
		UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
		[tapGestureRecognizer setCancelsTouchesInView:NO];
		[tapGestureRecognizer setDelegate:self];
		[self addGestureRecognizer:tapGestureRecognizer];
	}
	
	return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	return YES;
}

- (void)tapped:(UITapGestureRecognizer*)gestureRecognizer {
	if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
		[self untilt];
		[[RSAppListController sharedInstance] showJumpList];
	}
}

@end
