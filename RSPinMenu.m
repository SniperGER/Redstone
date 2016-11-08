#import "RSPinMenu.h"
#import "RSApp.h"
#import "RSAesthetics.h"
#import "RSAppListController.h"
#import "RSStartScreenController.h"
#import "RSTiltView.h"

@implementation RSPinMenu

-(id)initWithFrame:(CGRect)frame app:(RSApp*)app {
	self = [super initWithFrame:frame];
	
	if (self) {
		self.backgroundColor = [UIColor colorWithWhite:0.16 alpha:1.0];
		self.layer.borderWidth = 1.0;
		self.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.2].CGColor;
		self.clipsToBounds = YES;
		
		self->appIcon = app;

		RSTiltView* pinButton = [[RSTiltView alloc] initWithFrame:CGRectMake(1,1,self.frame.size.width-2,52)];
		pinButton.hasHighlight = YES;
		pinButton.transformMultiplierX = 0.2;
		[self addSubview:pinButton];

		UILabel* pinLabel = [[UILabel alloc] initWithFrame:CGRectMake(12,0,self.frame.size.width-24,52)];
		[pinLabel setText:[RSAesthetics localizedStringForKey:@"PIN_TO_START"]];
		[pinLabel setFont:[UIFont fontWithName:@"SegoeUI" size:18]];
		[pinLabel setTextColor:[UIColor whiteColor]];
		[pinLabel setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.0]];
		[pinButton addSubview:pinLabel];

		if ([[[RSStartScreenController sharedInstance] pinnedLeafIdentifiers] containsObject:[self->appIcon leafIdentifier]]) {
			[pinButton setUserInteractionEnabled:NO];
			[pinLabel setAlpha:0.4];
		} else {
			UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pinApp:)];
			[pinButton addGestureRecognizer:tap];
		}

		if ([[self->appIcon appIcon] isUninstallSupported]) {
			RSTiltView* uninstallButton = [[RSTiltView alloc] initWithFrame:CGRectMake(1,53,self.frame.size.width-2,52)];
			uninstallButton.hasHighlight = YES;
			uninstallButton.transformMultiplierX = 0.2;
			[self addSubview:uninstallButton];

			UILabel* uninstallLabel = [[UILabel alloc] initWithFrame:CGRectMake(12,0,self.frame.size.width-24,55)];
			[uninstallLabel setText:[RSAesthetics localizedStringForKey:@"UNINSTALL"]];
			[uninstallLabel setFont:[UIFont fontWithName:@"SegoeUI" size:18]];
			[uninstallLabel setTextColor:[UIColor whiteColor]];
			[uninstallLabel setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.0]];
			[uninstallButton addSubview:uninstallLabel];
		}
	}
	
	return self;
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

-(void)pinApp:(id)sender {
	[[RSAppListController sharedInstance] hidePinMenu];
	[[RSStartScreenController sharedInstance] pinTileWithId:[self->appIcon leafIdentifier]];
}

@end