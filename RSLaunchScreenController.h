#import "CommonHeaders.h"

@class RSLaunchScreen;

@interface RSLaunchScreenController : NSObject {
	RSLaunchScreen* launchScreen;
}

+(id)sharedInstance;
-(void)setLaunchScreenForLeafIdentifier:(NSString*)identifier;
-(void)show;
-(void)hide;
-(RSLaunchScreen*)launchScreen;

@end