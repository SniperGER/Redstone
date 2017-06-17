#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "../headers/Weather/Weather.h"

@interface RSHourlyForecastView : UIView {
	IBOutlet UILabel *cityName;
	
	IBOutlet UILabel *hour1Label;
	IBOutlet UIImageView *hour1Image;
	IBOutlet UILabel *hour1Temperature;
	
	IBOutlet UILabel *hour2Label;
	IBOutlet UIImageView *hour2Image;
	IBOutlet UILabel *hour2Temperature;
	
	
	IBOutlet UILabel *hour3Label;
	IBOutlet UIImageView *hour3Image;
	IBOutlet UILabel *hour3Temperature;
}

- (void)updateForCity:(City*)city;

@end
