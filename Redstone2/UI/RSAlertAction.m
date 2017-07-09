#import "../Redstone.h"

@implementation RSAlertAction

+ (id)actionWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(void (^)(void))handler {
	RSAlertAction* action = [[RSAlertAction alloc] initWithFrame:CGRectZero];
	[action.titleLabel setFont:[UIFont fontWithName:@"SegoeUI" size:17]];
	[action.titleLabel setTextColor:[RSAesthetics colorsForCurrentTheme][@"ForegroundColor"]];
	[action.titleLabel setText:title];
	[action setHighlightEnabled:YES];
	[action setBackgroundColor:[RSAesthetics colorsForCurrentTheme][@"ButtonColor"]];
	
	action.handler = handler;
	
	return action;
}

@end
