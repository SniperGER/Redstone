#import <UIKit/UIKit.h>

@class RSVolumeView, RSVolumeSlider;

@interface RSVolumeHUD : UIWindow {
    NSTimer* slideOutTimer;
    RSVolumeView* volumeView;
	
	RSVolumeSlider* ringerSlider;
	RSVolumeSlider* mediaSlider;
	
	UILabel* ringerStatusText;
	RSTiltView* ringerStatusButton;
	UILabel* ringerVolumeLabel;
}

- (void)animateIn;
- (void)animateOut;
- (void)resetSlideOutTimer;
- (void)stopSlideOutTimer;
- (void)updateVolume;

@end
