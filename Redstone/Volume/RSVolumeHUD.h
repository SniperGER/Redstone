#import <UIKit/UIKit.h>

@class RSTiltView, RSVolumeView, RSVolumeSlider, RSNowPlayingControls;

@interface RSVolumeHUD : UIWindow {
	NSTimer* slideOutTimer;
	RSTiltView* expandButton;
	
	RSVolumeView* ringerVolumeView;
	RSVolumeView* mediaVolumeView;
	RSVolumeView* headphoneVolumeView;
	
	RSVolumeSlider* ringerSlider;
	RSVolumeSlider* mediaSlider;
	RSVolumeSlider* headphoneSlider;
	
	RSTiltView* ringerMuteButton;
	RSTiltView* mediaMuteButton;
	RSTiltView* headphoneMuteButton;
	
	RSNowPlayingControls* nowPlayingControls;
	
	UIButton* vibrateButton;
	UIButton* ringerButton;
}

@property (nonatomic, assign) BOOL isExpanded;
@property (nonatomic, assign) BOOL isShowingMediaControls;
@property (nonatomic, assign) BOOL isShowingHeadphoneVolume;

- (void)animateIn;
- (void)animateOut;
- (void)stopSlideOutTimer;
- (void)resetSlideOutTimer;

- (void)updateVolume;

@end
