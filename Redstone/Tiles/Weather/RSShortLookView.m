#import "RSShortLookView.h"

@implementation RSShortLookView

- (void)updateForCity:(City *)city {
	int userTemperatureUnit = [[objc_getClass("WeatherPreferences") sharedPreferences] userTemperatureUnit];
	int currentTemperatureValue = (int)[[city temperature] temperatureForUnit:userTemperatureUnit];
	
	[cityName setText:[city name]];
	[currentTemperature setText:[NSString stringWithFormat:@"%i°", currentTemperatureValue]];
}

@end
