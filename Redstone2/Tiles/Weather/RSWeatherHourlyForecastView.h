#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <objc/runtime.h>

#import "../headers/libWeatherManager/RSWeatherCity.h"
#import "../headers/Weather/Weather.h"

@interface RSWeatherHourlyForecastView : UIView {
	IBOutlet UILabel* hour1Label;
	IBOutlet UIImageView* hour1Image;
	IBOutlet UILabel* hour1Temperature;
	
	IBOutlet UILabel* hour2Label;
	IBOutlet UIImageView* hour2Image;
	IBOutlet UILabel* hour2Temperature;
	
	IBOutlet UILabel* hour3Label;
	IBOutlet UIImageView* hour3Image;
	IBOutlet UILabel* hour3Temperature;
	
	IBOutlet UILabel* cityName;
}

- (void)updateForCity:(RSWeatherCity*)city;

@end
