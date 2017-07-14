#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <objc/runtime.h>

#import "../headers/libWeatherManager/RSWeatherCity.h"
#import "../headers/Weather/Weather.h"

@interface RSWeatherShortLookView : UIView {
	IBOutlet UILabel* cityName;
	IBOutlet UILabel* currentTemperature;
}

- (void)updateForCity:(RSWeatherCity*)city;

@end
