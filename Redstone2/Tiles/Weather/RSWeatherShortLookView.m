#import "RSWeatherShortLookView.h"

@implementation RSWeatherShortLookView

- (void)updateForCity:(RSWeatherCity*)city {
	int userTemperatureUnit = [[objc_getClass("WeatherPreferences") sharedPreferences] userTemperatureUnit];
	int currentTemperatureValue = (int)[[city temperature] temperatureForUnit:userTemperatureUnit];
	
	[currentTemperature setText:[NSString stringWithFormat:@"%i°", currentTemperatureValue]];
	
	[cityName setText:[city name]];}

@end
