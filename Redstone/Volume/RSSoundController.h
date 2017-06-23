#import <UIKit/UIKit.h>

@class RSVolumeHUD;

@interface RSSoundController : NSObject {
	RSVolumeHUD* volumeHUD;
}

@property (nonatomic, assign) BOOL isShowingVolumeHUD;
@property (nonatomic, assign) float ringerVolume;
@property (nonatomic, assign) float mediaVolume;
@property (nonatomic, assign) float headphoneVolume;

+ (id)sharedInstance;
- (void)volumeChanged:(double)volume forCategory:(NSString*)category increasingVolume:(BOOL)increase;
- (void)showVolumeHUDAnimated:(BOOL)animated;
- (void)hideVolumeHUDAnimated:(BOOL)animated;
- (float)ringerVolume;
- (float)mediaVolume;

@end
