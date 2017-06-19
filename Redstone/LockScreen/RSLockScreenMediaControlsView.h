#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

typedef void (^MRMediaRemoteGetNowPlayingInfoCompletion)(CFDictionaryRef information);
void MRMediaRemoteGetNowPlayingInfo(dispatch_queue_t queue, MRMediaRemoteGetNowPlayingInfoCompletion completion);

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
