#import "RSWeatherConditionView.h"

@implementation RSWeatherConditionView

- (void)updateForCity:(RSWeatherCity*)city {
	[currentCondition setText:[self localizedConditionForCode:[city conditionCode]]];
	WADayForecast* currentDayForecast = [[city dayForecasts] objectAtIndex:0];
	WAHourlyForecast* currentHourForecast = [[city hourlyForecasts] objectAtIndex:0];
	
	int userTemperatureUnit = [[objc_getClass("WeatherPreferences") sharedPreferences] userTemperatureUnit];
	int currentTemperatureValue = (int)[[city temperature] temperatureForUnit:userTemperatureUnit];
	int highTempValue = (int)[[currentDayForecast high] temperatureForUnit:userTemperatureUnit];
	int lowTempValue = (int)[[currentDayForecast low] temperatureForUnit:userTemperatureUnit];
	int precipitationValue = round([currentHourForecast percentPrecipitation]);
	
	[currentTemperature setText:[NSString stringWithFormat:@"%i°", currentTemperatureValue]];
	
	[highTemp setText:[NSString stringWithFormat:@"%i°", highTempValue]];
	[lowTemp setText:[NSString stringWithFormat:@"%i°", lowTempValue]];
	
	[percentPrecipitation setText:[NSString stringWithFormat:@"%i%%", precipitationValue]];
	
	NSString* windSpeedValue = [[objc_getClass("WeatherWindSpeedFormatter") convenienceFormatter] stringForWindSpeed:[city windSpeed]];
	[windSpeed setText:windSpeedValue];
	[windIcon setTransform:CGAffineTransformMakeRotation(deg2rad([city windDirection]))];
	
	[cityName setText:[city name]];
}

- (NSString*)localizedConditionForCode:(NSInteger)code {
	NSBundle* strings = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/Weather.framework"];
	NSString* conditionString = @"";
	
	switch (code) {
		case 0:
			conditionString = @"WeatherConditionTornado";
			break;
		case 1:
			conditionString = @"WeatherConditionTropicalStorm";
			break;
		case 2:
			conditionString = @"WeatherConditionHurricane";
			break;
		case 3:
			conditionString = @"WeatherConditionSevereThunderstorm";
			break;
		case 4:
			conditionString = @"WeatherConditionThunderstorm";
			break;
		case 5:
			conditionString = @"WeatherConditionMixedRainAndSnow";
			break;
		case 6:
			conditionString = @"WeatherConditionMixedRainAndSleet";
			break;
		case 7:
			conditionString = @"WeatherConditionMixedSnowAndSleet";
			break;
		case 8:
			conditionString = @"WeatherConditionFreezingDrizzle";
			break;
		case 9:
			conditionString = @"WeatherConditionDrizzle";
			break;
		case 10:
			conditionString = @"WeatherConditionFreezingRain";
			break;
		case 11:
			conditionString = @"WeatherConditionShowers1";
			break;
		case 12:
			conditionString = @"WeatherConditionRain";
			break;
		case 13:
			conditionString = @"WeatherConditionSnowFlurries";
			break;
		case 14:
			conditionString = @"WeatherConditionSnowShowers";
			break;
		case 15:
			conditionString = @"WeatherConditionBlowingSnow";
			break;
		case 16:
			conditionString = @"WeatherConditionSnow";
			break;
		case 17:
			conditionString = @"WeatherConditionHail";
			break;
		case 18:
			conditionString = @"WeatherConditionSleet";
			break;
		case 19:
			conditionString = @"WeatherConditionDust";
			break;
		case 20:
			conditionString = @"WeatherConditionFog";
			break;
		case 21:
			conditionString = @"WeatherConditionHaze";
			break;
		case 22:
			conditionString = @"WeatherConditionSmoky";
			break;
		case 23:
			conditionString = @"WeatherConditionBreezy";
			break;
		case 24:
			conditionString = @"WeatherConditionWindy";
			break;
		case 25:
			conditionString = @"WeatherConditionFrigid";
			break;
		case 26:
			conditionString = @"WeatherConditionCloudy";
			break;
		case 27:
			conditionString = @"WeatherConditionMostlyCloudyNight";
			break;
		case 28:
			conditionString = @"WeatherConditionMostlyCloudyDay";
			break;
		case 29:
			conditionString = @"WeatherConditionPartlyCloudyNight";
			break;
		case 30:
			conditionString = @"WeatherConditionPartlyCloudyDay";
			break;
		case 31:
			conditionString = @"WeatherConditionClearNight";
			break;
		case 32:
			conditionString = @"WeatherConditionSunny";
			break;
		case 33:
			conditionString = @"WeatherConditionMostlySunnyNight";
			break;
		case 34:
			conditionString = @"WeatherConditionMostlySunnyDay";
			break;
		case 35:
			conditionString = @"WeatherConditionMixedRainFall";
			break;
		case 36:
			conditionString = @"WeatherConditionHot";
			break;
		case 37:
			conditionString = @"WeatherConditionIsolatedThunderstorms";
			break;
		case 38:
			conditionString = @"WeatherConditionScatteredThunderstorms";
			break;
		case 39:
			conditionString = @"WeatherConditionScatteredShowers";
			break;
		case 40:
			conditionString = @"WeatherConditionHeavyRain";
			break;
		case 41:
			conditionString = @"WeatherConditionScatteredSnowShowers";
			break;
		case 42:
			conditionString = @"WeatherConditionHeavySnow";
			break;
		case 43:
			conditionString = @"WeatherConditionBlizzard";
			break;
		case 44:
			conditionString = @"NotAvailable";
			break;
		case 45:
			conditionString = @"WeatherConditionScatteredShowers";
			break;
		case 46:
			conditionString = @"WeatherConditionScatteredSnowShowers";
			break;
		case 47:
			conditionString = @"WeatherConditionIsolatedThundershowers";
			break;
		default: break;
	}
	
	return [strings localizedStringForKey:conditionString value:conditionString table:@"WeatherFrameworkLocalizableStrings"];
}

@end
