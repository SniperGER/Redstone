#import "RDSAccentColorList.h"

@implementation RDSAccentColorList

- (id)tableView:(UITableView *)arg1 cellForRowAtIndexPath:(NSIndexPath *)arg2 {
	PSTableCell *cell = (PSTableCell*)[super tableView:arg1 cellForRowAtIndexPath:arg2];
	
	if (![[[[cell specifier] values] objectAtIndex:0] isEqualToString:@"auto"]) {
		//[cell.imageView setImage:[self imageFromColor:[self colorFromHexString:cell.textLabel.text]]];
		[cell setBackgroundColor:[self colorFromHexString:cell.textLabel.text]];
		[cell.textLabel setHidden:YES];
	}
	
	return cell;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	settingsView = [[UIApplication sharedApplication] keyWindow];
	
	settingsView.tintColor = [UIColor redColor];
	self.navigationController.navigationBar.tintColor = [UIColor redColor];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	settingsView.tintColor = nil;
	self.navigationController.navigationBar.tintColor = nil;
}

- (UIImage *)imageFromColor:(UIColor *)color {
	CGRect rect = CGRectMake(0, 0, 29, 29);
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(context, [color CGColor]);
	CGContextFillRect(context, rect);
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
	unsigned rgbValue = 0;
	NSScanner *scanner = [NSScanner scannerWithString:hexString];
	[scanner setScanLocation:1]; // bypass '#' character
	[scanner scanHexInt:&rgbValue];
	return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
