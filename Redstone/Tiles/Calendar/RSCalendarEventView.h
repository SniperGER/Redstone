#import <UIKit/UIKit.h>
#import "../headers/EventKit/EKEvent.h"

@interface RSCalendarEventView : UIView {
	
	IBOutlet UILabel *eventTitle;
	IBOutlet UILabel *eventTime;
	IBOutlet UILabel *eventDate;
}

@property (nonatomic, assign) BOOL showsEvent;

- (void)updateForEvent:(EKEvent*)event;

@end
