#import <UIKit/UIKit.h>

@class RSVolumeHUD;

@interface RSSoundController : NSObject {
	float ringerVolume;
	float mediaVolume;
	
	RSVolumeHUD* volumeHUD;
}

@property (nonatomic, assign) BOOL isShowingVolumeHUD;

+ (id)sharedInstance;
- (void)volumeChanged:(double)volume forCategory:(NSString*)category increasingVolume:(BOOL)increase;
- (float)ringerVolume;
- (float)mediaVolume;

@end
