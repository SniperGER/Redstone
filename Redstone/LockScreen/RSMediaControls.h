#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

typedef void (^MRMediaRemoteGetNowPlayingInfoCompletion)(CFDictionaryRef information);
void MRMediaRemoteGetNowPlayingInfo(dispatch_queue_t queue, MRMediaRemoteGetNowPlayingInfoCompletion completion);

@interface RSMediaControls : UIView {
	UILabel* mediaTitleLabel;
	UILabel* mediaArtistLabel;
	
	UIButton* playPauseButton;
	UIButton* prevButton;
	UIButton* nextButton;
}

- (void)updateNowPlayingInfo:(NSDictionary*)nowPlayingInfo;

@end
