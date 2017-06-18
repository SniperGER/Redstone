#import "RSDayForecastView.h"

@implementation RSDayForecastView

- (void)updateForCity:(City*)city {
	[cityName setText:[city name]];
	
	WADayForecast* currentDayForecast = [[city dayForecasts] objectAtIndex:0];
	WADayForecast* nextDayForecast = [[city dayForecasts] objectAtIndex:1];
	WADayForecast* nextNextDayForecast = [[city dayForecasts] objectAtIndex:2];
	
	int userTemperatureUnit = [[objc_getClass("WeatherPreferences") sharedPreferences] userTemperatureUnit];
	
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"e"];
	
	NSDate* currentDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%llu", [currentDayForecast dayOfWeek]]];
	NSDate* nextDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%llu", [nextDayForecast dayOfWeek]]];
	NSDate* nextNextDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%llu", [nextNextDayForecast dayOfWeek]]];
	
	[dateFormatter setDateFormat:@"EEEE"];
	
	NSString* currentDay = [[dateFormatter stringFromDate:currentDate] substringWithRange:NSMakeRange(0, 3)];
	NSString* nextDay = [[dateFormatter stringFromDate:nextDate] substringWithRange:NSMakeRange(0, 3)];
	NSString* nextNextDay = [[dateFormatter stringFromDate:nextNextDate] substringWithRange:NSMakeRange(0, 3)];
	
	[day1Label setText:currentDay];
	[day1High setText:[NSString stringWithFormat:@"%i°", (int)[[currentDayForecast high] temperatureForUnit:userTemperatureUnit]]];
	[day1Low setText:[NSString stringWithFormat:@"%i°", (int)[[currentDayForecast low] temperatureForUnit:userTemperatureUnit]]];
	[day1Image setImage:[self iconForCondition:(int)[city conditionCode] isDay:YES]];
	
	[day2Label setText:nextDay];
	[day2High setText:[NSString stringWithFormat:@"%i°", (int)[[nextDayForecast high] temperatureForUnit:userTemperatureUnit]]];
	[day2Low setText:[NSString stringWithFormat:@"%i°", (int)[[nextDayForecast low] temperatureForUnit:userTemperatureUnit]]];
	[day2Image setImage:[self iconForCondition:(int)[nextDayForecast icon] isDay:YES]];
	
	[day3Label setText:nextNextDay];
	[day3High setText:[NSString stringWithFormat:@"%i°", (int)[[nextNextDayForecast high] temperatureForUnit:userTemperatureUnit]]];
	[day3Low setText:[NSString stringWithFormat:@"%i°", (int)[[nextNextDayForecast low] temperatureForUnit:userTemperatureUnit]]];
	[day3Image setImage:[self iconForCondition:(int)[nextNextDayForecast icon] isDay:YES]];
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
			filename = (isDay) ? @"MostlySunny" : @"ClearNight";
			break;
		case 32:
		case 34:
			filename = (isDay) ? @"MostlySunny" : @"ClearNight";
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
