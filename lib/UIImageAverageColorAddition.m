//
//  UIImage+UIImageAverageColorAddition.m
//  AvgColor
//
//  Created by nikolai on 28.08.12.
//  Copyright (c) 2012 Savoy Software. All rights reserved.
//

#import "UIImageAverageColorAddition.h"

@implementation UIImage (UIImageAverageColorAddition)

- (UIColor *)dominantColor
{
    CGImageRef rawImageRef = [self CGImage];
    
    // This function returns the raw pixel values
	CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider(rawImageRef));
    const UInt8 *rawPixelData = CFDataGetBytePtr(data);
    
    NSUInteger imageHeight = CGImageGetHeight(rawImageRef);
    NSUInteger imageWidth  = CGImageGetWidth(rawImageRef);
    NSUInteger bytesPerRow = CGImageGetBytesPerRow(rawImageRef);
	NSUInteger stride = CGImageGetBitsPerPixel(rawImageRef) / 8;
    
    // Here I sort the R,G,B, values and get the average over the whole image
    unsigned int red   = 0;
    unsigned int green = 0;
    unsigned int blue  = 0;
    
	for (int row = 0; row < imageHeight; row++) {
		const UInt8 *rowPtr = rawPixelData + bytesPerRow * row;
		for (int column = 0; column < imageWidth; column++) {
            red    += rowPtr[0];
            green  += rowPtr[1];
            blue   += rowPtr[2];
			rowPtr += stride;
            
        }
    }
	CFRelease(data);
    
	CGFloat f = 1.0f / (255.0f * imageWidth * imageHeight);
	return [UIColor colorWithRed:(f * red)  green:(f * green) blue:(f * blue) alpha:1];
}

- (UIColor *)averageColor
{
    CGImageRef rawImageRef = [self CGImage];

    // This function returns the raw pixel values
	CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider(rawImageRef));
    const UInt8 *rawPixelData = CFDataGetBytePtr(data);

    NSUInteger imageHeight = CGImageGetHeight(rawImageRef);
    NSUInteger imageWidth  = CGImageGetWidth(rawImageRef);
    NSUInteger bytesPerRow = CGImageGetBytesPerRow(rawImageRef);
	NSUInteger stride = CGImageGetBitsPerPixel(rawImageRef) / 8;

    // Here I sort the R,G,B, values and get the average over the whole image
    unsigned int red   = 0;
    unsigned int green = 0;
    unsigned int blue  = 0;

	for (int row = 0; row < imageHeight; row++) {
		const UInt8 *rowPtr = rawPixelData + bytesPerRow * row;
		for (int column = 0; column < imageWidth; column++) {
            red    += rowPtr[0];
            green  += rowPtr[1];
            blue   += rowPtr[2];
			rowPtr += stride;

        }
    }
	CFRelease(data);

	CGFloat f = 1.0f / (255.0f * imageWidth * imageHeight);
	return [UIColor colorWithRed:f * red  green:f * green blue:f * blue alpha:1];
}

- (UIColor *)mergedColor
{
	CGSize size = {1, 1};
	UIGraphicsBeginImageContext(size);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetInterpolationQuality(ctx, kCGInterpolationMedium);
	[self drawInRect:(CGRect){.size = size} blendMode:kCGBlendModeCopy alpha:1];
	uint8_t *data = CGBitmapContextGetData(ctx);
	UIColor *color = [UIColor colorWithRed:data[2] / 255.0f
									 green:data[1] / 255.0f
									  blue:data[0] / 255.0f
									 alpha:1];
	UIGraphicsEndImageContext();
	return color;
}

