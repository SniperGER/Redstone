@class CLLocation;

@interface RSWeatherCity : NSObject

- (int)conditionCode;
- (float)windSpeed;
- (float)windDirection;
- (CLLocation*)location;
- (NSArray*)dayForecasts;
- (NSArray*)hourlyForecasts;
- (id)temperature;
- (id)name;
- (void)setName:(id)arg1;

@end
