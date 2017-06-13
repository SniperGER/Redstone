#import <UIKit/UIKit.h>

@class SBPasscodeNumberPadButton;

@interface RSLockScreenPasscodeEntryButton : UIView {
	UILabel* buttonLabel;
}

@property (nonatomic, strong) SBPasscodeNumberPadButton* numberPadButton;
@property (nonatomic, assign) BOOL isBackSpaceButton;

- (void)setButtonLabelText:(NSString*)buttonLabelText;

@end
