//
//  RSTileDelegate.h
//  
//
//  Created by Janik Schmidt on 06.08.16.
//
//

#import <Foundation/Foundation.h>
#import "Headers.h"

@interface RSTileDelegate : NSObject

+(NSArray*)getTileList;

+(NSDictionary*)getTileInfo:(NSString*)bundleIdentifier;
+(NSString*)getTileDisplayName:(NSString*)bundleIdentifier;
+(UIColor*)getGlobalAccentColor;
+(UIColor*)getIndividualTileColor:(NSString*)bundleIdentifier;
+(UIColor*)getTileLaunchImageColor:(NSString*)bundleIdentifier;
+(CGFloat)getTileOpacity;
+(UIImage*)getTileImage:(NSString*)bundleIdentifier withSize:(NSString*)size;

+(BOOL)isAppHidden:(NSString*)bundleIdentifier;

@end
