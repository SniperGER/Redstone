#import "RSWeatherTile.h"

@interface RSTile : NSObject

- (void)setLiveTileHidden:(BOOL)arg1 animated:(BOOL)arg2;

@end

@implementation RSWeatherTile

- (id)initWithFrame:(CGRect)frame tile:(RSTile *)tile {
	if (self = [super initWithFrame:frame]) {
		self.tile = tile;
		
		NSBundle* tileBundle = [NSBundle bundleForClass:[self class]];
		shortLookView = [[tileBundle loadNibNamed:@"ShortLookView" owner:self options:nil] objectAtIndex:0];
		conditionView = [[tileBundle loadNibNamed:@"ConditionView" owner:self options:nil] objectAtIndex:0];
		hourlyForecastView = [[tileBundle loadNibNamed:@"HourlyForecastView" owner:self options:nil] objectAtIndex:0];
		dayForecastView = [[tileBundle loadNibNamed:@"DayForecastView" owner:self options:nil] objectAtIndex:0];
		
		weatherManager = [[objc_getClass("RSWeatherInfoManager") alloc] initWithDelegate:self];
		[weatherManager startMonitoringCurrentLocationWeatherChanges];
	}
	
	return self;
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
			break;
	}
	
	return nil;
}

- (BOOL)readyForDisplay {
	return (currentCity != nil);
}

- (CGFloat)updateInterval {
	return 0;
}

- (void)update {
	return;
}

- (void)weatherInfoManager:(RSWeatherInfoManager *)weatherInfoManager didUpdateWeather:(RSWeatherCity *)city {
	
	CLGeocoder *geocoder = [[CLGeocoder alloc] init];
	[geocoder reverseGeocodeLocation:[city location] completionHandler:^(NSArray *placemarks, NSError *error) {
		if (placemarks && placemarks.count > 0) {
			CLPlacemark *placemark = placemarks[0];
			NSDictionary *addressDictionary = placemark.addressDictionary;
			
			[city setName:[addressDictionary objectForKey:@"City"]];
			
			[shortLookView updateForCity:city];
			[conditionView updateForCity:city];
			[hourlyForecastView updateForCity:city];
			[dayForecastView updateForCity:city];
			
			if (currentCity == nil) {
				[self.tile setLiveTileHidden:NO animated:YES];
			}
			
			currentCity = city;
		}
	}];
}

- (void)prepareForRemoval {
	[weatherManager stopMonitoringCurrentLocationWeatherChanges];
	weatherManager = nil;
}

@end
