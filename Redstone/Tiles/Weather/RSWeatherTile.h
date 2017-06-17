#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <objc/runtime.h>

#import "../headers/RSLiveTileDelegate.h"
#import "../headers/Weather/Weather.h"
#import "Reachability.h"
#import "RSShortLookView.h"
#import "RSConditionView.h"
#import "RSHourlyForecastView.h"
#import "RSDayForecastView.h"

@interface RSWeatherTile : UIView <RSLiveTileDelegate, CLLocationManagerDelegate> {
	BOOL isUpdatingWeatherData;
	
	WeatherPreferences* weatherPreferences;
	WeatherLocationManager* weatherLocationManager;
	
	City* currentCity;
	
	NSTimer* locationUpdateTimer;
	NSTimer* weatherDataUpdateTimer;
	
	RSShortLookView* shortLookView;
	RSConditionView* conditionView;
	RSHourlyForecastView* hourlyForecastView;
	RSDayForecastView* dayForecastView;
}

@property (nonatomic, strong) RSTile* tile;

@end
