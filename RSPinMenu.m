#import "RSPinMenu.h"
#import "RSTiltView.h"

@implementation RSPinMenu

-(id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	self.backgroundColor = [UIColor colorWithWhite:0.16 alpha:1.0];
	self.layer.borderWidth = 2.0;
	self.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.2].CGColor;

	RSTiltView* pinToStart = [[RSTiltView alloc] initWithFrame:CGRectMake(0,0,frame.size.width,frame.size.height)];
	UILabel* pinToStartLabel = [[UILabel alloc] initWithFrame:CGRectMake(12,0,frame.size.width-24,frame.size.height)];
	pinToStartLabel.font = [UIFont fontWithName:@"SegoeUI" size:18];
	pinToStartLabel.textColor = [UIColor whiteColor];
	[pinToStartLabel setText:@"Pin to Start"];
	[pinToStart addSubview:pinToStartLabel];

	[pinToStart setActionForTapped:@selector(pinTileToStart:) forTarget:self];

	[self addSubview:pinToStart];

	[self.layer setOpacity:0.0];

	return self;
}

-(void)pinTileToStart:(id)sender {
	NSDictionary* userInfo = @{
		@"bundleIdentifier": appBundleIdentifier
	};
	
	NSLog(@"[RedstoneLog] Tile pinned");
	[[NSNotificationCenter defaultCenter] postNotificationName:@"applicationPinned" object:self userInfo:userInfo];
}

-(void)playOpeningAnimation:(BOOL)comesFromTop {
	CAAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
															function:ExponentialEaseOut
														   fromValue:0.0
															 toValue:1.0];
	opacity.duration = 0.25;
	opacity.removedOnCompletion = NO;
	opacity.fillMode = kCAFillModeForwards;
	
	CAAnimation *scale;
	if (comesFromTop) {
		scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"
												 function:ExponentialEaseOut
												fromValue:-self.frame.size.height/2
												  toValue:0.0];
	} else {
		
		scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"
												 function:ExponentialEaseOut
												fromValue:self.frame.size.height/2
												  toValue:0.0];
	}

	scale.duration = 0.4;
	scale.removedOnCompletion = NO;
	scale.fillMode = kCAFillModeForwards;
	
	[self.layer addAnimation:opacity forKey:@"opacity"];
	[self.layer addAnimation:scale forKey:@"scale"];
	[self.layer setOpacity:1.0];
}

-(void)setAppBundleIdentifier:(NSString*)bundleIdentifier {
	appBundleIdentifier = bundleIdentifier;
}

@end