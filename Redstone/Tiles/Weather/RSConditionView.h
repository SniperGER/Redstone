#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "../headers/Weather/Weather.h"

#define deg2rad(angle) ((angle) / 180.0 * M_PI)

@interface RSConditionView : UIView {
	IBOutlet UILabel *currentCondition;
	IBOutlet UILabel *currentTemperature;
	IBOutlet UILabel *cityName;
	IBOutlet UILabel *highTemp;
	IBOutlet UILabel *lowTemp;
	IBOutlet UILabel *percentPrecipitation;
	IBOutlet UILabel *windSpeed;
	IBOutlet UIImageView *windIcon;
}

- (void)updateForCity:(City*)city;

@end
