#import "RSWeatherTile.h"

@implementation RSWeatherTile

- (id)initWithFrame:(CGRect)frame tile:(RSTile*)tile {
	self = [super initWithFrame:frame];
	
	if (self) {
		//dlopen("/System/Library/PrivateFrameworks/Weather.framework/Weather", RTLD_NOW);
		
		weatherPreferences = [objc_getClass("WeatherPreferences") sharedPreferences];
		weatherLocationManager = [objc_getClass("WeatherLocationManager") sharedWeatherLocationManager];
		
		[weatherLocationManager setDelegate:self];
		
		self.tile = tile;
		currentCity = [[objc_getClass("City") alloc] init];
		
		NSBundle* tileBundle = [NSBundle bundleForClass:[self class]];
		shortLookView = [[tileBundle loadNibNamed:@"ShortLookView" owner:self options:nil] objectAtIndex:0];
		conditionView = [[tileBundle loadNibNamed:@"ConditionView" owner:self options:nil] objectAtIndex:0];
		hourlyForecastView = [[tileBundle loadNibNamed:@"HourlyForecastView" owner:self options:nil] objectAtIndex:0];
		dayForecastView = [[tileBundle loadNibNamed:@"DayForecastView" owner:self options:nil] objectAtIndex:0];
	}
	
	return self;
}

- (void)update {
	isUpdatingWeatherData = YES;

	
	[self requestWeatherDataUpdate];
}

- (BOOL)isConnectedToInternet {
	Reachability* networkReachability = [Reachability reachabilityForInternetConnection];
	NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
	
	return networkStatus != NotReachable;
}

- (void)requestWeatherDataUpdate {
	/*if ([weatherPreferences isLocalWeatherEnabled] && [weatherPreferences localWeatherCity]) {
		currentCity = [weatherPreferences localWeatherCity];
	} else {
		currentCity = [[weatherPreferences loadSavedCities] objectAtIndex:[weatherPreferences loadActiveCity]];
	}*/
	
	if (![self isConnectedToInternet]) {
		isUpdatingWeatherData = NO;
		[self.tile setLiveTileHidden:YES];
		
		return;
	}
	
	if ([currentCity updateTime]) {
		NSDate* updateTime = [currentCity updateTime];
		
		if ([[NSDate date] compare:[updateTime dateByAddingTimeInterval:900]] != NSOrderedDescending) {
			isUpdatingWeatherData = NO;
			[conditionView updateForCity:currentCity];
			
			return;
		} else {
			[self.tile setLiveTileHidden:YES];
		}
	}
	
	if ([weatherPreferences isLocalWeatherEnabled]) {
		[weatherLocationManager setLocationTrackingIsReady:YES];
		[weatherLocationManager setLocationTrackingActive:YES];
		[weatherLocationManager setLocationTrackingReady:YES activelyTracking:YES watchKitExtension:NO];
		
		locationUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(locationDidUpdate) userInfo:nil repeats:YES];
		[self locationDidUpdate];
	} else {
		City* staticCity = [[weatherPreferences loadSavedCities] objectAtIndex:[weatherPreferences loadActiveCity]];
		
		[currentCity setName:[staticCity name]];
		[currentCity setLocation:[staticCity location]];
		[currentCity update];
		
		weatherDataUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(weatherDataDidUpdate) userInfo:nil repeats:YES];
		[self weatherDataDidUpdate];
	}
}

- (void)locationDidUpdate {
	if ([weatherLocationManager location] != nil) {
		[locationUpdateTimer invalidate];
		locationUpdateTimer = nil;
		
		[currentCity setIsLocalWeatherCity:YES];
		[currentCity setLocation:[weatherLocationManager location]];
		[currentCity update];
		
		/*[weatherLocationManager setLocationTrackingIsReady:NO];
		[weatherLocationManager setLocationTrackingActive:NO];
		[weatherLocationManager setLocationTrackingReady:NO activelyTracking:NO watchKitExtension:NO];*/
		
		weatherDataUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(weatherDataDidUpdate) userInfo:nil repeats:YES];
		[self weatherDataDidUpdate];
	}
}

- (void)weatherDataDidUpdate {
	if ([[currentCity hourlyForecasts] count] > 0) {
		isUpdatingWeatherData = NO;
		
		[weatherDataUpdateTimer invalidate];
		weatherDataUpdateTimer = nil;
		
		[shortLookView updateForCity:currentCity];
		[conditionView updateForCity:currentCity];
		[hourlyForecastView updateForCity:currentCity];
		[dayForecastView updateForCity:currentCity];
		
		[self.tile setLiveTileHidden:NO animated:YES];
	}
}

- (BOOL)readyForDisplay {
	return !isUpdatingWeatherData;
}

- (NSArray*)viewsForSize:(int)size {
	switch (size) {
		case 1:
			return @[shortLookView];
		case 2:
			return @[conditionView, hourlyForecastView];
		case 3:
			return @[conditionView, dayForecastView];
		default:
			return @[];
	}
}

- (CGFloat)updateInterval {
	return 300;
}

@end
