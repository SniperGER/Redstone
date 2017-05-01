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

@interface RSTiltView : UIView {
	CATransform3D layerTransform;
	float transformAngle;
	float transformMultiplierX;
	float transformMultiplierY;
	BOOL hasHighlight;
	BOOL keepsHighlightOnLongPress;
	BOOL isUntilted;
}

- (void)setTransformOptions:(NSDictionary*)options;

@end