#import "Redstone.h"
#import "substrate.h"

extern "C" UIImage * _UICreateScreenUIImage();

RSCore* redstone;

void playZoomDownAppAnimation() {
	UIImage *screenImage = _UICreateScreenUIImage();
	UIImageView *screenImageView = [[UIImageView alloc] initWithImage:screenImage];
	[redstone.window addSubview:screenImageView];
	
	CAAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
															function:CubicEaseInOut
														   fromValue:1.0
															 toValue:0.0];
	opacity.duration = 0.325;
	opacity.removedOnCompletion = NO;
	opacity.fillMode = kCAFillModeForwards;
	
	CAAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"
														  function:CubicEaseInOut
														 fromValue:1.0
														   toValue:1.5];
	scale.duration = 0.35;
	scale.removedOnCompletion = NO;
	scale.fillMode = kCAFillModeForwards;
	
	[screenImageView.layer addAnimation:opacity forKey:@"opacity"];
	[screenImageView.layer addAnimation:scale forKey:@"scale"];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[screenImageView removeFromSuperview];
		
		[redstone.startScreenController returnToHomescreen];
	});
}

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)arg1 {
	%orig(arg1);
	
	redstone = [[RSCore alloc] initWithWindow:[[%c(SBUIController) sharedInstance] window]];
	[RSCore hideAllExcept:nil];
}

- (void)frontDisplayDidChange:(id)arg1 {
	%orig(arg1);
	
	[redstone frontDisplayDidChange:arg1];
}

%end

%hook SBUIAnimationZoomApp

- (void)__startAnimation {
	if ([self zoomDirection] == 1) {
		playZoomDownAppAnimation();
	}
	
	%orig;
}

%end

%hook SBUIAnimationZoomDownApp

- (void)_startAnimation {
	playZoomDownAppAnimation();
	
	%orig;
}

%end

%hook SBHomeScreenViewController

- (NSInteger)supportedInterfaceOrientations {
	return 1;
}

%end
