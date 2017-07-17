/**
 @class RSPreferences
 @author Sniper_GER
 @discussion Provides a dictionary representation of Redstone's preferences
 */

#import <Foundation/Foundation.h>

@interface RSPreferences : NSObject

@property (nonatomic, strong) NSMutableDictionary* preferences;

/**
 Returns a dictionary representation of Redstone's preferences
 
 @return The dictionary representation of Redstone's preferences
 */
+ (NSDictionary*)preferences;

/**
 Sets the property of the receiver specified by a given key to a given value.
 
 @param value The value for the property identified by key.
 @param key The name of one of the receiver's properties.
 */
+ (void)setValue:(id)value forKey:(NSString *)key;

/**
 Adds a given key-value pair to the dictionary.
 
 @param object The value for \p key. A strong reference to the object is maintained by the dictionary.
 @param key The key for \p value. If \p key already exists in the dictionary, \p object takes its place.
 */
+ (void)setObject:(id)object forKey:(NSString*)key;

+ (void)reloadPreferences;

/**
 Returns the value associated with a given key.
 
 @param key The key for which to return the corresponding value.
 @return The value associated with \p key, or nil if no value is associated with \p key.
 */
- (id)objectForKey:(NSString*)key;

@end
