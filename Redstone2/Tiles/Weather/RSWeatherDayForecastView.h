#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <objc/runtime.h>

#import "../headers/libWeatherManager/RSWeatherCity.h"
#import "../headers/Weather/Weather.h"

@interface RSWeatherDayForecastView : UIView {
	IBOutlet UILabel* day1Label;
	IBOutlet UIImageView* day1Image;
	IBOutlet UILabel* day1High;
	IBOutlet UILabel* day1Low;
	
	IBOutlet UILabel* day2Label;
	IBOutlet UIImageView* day2Image;
	IBOutlet UILabel* day2High;
	IBOutlet UILabel* day2Low;
	
	IBOutlet UILabel* day3Label;
	IBOutlet UIImageView* day3Image;
	IBOutlet UILabel* day3High;
	IBOutlet UILabel* day3Low;
	
	IBOutlet UILabel* cityName;
}

- (void)updateForCity:(RSWeatherCity*)city;

@end
