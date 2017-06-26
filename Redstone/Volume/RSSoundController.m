#import "../Redstone.h"

@implementation RSSoundController

static RSSoundController* sharedInstance;

+ (id)sharedInstance {
	return sharedInstance;
}

- (id)init {
	if (self = [super init]) {
		sharedInstance = self;
		
		mediaController = [objc_getClass("SBMediaController") sharedInstance];
		audioVideoController = [objc_getClass("AVSystemController") sharedAVSystemController];
		
		if ([[[RSPreferences preferences] objectForKey:@"volumeControlEnabled"] boolValue]) {
			[audioVideoController getVolume:&_ringerVolume forCategory:@"Ringtone"];
			[audioVideoController getVolume:&_mediaVolume forCategory:@"Audio/Video"];
			
			if ([mediaController isRingerMuted]) {
				self.ringerVolume = 0.0;
			}
			
			volumeHUD = [[RSVolumeHUD alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 100)];
		}
		
		[self updateNowPlayingInfo:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNowPlayingInfo:) name:@"RedstoneNowPlayingUpdate" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceFinishedLock) name:@"RedstoneDeviceHasFinishedLock" object:nil];
	}
	
	return self;
}

- (void)deviceFinishedLock {
	[self hideVolumeHUDAnimated:NO];
}

- (BOOL)canDisplayHUD {
	if ([[objc_getClass("SpringBoard") sharedApplication] _isDim]) {
		return NO;
	}
	
	if (![[objc_getClass("VolumeControl") sharedVolumeControl] _HUDIsDisplayableForCategory:nil]) {
		return NO;
	}
	
	return YES;
}

- (void)volumeChanged:(float)volume forCategory:(NSString *)category increasingVolume:(BOOL)isIncreasing {
	if (self.isShowingVolumeHUD) {
		if ([category isEqualToString:@"Ringtone"]) {
			if ([mediaController isRingerMuted] && self.ringerVolume == 0.0 && isIncreasing) {
				self.ringerVolume = 1.0/16.0;
				[[objc_getClass("AVSystemController") sharedAVSystemController] setVolumeTo:self.ringerVolume forCategory:@"Ringtone"];
			} else if (!isIncreasing && volume == 1.0/16.0 && (self.ringerVolume == volume || self.ringerVolume == 0.0)) {
				self.ringerVolume = 0.0;
				[[objc_getClass("AVSystemController") sharedAVSystemController] setVolumeTo:self.ringerVolume forCategory:@"Ringtone"];
			} else {
				self.ringerVolume = volume;
			}
		} else if ([category isEqualToString:@"Audio/Video"]) {
			self.mediaVolume = volume;
		}
	}
	
	//[self updateNowPlayingInfo:nil];
	
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

- (void)showVolumeHUDAnimated:(BOOL)animated {
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
		[volumeHUD stopSlideOutTimer];
		[volumeHUD animateOut];
	} else {
		[volumeHUD setHidden:YES];
	}
}

- (void)updateNowPlayingInfo:(id)sender {
	if (volumeHUD) {
		BOOL isShowingHeadphones = [[audioVideoController attributeForKey:@"AVSystemController_HeadphoneJackIsConnectedAttribute"] boolValue];
		[volumeHUD setIsShowingHeadphoneVolume:isShowingHeadphones];
		
		[audioVideoController getVolume:&_ringerVolume forCategory:@"Ringtone"];
		[audioVideoController getVolume:&_mediaVolume forCategory:@"Audio/Video"];
		
		if ([mediaController isRingerMuted]) {
			self.ringerVolume = 0.0;
		}
	}

	MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
		isPlaying = [[(__bridge NSDictionary*)information objectForKey:@"kMRMediaRemoteNowPlayingInfoPlaybackRate"] boolValue];
		artist = [(__bridge NSDictionary*)information objectForKey:@"kMRMediaRemoteNowPlayingInfoArtist"];
		title = [(__bridge NSDictionary*)information objectForKey:@"kMRMediaRemoteNowPlayingInfoTitle"];
		album = [(__bridge NSDictionary*)information objectForKey:@"kMRMediaRemoteNowPlayingInfoAlbum"];
		
		artwork = [UIImage imageWithData:[(__bridge NSDictionary*)information objectForKey:@"kMRMediaRemoteNowPlayingInfoArtworkData"]];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"RedstoneNowPlayingUpdateFinished" object:nil];
		
		if (volumeHUD) {
			if (!isPlaying && !artwork) {
				[volumeHUD setIsShowingMediaControls:NO];
			} else {
				[volumeHUD setIsShowingMediaControls:YES];
			}
		}
	});
}

- (RSVolumeHUD*)volumeHUD {
	return volumeHUD;
}

#pragma mark Now Playing Info

- (BOOL)isPlaying {
	return isPlaying;
}

- (UIImage*)artwork {
	return artwork;
}

- (NSString*)artist {
	return artist;
}

- (NSString*)title {
	return title;
}

- (NSString*)album {
	return album;
}

@end
