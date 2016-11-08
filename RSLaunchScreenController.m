#import "RSLaunchScreenController.h"
#import "RSLaunchScreen.h"
#import "Redstone.h"
#import "RSAesthetics.h"

@implementation RSLaunchScreenController

static RSLaunchScreenController* sharedInstance;

+(id)sharedInstance {
  return sharedInstance;
}

-(id)init {
	self = [super init];
  	sharedInstance = self;

	if (self) {
		self->launchScreen = [[RSLaunchScreen alloc] initWithFrame:CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) leafIdentifier:nil];
		[[Redstone sharedInstance].rootScrollView addSubview:self->launchScreen];
	}

	return self;
}

-(void)setLaunchScreenForLeafIdentifier:(NSString*)identifier {
	[self->launchScreen setBackgroundColor:[RSAesthetics accentColorForApp:identifier]];
}

-(void)show {
	CAAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
															function:CubicEaseOut
														   fromValue:0.0
															 toValue:1.0];
	opacity.duration = 0.3;
	opacity.removedOnCompletion = NO;
	opacity.fillMode = kCAFillModeForwards;
	
	CAAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"
														  function:CubicEaseOut
														 fromValue:0.8
														   toValue:1.0];
	scale.duration = 0.5;
	scale.removedOnCompletion = NO;
	scale.fillMode = kCAFillModeForwards;
	
	[[self->launchScreen subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
	//UIImageView* self->launchScreenImage = [[UIImageView alloc] initWithImage:[RSAesthetics getTileImage:bundleIdentifier withSize:10]];
	//[self->launchScreenImage setFrame:CGRectMake(CGRectGetMidX(self->launchScreen.bounds)-34, CGRectGetMidY(self->launchScreen.bounds)-34, 68 , 68)];
	//[self->launchScreen addSubview:self->launchScreenImage];
	
	[self->launchScreen setHidden:NO];
	//[[[self->launchScreen subviews] objectAtIndex:0].layer addAnimation:scale forKey:@"scale"];
	[self->launchScreen.layer addAnimation:opacity forKey:@"opacity"];
}
-(void)hide {
	[self->launchScreen.layer removeAllAnimations];
	[self->launchScreen setHidden:YES];
}

-(RSLaunchScreen*)launchScreen {
	return self->launchScreen;
}

@end