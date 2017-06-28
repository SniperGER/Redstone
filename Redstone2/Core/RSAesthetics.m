#import "../Redstone.h"

@implementation RSAesthetics

+ (NSDictionary*)colorsForTheme:(NSString *)themeName {
	if ([themeName isEqualToString:@"dark"]) {
		return @{
				 @"RedstoneForegroundColor": [UIColor whiteColor],
				 @"RedstoneBackgroundColor": [UIColor colorWithWhite:0.22 alpha:1.0]
				 };
	} else if ([themeName isEqualToString:@"light"]) {
		return @{
				 @"RedstoneForegroundColor": [UIColor blackColor],
				 @"RedstoneBackgroundColor": [UIColor whiteColor]
				 };
	}
	
	return nil;
}

@end
