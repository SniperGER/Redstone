//
//  RSTileDelegate.h
//  
//
//  Created by Janik Schmidt on 05.08.16.
//
//

#import <Foundation/Foundation.h>

@class Redstone;

@interface RSTileDelegate : NSObject

+(NSArray*)getTileList;

+(NSDictionary*)getTileInformation:(NSString*)bundleIdentifier;
+(NSString*)getGlobalTileAccentColor;
+(NSString*)getIndividualTileAccentColor:(NSString*)bundleIdentifier;

+(BOOL)isTileHidden:(NSString*)bundleIdentifier;

@end
