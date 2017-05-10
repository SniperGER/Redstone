#import <Foundation/Foundation.h>

@class RSLaunchScreen;

@interface RSLaunchScreenController : NSObject {
	RSLaunchScreen* _launchScreen;
}

@property (nonatomic, strong) RSLaunchScreen* launchScreen;

+ (id)sharedInstance;
- (void)setLaunchScreenForLeafIdentifier:(NSString*)leafIdentifier;
- (void)show;
- (void)hide;

@end
