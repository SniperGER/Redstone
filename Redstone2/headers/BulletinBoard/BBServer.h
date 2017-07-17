#import <Foundation/Foundation.h>

@interface BBServer : NSObject

+ (id)sharedBBServer; // added
- (id)_allBulletinsForSectionID:(id)arg1;

@end
