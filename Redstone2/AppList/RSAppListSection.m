#import "../Redstone.h"

@implementation RSAppListSection

- (id)initWithFrame:(CGRect)frame letter:(NSString *)letter {
	if (self = [super initWithFrame:frame]) {
		displayName = letter;
		
		[self setClipsToBounds:YES];
		[self setHighlightEnabled:YES];
		
		sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 60, 60)];
		[sectionLabel setText:letter];
		[sectionLabel setTextColor:[UIColor whiteColor]];
		[sectionLabel setFont:[UIFont fontWithName:@"SegoeUI-Light" size:30]];
		[self addSubview:sectionLabel];
	}
	
	return self;
}

- (NSString*)displayName {
	return displayName;
}

@end
