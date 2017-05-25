#import <UIKit/UIKit.h>

@interface RSLockScreenView : UIView {
	UILabel* timeLabel;
	UILabel* dateLabel;
}

- (void)setTime:(NSString*)time;
- (void)setDate:(NSString*)date;

@end
