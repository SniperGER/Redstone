#import "RSLaunchScreen.h"
#import "RSAesthetics.h"

@implementation RSLaunchScreen

-(id)initWithFrame:(CGRect)frame leafIdentifier:(NSString*)identifier {
	self = [super initWithFrame:frame];

	if (self) {
		if (identifier != nil) {
			[self setBackgroundColor:[RSAesthetics accentColorForApp:identifier]];
		} else {
			[self setBackgroundColor:[RSAesthetics accentColor]];
		}

		[self setHidden:YES];
	}

	return self;
}

@end