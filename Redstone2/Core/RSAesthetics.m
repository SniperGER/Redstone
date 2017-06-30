#import "../Redstone.h"

@implementation RSAesthetics

+ (UIColor*)accentColor {
	return [self colorFromHexString:[[RSPreferences preferences] objectForKey:@"accentColor"]];
}

+ (CGFloat)tileOpacity {
	return [[[RSPreferences preferences] objectForKey:@"tileOpacity"] floatValue];
}

+ (NSDictionary*)colorsForTheme:(NSString *)themeName {
	if ([themeName isEqualToString:@"dark"]) {
		return @{
				 @"RedstoneForegroundColor": [UIColor whiteColor],
				 @"RedstoneBackgroundColor": [UIColor colorWithWhite:0.22 alpha:1.0],
				 @"RedstoneOpaqueBackgroundColor": [UIColor colorWithWhite:0.0 alpha:0.75]
				 };
	} else if ([themeName isEqualToString:@"light"]) {
		return @{
				 @"RedstoneForegroundColor": [UIColor blackColor],
				 @"RedstoneBackgroundColor": [UIColor whiteColor],
				 @"RedstoneOpaqueBackgroundColor": [UIColor colorWithWhite:1.0 alpha:0.75]
				 };
	}
	
	return nil;
}

+ (UIColor*)colorFromHexString:(NSString*)arg1 {
	NSString *cleanString = [arg1 stringByReplacingOccurrencesOfString:@"#" withString:@""];
	
	if ([cleanString length] == 3) {
		cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
					   [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
					   [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
					   [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
	}
	
	if ([cleanString length] == 6) {
		cleanString = [cleanString stringByAppendingString:@"ff"];
	}
	
	unsigned int baseValue;
	[[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
	
	float red = ((baseValue >> 24) & 0xFF)/255.0f;
	float green = ((baseValue >> 16) & 0xFF)/255.0f;
	float blue = ((baseValue >> 8) & 0xFF)/255.0f;
	float alpha = ((baseValue >> 0) & 0xFF)/255.0f;
	
	return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
