#import <UIKit/UIKit.h>
#import "../../StartScreen/RSLiveTileInterface.h"
#import "../headers/Weather/Weather.h"
#import "../headers/libWeatherManager/RSWeatherCity.h"

#import "RSWeatherShortLookView.h"
#import "RSWeatherConditionView.h"
#import "RSWeatherHourlyForecastView.h"
#import "RSWeatherDayForecastView.h"

@class RSWeatherInfoManager;
@protocol RSWeatherInfoManagerDelegate <NSObject>
@optional
- (void)weatherInfoManager:(RSWeatherInfoManager *)weatherInfoManager didUpdateWeather:(RSWeatherCity *)city;
- (void)weatherInfoManager:(RSWeatherInfoManager *)weatherInfoManager didFailWithError:(NSError *)error;
@end

@interface RSWeatherInfoManager : NSObject
@property (nonatomic, assign) id <RSWeatherInfoManagerDelegate>delegate;

- (id)initWithDelegate:(id <RSWeatherInfoManagerDelegate>)delegate;
- (BOOL)isMonitoringWeatherChangesForLocation:(CLLocation *)location;
- (void)startMonitoringCurrentLocationWeatherChanges;
- (void)startMonitoringWeatherChangesForLocation:(CLLocation *)location;
- (void)stopMonitoringCurrentLocationWeatherChanges;
- (void)stopMonitoringWeatherChangesForLocation:(CLLocation *)location;
@end

@interface RSWeatherTile : UIView <RSLiveTileInterface, RSWeatherInfoManagerDelegate> {
	RSWeatherInfoManager* weatherManager;
	RSWeatherCity* currentCity;
	
	RSWeatherShortLookView* shortLookView;
	RSWeatherConditionView* conditionView;
	RSWeatherHourlyForecastView* hourlyForecastView;
	RSWeatherDayForecastView* dayForecastView;
}

@property (nonatomic, strong) RSTile* tile;

@end
