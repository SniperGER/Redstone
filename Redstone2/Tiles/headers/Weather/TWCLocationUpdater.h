#import "TWCCityUpdater.h"

@class City, CLGeocoder;

@interface TWCLocationUpdater : TWCCityUpdater {
	
	City* _currentCity;
	CLGeocoder* _reverseGeocoder;
	
}

@property (nonatomic,retain) CLGeocoder * reverseGeocoder;              //@synthesize reverseGeocoder=_reverseGeocoder - In the implementation block
@property (nonatomic,retain) City * currentCity;                        //@synthesize currentCity=_currentCity - In the implementation block
+(id)sharedLocationUpdater;
-(void)updateWeatherForCity:(id)arg1 ;
-(void)updateWeatherForCities:(id)arg1 withCompletionHandler:(/*^block*/id)arg2 ;
-(void)updateWeatherForLocation:(id)arg1 city:(id)arg2 ;
-(void)_updateWeatherForLocation:(id)arg1 city:(id)arg2 completionHandler:(/*^block*/id)arg3 ;
-(void)setCurrentCity:(City *)arg1 ;
-(void)_geocodeLocation:(id)arg1 currentCity:(id)arg2 completionHandler:(/*^block*/id)arg3 ;
-(CLGeocoder *)reverseGeocoder;
-(void)setReverseGeocoder:(CLGeocoder *)arg1 ;
-(void)_completeReverseGeocodeForLocation:(id)arg1 currentCity:(id)arg2 geocodeError:(id)arg3 completionHandler:(/*^block*/id)arg4 ;
-(void)parsedResultCity:(id)arg1 ;
-(void)enableProgressIndicator:(BOOL)arg1 ;
-(void)updateWeatherForLocation:(id)arg1 city:(id)arg2 withCompletionHandler:(/*^block*/id)arg3 ;
-(City *)currentCity;
@end
