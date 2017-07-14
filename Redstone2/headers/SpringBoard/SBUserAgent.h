#import <Foundation/Foundation.h>

@interface SBUserAgent : NSObject

+ (id)sharedUserAgent;
- (BOOL)deviceIsLocked;
- (BOOL)deviceIsPasscodeLocked;

@end
