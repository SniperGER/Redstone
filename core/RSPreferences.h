/*
 * Redstone
 * A Windows 10 Mobile experience for iOS
 * Compatible with iOS 9 (tested with iOS 9.3.3);
 *
 * Licensed under GNU GPLv3
 *
 * © 2016 Sniper_GER, FESTIVAL Development
 * All rights reserved.
 */

@interface RSPreferences : NSObject

+ (NSMutableDictionary*)preferences;
+ (void)setValue:(id)value forKey:(NSString*)key;

@end