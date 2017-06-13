#import <Foundation/Foundation.h>

@class RSLaunchScreen;

@interface RSLaunchScreenController : NSObject

@property (nonatomic, strong) RSLaunchScreen* launchScreen;

+ (id)sharedInstance;
- (void)setLaunchScreenForLeafIdentifier:(NSString*)leafIdentifier tileInfo:(RSTileInfo*)tileInfo;
- (void)show;
- (void)hide;

@end
