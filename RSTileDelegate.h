#include <objc/runtime.h>

@interface RSTileDelegate : NSObject

+(NSDictionary*)getTileInfo:(NSString*)bundleIdentifier;
+(NSString*)getTileDisplayName:(NSString*)bundleIdentifier;
+(NSArray*)getTileList;

@end