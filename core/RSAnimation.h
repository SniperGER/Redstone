/*
 * Redstone
 * A Windows 10 Mobile experience for iOS
 * Compatible with iOS 9 (tested with iOS 9.3.3);
 *
 * Licensed under GNU GPLv3
 *
 * © 2016 Sniper_GER, FESTIVAL Development
 * All rights reserved.
 */

@interface RSAnimation : NSObject

+ (NSArray*)tileSlideOutAnimationWithDuration:(float)duration delay:(float)animationDelay;
+ (NSArray*)tileSlideInAnimationWithDuration:(float)duration delay:(float)animationDelay;

@end