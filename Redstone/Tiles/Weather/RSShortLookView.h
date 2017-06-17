#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "../headers/Weather/Weather.h"

@interface RSShortLookView : UIView {
	IBOutlet UILabel *currentTemperature;
	IBOutlet UILabel *cityName;
}

- (void)updateForCity:(City*)city;

@end
