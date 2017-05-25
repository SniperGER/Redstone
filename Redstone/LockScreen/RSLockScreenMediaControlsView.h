#import <UIKit/UIKit.h>

@interface RSLockScreenMediaControlsView : UIView {
	UILabel* mediaTitleLabel;
	UILabel* mediaSubtitleLabel;
	
	UIButton* prevTitleButton;
	UIButton* playPauseButton;
	UIButton* nextTitleButton;
}

- (void)updateNowPlayingInfo:(NSDictionary*)nowPlayingInfo;

@end
