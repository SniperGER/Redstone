#import "../Redstone.h"

@implementation RSAppListSection

- (id)initWithFrame:(CGRect)frame letter:(NSString *)letter {
	if (self = [super initWithFrame:frame]) {
		self.originalCenter = self.center;
		[self.layer setZPosition:100];
		displayName = letter;
		
		[self setClipsToBounds:YES];
		[self setHighlightEnabled:YES];
		
		sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 60, 60)];
		[sectionLabel setTextColor:[RSAesthetics colorsForCurrentTheme][@"ForegroundColor"]];
		[sectionLabel setFont:[UIFont fontWithName:@"SegoeUI-Light" size:30]];
		
		if ([letter isEqualToString:@"@"]) {
			letter = @"\uE12B";
			[sectionLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:24]];
		}
		
		[sectionLabel setText:letter];
		[self addSubview:sectionLabel];
		
		UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
		[self addGestureRecognizer:tapGestureRecognizer];
	}
	
	return self;
}

- (NSString*)displayName {
	return displayName;
}

- (void)tapped:(UITapGestureRecognizer*)gestureRecognizer {
	if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
		[self untilt];
		[[[RSHomeScreenController sharedInstance] appListController] showJumpList];
	}
}

@end
