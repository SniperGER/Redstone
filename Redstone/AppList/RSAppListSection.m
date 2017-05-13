#import "../Redstone.h"

@implementation RSAppListSection

- (id)initWithFrame:(CGRect)frame letter:(NSString *)letter {
	self = [super initWithFrame:frame];
	
	if (self) {
		[self setClipsToBounds:YES];
		
		self.displayName = letter;
		
		self->backgroundImage = [[UIImageView alloc] initWithImage:[RSAesthetics getCurrentWallpaper]];
		[self->backgroundImage setFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
		//[self addSubview:self->backgroundImage];
		
		self->backgroundImageOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		[self->backgroundImageOverlay setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.75]];
		//[self addSubview:self->backgroundImageOverlay];
	
		self->sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 60, 60)];
		[self->sectionLabel setText:letter];
		[self->sectionLabel setTextColor:[UIColor whiteColor]];
		[self->sectionLabel setFont:[UIFont fontWithName:@"SegoeUI-Light" size:30]];
		[self addSubview:self->sectionLabel];
	}
	
	return self;
}


- (void)updateBackgroundPosition {
	[self->backgroundImage setFrame:CGRectMake(-screenWidth + [[RSCore sharedInstance] rootScrollView].contentOffset.x, -self.frame.origin.y + [[RSAppListController sharedInstance] appList].contentOffset.y - 70, screenWidth, screenHeight)];
}

- (void)setOverlayAlpha:(CGFloat)alpha {
	[self->backgroundImageOverlay setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:alpha]];
}

@end
