//
//  RSPreferences.h
//  Redstone
//
//  Created by Janik Schmidt on 12.05.17.
//
//

#import <Foundation/Foundation.h>

@interface RSPreferences : NSObject {
	NSMutableDictionary* _preferences;
}

@property (nonatomic, retain) NSMutableDictionary* preferences;

+ (NSMutableDictionary*)preferences;
+ (void)setValue:(id)value forKey:(NSString*)key;

@end