- (NSArray*)mainColorsInImage {
	float dimension = 10;
	float flexibility = 2;
	float range = 60;
	
	NSMutableArray * colours = [NSMutableArray new];
	CGImageRef imageRef = [self CGImage];
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	unsigned char *rawData = (unsigned char*) calloc(dimension * dimension * 4, sizeof(unsigned char));
	NSUInteger bytesPerPixel = 4;
	NSUInteger bytesPerRow = bytesPerPixel * dimension;
	NSUInteger bitsPerComponent = 8;
	CGContextRef context = CGBitmapContextCreate(rawData, dimension, dimension, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	CGColorSpaceRelease(colorSpace);
	CGContextDrawImage(context, CGRectMake(0, 0, dimension, dimension), imageRef);
	CGContextRelease(context);
	
	float x = 0;
	float y = 0;
	for (int n = 0; n<(dimension*dimension); n++){
	
	    int index = (bytesPerRow * y) + x * bytesPerPixel;
	    int red   = rawData[index];
	    int green = rawData[index + 1];
	    int blue  = rawData[index + 2];
	    int alpha = rawData[index + 3];
	    NSArray * a = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%i",red],[NSString stringWithFormat:@"%i",green],[NSString stringWithFormat:@"%i",blue],[NSString stringWithFormat:@"%i",alpha], nil];
	    [colours addObject:a];
	
	    y++;
	    if (y==dimension){
	        y=0;
	        x++;
	    }
	}
	free(rawData);
	
	NSArray * copyColours = [NSArray arrayWithArray:colours];
	NSMutableArray * flexibleColours = [NSMutableArray new];
	
	float flexFactor = flexibility * 2 + 1;
	float factor = flexFactor * flexFactor * 3; //(r,g,b) == *3
	for (int n = 0; n<(dimension * dimension); n++){
	
	    NSArray * pixelColours = copyColours[n];
	    NSMutableArray * reds = [NSMutableArray new];
	    NSMutableArray * greens = [NSMutableArray new];
	    NSMutableArray * blues = [NSMutableArray new];
	
	    for (int p = 0; p<3; p++){
	
	        NSString * rgbStr = pixelColours[p];
	        int rgb = [rgbStr intValue];
	
	        for (int f = -flexibility; f<flexibility+1; f++){
	            int newRGB = rgb+f;
	            if (newRGB<0){
	                newRGB = 0;
	            }
	            if (p==0){
	                [reds addObject:[NSString stringWithFormat:@"%i",newRGB]];
	            } else if (p==1){
	                [greens addObject:[NSString stringWithFormat:@"%i",newRGB]];
	            } else if (p==2){
	                [blues addObject:[NSString stringWithFormat:@"%i",newRGB]];
	            }
	        }
	    }
	
	    int r = 0;
	    int g = 0;
	    int b = 0;
	    for (int k = 0; k<factor; k++){
	
	        int red = [reds[r] intValue];
	        int green = [greens[g] intValue];
	        int blue = [blues[b] intValue];
	
	        NSString * rgbString = [NSString stringWithFormat:@"%i,%i,%i",red,green,blue];
	        [flexibleColours addObject:rgbString];
	
	        b++;
	        if (b==flexFactor){ b=0; g++; }
	        if (g==flexFactor){ g=0; r++; }
	    }
	}
	
	NSMutableDictionary * colourCounter = [NSMutableDictionary new];
	
	NSCountedSet *countedSet = [[NSCountedSet alloc] initWithArray:flexibleColours];
	for (NSString *item in countedSet) {
	    NSUInteger count = [countedSet countForObject:item];
	    [colourCounter setValue:[NSNumber numberWithInteger:count] forKey:item];
	}
	
	NSArray *orderedKeys = [colourCounter keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2){
	    return [obj2 compare:obj1];
	}];
	
	NSMutableArray * ranges = [NSMutableArray new];
	for (NSString * key in orderedKeys){
	    NSArray * rgb = [key componentsSeparatedByString:@","];
	    int r = [rgb[0] intValue];
	    int g = [rgb[1] intValue];
	    int b = [rgb[2] intValue];
	    bool exclude = false;
	    for (NSString * ranged_key in ranges){
	        NSArray * ranged_rgb = [ranged_key componentsSeparatedByString:@","];
	
	        int ranged_r = [ranged_rgb[0] intValue];
	        int ranged_g = [ranged_rgb[1] intValue];
	        int ranged_b = [ranged_rgb[2] intValue];
	
	        if (r>= ranged_r-range && r<= ranged_r+range){
	            if (g>= ranged_g-range && g<= ranged_g+range){
	                if (b>= ranged_b-range && b<= ranged_b+range){
	                    exclude = true;
	                }
	            }
	        }
	    }
	
	    if (!exclude){ [ranges addObject:key]; }
	}
	
	NSMutableArray * colourArray = [NSMutableArray new];
	for (NSString * key in ranges){
	    NSArray * rgb = [key componentsSeparatedByString:@","];
	    float r = [rgb[0] floatValue];
	    float g = [rgb[1] floatValue];
	    float b = [rgb[2] floatValue];
	    UIColor * colour = [UIColor colorWithRed:(r/255.0f) green:(g/255.0f) blue:(b/255.0f) alpha:1.0f];
	    [colourArray addObject:colour];
	}
	
	return colourArray;
}

@end