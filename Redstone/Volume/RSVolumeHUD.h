#import <UIKit/UIKit.h>

@class RSVolumeView, RSVolumeSlider;

@interface RSVolumeHUD : UIWindow {
    NSTimer* slideOutTimer;
    RSVolumeView* volumeView;
	
	RSVolumeSlider* ringerSlider;
	UILabel* ringerStatusText;
	RSTiltView* ringerStatusButton;
	UILabel* ringerVolumeLabel;
	
	RSVolumeSlider* mediaSlider;
	UILabel* mediaStatusText;
	RSTiltView* mediaStatusButton;
	UILabel* mediaVolumeLabel;
	
	RSTiltView* expandButton;
	BOOL expanded;
}

- (void)animateIn;
- (void)animateOut;
- (void)resetSlideOutTimer;
- (void)stopSlideOutTimer;
- (void)updateVolume;
- (void)toggleExpanded;

@end
