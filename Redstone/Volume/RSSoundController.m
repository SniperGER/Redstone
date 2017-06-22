#import "../Redstone.h"

@implementation RSSoundController

static RSSoundController* sharedInstance;

+ (id)sharedInstance {
    return sharedInstance;
}

- (id)init {
    self = [super init];
    
    if (self) {
        sharedInstance = self;
		
		[[objc_getClass("AVSystemController") sharedAVSystemController] getVolume:&ringerVolume forCategory:@"Ringtone"];
		[[objc_getClass("AVSystemController") sharedAVSystemController] getVolume:&mediaVolume forCategory:@"Audio/Video"];
		
        volumeHUD = [[RSVolumeHUD alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 100)];
    }
    
    return self;
}

- (void)volumeChanged:(double)volume forCategory:(NSString*)category increasingVolume:(BOOL)increase {
	if (self.isShowingVolumeHUD) {
		if ([category isEqualToString:@"Ringtone"]) {
			if (increase && ringerVolume == 0.0 && volume <= ((1.0/16.0)*2)) {
				ringerVolume = 1.0/16.0;
				[[objc_getClass("AVSystemController") sharedAVSystemController] setVolumeTo:ringerVolume forCategory:@"Ringtone"];
			} else if (!increase && volume == 1.0/16.0 && volume == ringerVolume) {
				ringerVolume = 0.0;
				[[objc_getClass("AVSystemController") sharedAVSystemController] setVolumeTo:ringerVolume forCategory:@"Ringtone"];
			} else if(!increase && ringerVolume == 0.0) {
				ringerVolume = 0.0;
				[[objc_getClass("AVSystemController") sharedAVSystemController] setVolumeTo:ringerVolume forCategory:@"Ringtone"];
			} else {
				ringerVolume = volume;
			}
		} else if ([category isEqualToString:@"Audio/Video"]) {
			mediaVolume = volume;
		}
	}
	
	if (!self.isShowingVolumeHUD && [self canDisplayHUD]) {
		[self showVolumeHUDAnimated:YES];
	} else {
		if (!self.isShowingVolumeHUD && ![self canDisplayHUD]) {
			//[volumeHUD animateInAfterRemovalWasCancelled];
		} else {
			if (self.isShowingVolumeHUD) {
				if (![self canDisplayHUD]) {
					[volumeHUD animateOut];
				} else {
					[volumeHUD updateVolume];
					[volumeHUD resetSlideOutTimer];
				}
			}
		}
		[volumeHUD resetSlideOutTimer];
	}
}

- (BOOL)canDisplayHUD {
	if ([[objc_getClass("SpringBoard") sharedApplication] _isDim] || [[objc_getClass("SBUserAgent") sharedUserAgent] deviceIsLocked]) {
		return NO;
	}
	
	if (![[objc_getClass("VolumeControl") sharedVolumeControl] _HUDIsDisplayableForCategory:nil]) {
		return NO;
	}
	
	return YES;
}

- (void)showVolumeHUDAnimated:(BOOL)animated {
	[volumeHUD setWindowLevel:2200];
	[volumeHUD makeKeyAndVisible];
	
	self.isShowingVolumeHUD = YES;
	
	if (animated) {
		[volumeHUD animateIn];
		[volumeHUD resetSlideOutTimer];
	} else {
		
	}
}

- (void)hideVolumeHUDAnimated:(BOOL)animated {
	self.isShowingVolumeHUD = NO;
	if (animated) {
		
	} else {
		
	}
}

- (float)ringerVolume {
	return ringerVolume;
}

- (float)mediaVolume {
	return mediaVolume;
}

/*- (BOOL)canDisplayHUD {
	if ([[objc_getClass("SpringBoard") sharedApplication] _isDim] || [[objc_getClass("SBUserAgent") sharedUserAgent] deviceIsLocked]) {
		return NO;
	} else {
		return [[objc_getClass("VolumeControl") sharedVolumeControl] _HUDIsDisplayableForCategory:nil];
	}
	
	return YES;
}

- (void)volumeChanged {
	if (!self.isShowingVolumeHUD && [self canDisplayHUD]) {
		[self showVolumeHUDAnimated];
	} else {
		if (!self.isShowingVolumeHUD && ![self canDisplayHUD]) {
			//[volumeHUD animateInAfterRemovalWasCancelled];
		} else {
			if (self.isShowingVolumeHUD) {
				if (![self canDisplayHUD]) {
					[volumeHUD animateOut];
				} else {
					[volumeHUD updateVolume];
					[volumeHUD resetSlideOutTimer];
				}
			}
		}
		[volumeHUD resetSlideOutTimer];
	}
}

- (void)showVolumeHUDAnimated {
	self.isShowingVolumeHUD = YES;
	
    [volumeHUD setWindowLevel:2200];
    [volumeHUD makeKeyAndVisible];
    
    [volumeHUD animateIn];
    [volumeHUD resetSlideOutTimer];
}

- (void)hideVolumeHUDAnimated {
	self.isShowingVolumeHUD = NO;
	
    [volumeHUD animateOut];
}*/

@end
