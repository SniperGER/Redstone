#import <UIKit/UIKit.h>

typedef void (^MRMediaRemoteGetNowPlayingInfoCompletion)(CFDictionaryRef information);
void MRMediaRemoteGetNowPlayingInfo(dispatch_queue_t queue, MRMediaRemoteGetNowPlayingInfoCompletion completion);

@class SBMediaController, AVSystemController, RSVolumeHUD;

@interface RSSoundController : NSObject {
	SBMediaController* mediaController;
	AVSystemController* audioVideoController;
	
	RSVolumeHUD* volumeHUD;
	
	__block BOOL isPlaying;
	__block UIImage* artwork;
	__block NSString* artist;
	__block NSString* title;
	__block NSString* album;
}

@property (nonatomic, assign) float ringerVolume;
@property (nonatomic, assign) float mediaVolume;
@property (nonatomic, assign) BOOL isShowingVolumeHUD;

+ (id)sharedInstance;
- (void)volumeChanged:(float)volume forCategory:(NSString*)category increasingVolume:(BOOL)isIncreasing;
- (void)showVolumeHUDAnimated:(BOOL)animated;
- (void)hideVolumeHUDAnimated:(BOOL)animated;

- (void)updateNowPlayingInfo:(id)sender;
- (RSVolumeHUD*)volumeHUD;

- (BOOL)isPlaying;
- (UIImage*)artwork;
- (NSString*)artist;
- (NSString*)title;
- (NSString*)album;

@end
