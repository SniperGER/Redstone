#import "CommonHeaders.h"

@interface RSPinMenu : UIView {
	NSString* appBundleIdentifier;
}

-(void)playOpeningAnimation:(BOOL)comesFromTop;
-(void)setAppBundleIdentifier:(NSString*)bundleIdentifirer;

@end