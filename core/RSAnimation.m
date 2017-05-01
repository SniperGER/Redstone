#import "../RedstoneHeaders.h"

@implementation RSAnimation

+ (NSArray*)tileSlideOutAnimationWithDuration:(float)duration delay:(float)animationDelay {
	CAAnimation* scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"
														  function:CubicEaseIn
														 fromValue:1.0
														   toValue:4.0];
	scale.duration = duration;
	scale.removedOnCompletion = NO;
	scale.fillMode = kCAFillModeForwards;
	scale.beginTime = CACurrentMediaTime()+animationDelay;

	CAAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
															function:CubicEaseIn
														   fromValue:1.0
															 toValue:0.0];
	opacity.duration = duration - 0.025;
	opacity.removedOnCompletion = NO;
	opacity.fillMode = kCAFillModeForwards;
	opacity.beginTime = CACurrentMediaTime()+animationDelay;

	NSArray* animationArray = @[scale, opacity];

	return animationArray;
}
+ (NSArray*)tileSlideInAnimationWithDuration:(float)duration delay:(float)animationDelay {
	CAAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"
														  function:CubicEaseOut
														 fromValue:0.9
														   toValue:1.0];
	scale.duration = duration;
	scale.removedOnCompletion = NO;
	scale.fillMode = kCAFillModeForwards;
	scale.beginTime = CACurrentMediaTime()+animationDelay;

	CAAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
															function:CubicEaseOut
														   fromValue:0.0
															 toValue:1.0];
	opacity.duration = duration - 0.1;
	opacity.removedOnCompletion = NO;
	opacity.fillMode = kCAFillModeForwards;
	opacity.beginTime = CACurrentMediaTime()+animationDelay;

	CAAnimationGroup *animations = [CAAnimationGroup animation];
	[animations setAnimations:@[scale, opacity]];

	NSArray* animationArray = @[scale, opacity];

	return animationArray;
}

@end