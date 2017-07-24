#import "../Redstone.h"

@implementation RSAppSwitcherController

- (id)init {
	if (self = [super init]) {
		self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
		
		containerView = [[RSAppSwitcherContainerView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
		[containerView setBackgroundColor:[RSAesthetics colorsForCurrentTheme][@"OpaqueBackgroundColor"]];
		[self.window addSubview:containerView];
		
		homeScreenImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
		[homeScreenImageView setTransform:CGAffineTransformMakeScale(0.5, 0.5)];
		[containerView addSubview:homeScreenImageView];
	}
	
	return self;
}

- (void)setHomeScreenView:(UIView*)view {
	[homeScreenImageView setImage:[self imageWithView:view]];
}

- (UIImage*)imageWithView:(UIView *)view {
	UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
	[view.layer renderInContext:UIGraphicsGetCurrentContext()];
	
	UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return img;
}

@end
