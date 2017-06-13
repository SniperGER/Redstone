#import <Foundation/Foundation.h>

@interface RSPreferences : NSObject {
	NSMutableDictionary* _preferences;
}

@property (nonatomic, strong) NSMutableDictionary* preferences;

+ (NSMutableDictionary*)preferences;
+ (void)setValue:(id)value forKey:(NSString*)key;

@end
