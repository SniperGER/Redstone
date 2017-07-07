#import "../Redstone.h"

@implementation RSProgressBar

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self setBackgroundColor:[RSAesthetics colorsForCurrentTheme][@"TrackColor"]];
		
		progressLayer = [UIView new];
		[progressLayer setFrame:CGRectMake(0, 0, 0, frame.size.height)];
		[progressLayer setBackgroundColor:[RSAesthetics accentColor]];
		[self addSubview:progressLayer];
	}
	
	return self;
}

- (void)setProgress:(float)progress {
	[UIView animateWithDuration:0.3 animations:^{
		[progressLayer setEasingFunction:CreateCAMediaTimingFunction(0.1, 0.9, 0.2, 1) forKeyPath:@"frame"];
		
		[progressLayer setFrame:CGRectMake(0, 0, self.frame.size.width * progress, self.frame.size.height)];
	} completion:^(BOOL finished) {
		[progressLayer removeEasingFunctionForKeyPath:@"frame"];
	}];
}

@end
