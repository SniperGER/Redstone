#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "../headers/Weather/Weather.h"

@interface RSDayForecastView : UIView {
	IBOutlet UILabel *cityName;
	
	IBOutlet UILabel *day1Label;
	IBOutlet UIImageView *day1Image;
	IBOutlet UILabel *day1High;
	IBOutlet UILabel *day1Low;
	
	IBOutlet UILabel *day2Label;
	IBOutlet UIImageView *day2Image;
	IBOutlet UILabel *day2High;
	IBOutlet UILabel *day2Low;
	
	IBOutlet UILabel *day3Label;
	IBOutlet UIImageView *day3Image;
	IBOutlet UILabel *day3High;
	IBOutlet UILabel *day3Low;
}

- (void)updateForCity:(City*)city;

@end
