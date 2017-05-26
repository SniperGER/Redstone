#import <UIKit/UIKit.h>

@class RSTiltView;

@interface RSLockScreenMediaControlsView : UIView {
	UILabel* mediaTitleLabel;
	UILabel* mediaSubtitleLabel;
	
	RSTiltView* prevTitleButton;
	RSTiltView* playPauseButton;
	RSTiltView* nextTitleButton;
}

- (void)updateNowPlayingInfo:(NSDictionary*)nowPlayingInfo;

@end
