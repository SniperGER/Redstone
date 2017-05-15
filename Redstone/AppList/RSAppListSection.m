#import "../Redstone.h"

@implementation RSAppListSection

- (id)initWithFrame:(CGRect)frame letter:(NSString *)letter {
	self = [super initWithFrame:frame];
	
	if (self) {
		[self setClipsToBounds:YES];
		
		self.displayName = letter;
	
		self->sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 60, 60)];
		[self->sectionLabel setText:letter];
		[self->sectionLabel setTextColor:[UIColor whiteColor]];
		[self->sectionLabel setFont:[UIFont fontWithName:@"SegoeUI-Light" size:30]];
		[self addSubview:self->sectionLabel];
		
		UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
		[self addGestureRecognizer:tapGestureRecognizer];
	}
	
	return self;
}

- (void)tapped:(id)sender {
	[[RSAppListController sharedInstance] showJumpList];
}

@end
