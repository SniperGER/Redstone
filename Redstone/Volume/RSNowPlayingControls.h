#import <UIKit/UIKit.h>

@class RSTiltView;

@interface RSNowPlayingControls : UIView {
	UILabel* mediaTitleLabel;
	UILabel* mediaSubtitleLabel;
	
	RSTiltView* prevTitleButton;
	RSTiltView* playPauseButton;
	RSTiltView* nextTitleButton;
}

- (void)setLightTextEnabled:(BOOL)lightText;
- (void)updateNowPlayingInfo;

@end
