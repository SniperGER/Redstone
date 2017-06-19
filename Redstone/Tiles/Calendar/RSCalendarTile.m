#import "RSCalendarTile.h"

@implementation RSCalendarTile

- (id)initWithFrame:(CGRect)frame tile:(RSTile *)tile {
	self = [super initWithFrame:frame];
	
	if (self) {
		NSBundle* tileBundle = [NSBundle bundleForClass:[self class]];
		
		regularView = [[tileBundle loadNibNamed:@"RegularView" owner:self options:nil] objectAtIndex:0];
		compactView = [[tileBundle loadNibNamed:@"CompactView" owner:self options:nil] objectAtIndex:0];
		eventView = [[tileBundle loadNibNamed:@"EventView" owner:self options:nil] objectAtIndex:0];
		
		calendarModel = [objc_getClass("CalendarModel") new];
		

	}
	
	return self;
}

- (void)update {
	NSDate* date = [NSDate date];
	NSCalendar* calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"EEEE"];
	
	[regularView.dayLabel setText:[dateFormatter stringFromDate:date]];
	[regularView.dateLabel setText:[NSString stringWithFormat:@"%lu", (long)[calendar component:NSCalendarUnitDay fromDate:date]]];
	
	[compactView.dayLabel setText:[dateFormatter stringFromDate:date]];
	[compactView.dateLabel setText:[NSString stringWithFormat:@"%lu", (long)[calendar component:NSCalendarUnitDay fromDate:date]]];
	
	NSMutableArray *visibleCalendars = [(NSArray *)[calendarModel valueForKey:@"_visibleCalendars"] mutableCopy];
	NSMutableSet *selectedCalendars = [NSMutableSet new];
	for (id obj in visibleCalendars) {
		[selectedCalendars addObject:obj];
	}
	
	calendarModel.selectedCalendars = [selectedCalendars copy];
	[calendarModel setMaxCachedDays:3];
	calendarModel.selectedCalendars = [NSSet setWithArray:(NSArray *)[calendarModel valueForKey:@"_visibleCalendars"]];
	[calendarModel setMaxCachedDays:3];
	
	currentCalendarDate = [NSClassFromString(@"EKCalendarDate") calendarDateWithDate:[NSDate date]
																			timeZone:[NSTimeZone defaultTimeZone]];
	NSArray* occurrences = [[calendarModel occurrencesForStartDay:[calendarModel.selectedDay componentsWithoutTime] endDay:[calendarModel.selectedDay componentsWithoutTime] preSorted:YES waitForLoad:YES] occurrences];
	
	if (occurrences.count > 0) {
		EKEvent* firstEvent = (EKEvent*)[occurrences objectAtIndex:0];
		
		[eventView updateForEvent:firstEvent];
	} else {
		[eventView updateForEvent:nil];
	}
}

- (BOOL)readyForDisplay {
	return YES;
}

- (NSArray*)viewsForSize:(int)size {
	switch (size) {
		case 1:
			return @[compactView];
		default:
			return (eventView.showsEvent) ? @[eventView] : @[regularView];
	}
}

- (CGFloat)updateInterval {
	return 30;
}

@end
