#import "RSHourlyForecastView.h"

@implementation RSHourlyForecastView

- (void)updateForCity:(City*)city {
	[cityName setText:[city name]];
	
	WAHourlyForecast* currentForecast = [[city hourlyForecasts] objectAtIndex:0];
	WAHourlyForecast* nextForecast = [[city hourlyForecasts] objectAtIndex:1];
	WAHourlyForecast* nextNextForecast = [[city hourlyForecasts] objectAtIndex:2];
	
	int userTemperatureUnit = [[objc_getClass("WeatherPreferences") sharedPreferences] userTemperatureUnit];
	
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"HH:mm"];
	NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	
	NSDate* currentDate = [dateFormatter dateFromString:[currentForecast time]];
	NSDate* nextDate = [dateFormatter dateFromString:[nextForecast time]];
	NSDate* nextNextDate = [dateFormatter dateFromString:[nextNextForecast time]];
	
	[hour1Label setText:[NSString stringWithFormat:@"%lu", (long)[gregorian component:NSCalendarUnitHour fromDate:currentDate]]];
	[hour1Image setImage:[self iconForCondition:(int)[currentForecast conditionCode] isDay:YES]];
	[hour1Temperature setText:[NSString stringWithFormat:@"%i°", (int)[[currentForecast temperature] temperatureForUnit:userTemperatureUnit]]];
	
	[hour2Label setText:[NSString stringWithFormat:@"%lu", (long)[gregorian component:NSCalendarUnitHour fromDate:nextDate]]];
	[hour2Image setImage:[self iconForCondition:(int)[nextForecast conditionCode] isDay:YES]];
	[hour2Temperature setText:[NSString stringWithFormat:@"%i°", (int)[[nextForecast temperature] temperatureForUnit:userTemperatureUnit]]];
	
	[hour3Label setText:[NSString stringWithFormat:@"%lu", (long)[gregorian component:NSCalendarUnitHour fromDate:nextNextDate]]];
	[hour3Image setImage:[self iconForCondition:(int)[nextNextForecast conditionCode] isDay:YES]];
	[hour3Temperature setText:[NSString stringWithFormat:@"%i°", (int)[[nextNextForecast temperature] temperatureForUnit:userTemperatureUnit]]];
}

- (NSString*)dayNightStringForCurrentVersion:(BOOL)isDay {
	return (isDay ? @"Day" : @"Night");
}

- (UIImage*)iconForCondition:(int)condition isDay:(BOOL)isDay {
	NSBundle* weatherFrameworkBundle = [NSBundle bundleForClass:[self class]];
	NSString* filename = @"";
	
	switch (condition) {
		case 0:
			filename = @"Tornado";
			break;
		case 1:
			filename = @"TropicalStorm";
			break;
		case 2:
			filename = @"Hurricane";
			break;
		case 3:
			filename = @"SevereThunderstorm";
			break;
		case 4:
		case 45:
			filename = @"MixRainfall";
			break;
		case 5:
		case 6:
		case 8:
		case 10:
		case 18:
			filename = @"Sleet";
			break;
		case 7:
			filename = @"Flurry";
			break;
		case 9:
			filename = @"Drizzle";
			break;
		case 11:
		case 12:
			filename = @"Rain";
			break;
		case 13:
		case 14:
		case 16:
		case 42:
		case 46:
			filename = @"FlurrySnowShower";
			break;
		case 15:
			filename = @"BlowingSnow";
			break;
		case 17:
		case 35:
			filename = [@"Hail" stringByAppendingString:[self dayNightStringForCurrentVersion:isDay]];
			break;
		case 19:
			filename = @"Dust";
			break;
		case 20:
			filename = @"Fog";
			break;
		case 21:
		case 22:
			filename = @"Smoke";
			break;
		case 23:
		case 25:
			filename = @"Ice";
			break;
		case 24:
			filename = @"Breezy";
			break;
		case 26:
		case 27:
		case 28:
			filename = @"MostlyCloudy";
			break;
		case 29:
			filename = [@"PartlyCloudy" stringByAppendingString:[self dayNightStringForCurrentVersion:NO]];
			break;
		case 30:
			filename = [@"PartlyCloudy" stringByAppendingString:[self dayNightStringForCurrentVersion:YES]];
			break;
		case 31:
		case 33:
			filename = @"ClearNight";
			break;
		case 32:
		case 34:
			filename = @"MostlySunny";
			break;
		case 36:
			filename = @"Hot";
			break;
		case 37:
		case 38:
		case 39:
		case 47:
			filename = [@"ScatteredThunderstorm" stringByAppendingString:[self dayNightStringForCurrentVersion:isDay]];
			break;
		case 40:
			filename = [@"ScatteredShowers" stringByAppendingString:[self dayNightStringForCurrentVersion:isDay]];
			break;
		case 41:
		case 43:
			filename = @"Blizzard";
			break;
		case 44:
			filename = [@"PartlyCloudy" stringByAppendingString:[self dayNightStringForCurrentVersion:isDay]];
			break;
		default:
			filename = @"NoReport";
			break;
	}
	
	NSString* finalPath = [NSString stringWithFormat:@"%@/%@", [weatherFrameworkBundle bundlePath], filename];
	
	return [UIImage imageWithContentsOfFile:finalPath];
}

@end
