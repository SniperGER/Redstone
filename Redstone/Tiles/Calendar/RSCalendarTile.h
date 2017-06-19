#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#import "../headers/RSLiveTileDelegate.h"
#import "../headers/EventKitUI/CalendarModel.h"
#import "../headers/EventKitUI/EKCalendarDate.h"
#import "../headers/EventKit/EKEvent.h"

#import "RSCalendarRegularView.h"
#import "RSCalendarCompactView.h"
#import "RSCalendarEventView.h"

@interface RSCalendarTile : UIView <RSLiveTileDelegate> {
	RSCalendarRegularView* regularView;
	RSCalendarCompactView* compactView;
	RSCalendarEventView* eventView;
	
	CalendarModel* calendarModel;
	EKCalendarDate* currentCalendarDate;
}

@property (nonatomic, strong) RSTile* tile;

@end
