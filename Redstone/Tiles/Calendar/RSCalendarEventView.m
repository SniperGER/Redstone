#import "RSCalendarEventView.h"

@implementation RSCalendarEventView

- (void)updateForEvent:(EKEvent*)event {
	self.showsEvent = (event != nil);
	
	[eventTitle setText:[event title]];
	
	if ([event _isAllDay]) {
		NSBundle* strings = [NSBundle bundleWithPath:@"/System/Library/Frameworks/EventKitUI.framework"];
		[eventTime setText:[strings localizedStringForKey:@"All day" value:@"All day" table:@"Localizable"]];
	} else {
		NSDate* date = [event occurrenceDate];
		NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"HH:mm"];
		
		[eventTime setText:[dateFormatter stringFromDate:date]];
	}
	
	NSDate* date = [event occurrenceDate];
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"EEEE dd"];
	[eventDate setText:[dateFormatter stringFromDate:date]];
}

@end
