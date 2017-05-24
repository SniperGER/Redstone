#import "../Redstone.h"

@implementation RSPasscodeButton

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		buttonLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		[buttonLabel setFont:[UIFont fontWithName:@"SegoeUI" size:34]];
		[buttonLabel setTextColor:[UIColor whiteColor]];
		[buttonLabel setTextAlignment:NSTextAlignmentCenter];
		[self addSubview:buttonLabel];
	}
	
	return self;
}

- (void)setButtonLabel:(NSString *)label {
	if (!self.isBackspaceButton) {
		[buttonLabel setText:label];
	}
}

- (NSString*)buttonLabel {
	return buttonLabel.text;
}

- (void)setIsBackspaceButton:(BOOL)isBackspaceButton {
	_isBackspaceButton = isBackspaceButton;
	
	if (isBackspaceButton) {
		[buttonLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:34]];
		[buttonLabel setText:@"\uE94F"];
	} else {
		[buttonLabel setFont:[UIFont fontWithName:@"SegoeUI" size:34]];
	}
}

- (void)setIsReturnButton:(BOOL)isReturnButton {
	_isReturnButton = isReturnButton;
	
	if (isReturnButton) {
		[buttonLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:34]];
		[buttonLabel setText:@"\uE10B"];
	} else {
		[buttonLabel setFont:[UIFont fontWithName:@"SegoeUI" size:34]];
	}
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
	[self setBackgroundColor:[RSAesthetics accentColor]];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
	[self setBackgroundColor:[UIColor clearColor]];
}

@end
