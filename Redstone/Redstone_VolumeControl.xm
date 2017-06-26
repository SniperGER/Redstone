#import "Redstone.h"
#import "substrate.h"

%group volumecontrol

%hook SBVolumeHUDView

- (void)layoutSubviews {
	%orig;
	[self setHidden:YES];
}

%end // %hook SBHUDWindow

%hook VolumeControl

- (void)increaseVolume {
	%orig;
	
	float currentVolume;
	NSString* categoryName;
	[[%c(AVSystemController) sharedAVSystemController] getActiveCategoryVolume:&currentVolume andName:&categoryName];
	[[RSSoundController sharedInstance] volumeChanged:(double)currentVolume forCategory:categoryName increasingVolume:YES];
}

- (void)decreaseVolume {
	%orig;
	
	float currentVolume;
	NSString* categoryName;
	[[%c(AVSystemController) sharedAVSystemController] getActiveCategoryVolume:&currentVolume andName:&categoryName];
	[[RSSoundController sharedInstance] volumeChanged:(double)currentVolume forCategory:categoryName increasingVolume:NO];
}

- (float)volumeStepUp {
	if (![[RSSoundController sharedInstance] isShowingVolumeHUD]) {
		return 0;
	}
	
	return %orig;
}

- (float)volumeStepDown {
	if (![[RSSoundController sharedInstance] isShowingVolumeHUD]) {
		return 0;
	}
	
	return %orig;
}

%end // %hook VolumeControl

%hook SBMediaController

- (void)_nowPlayingInfoChanged {
	%orig;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RedstoneNowPlayingUpdate" object:nil];
}

- (void)_nowPlayingAppIsPlayingDidChange {
	%orig;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RedstoneNowPlayingUpdate" object:nil];
}

%end // %hook SBMediaController

void headphoneConnectionChanged(CFNotificationCenterRef center,void *observer,CFStringRef name,const void *object,CFDictionaryRef userInfo) {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RedstoneNowPlayingUpdate" object:nil];
}

%end // %group volumecontrol

%ctor {
	NSDictionary* settings = [NSDictionary dictionaryWithContentsOfFile:PREFERENCES_PATH];
	
	if ([[settings objectForKey:@"enabled"] boolValue] && [[settings objectForKey:@"volumeControlEnabled"] boolValue]) {
		NSLog(@"[Redstone] Initializing VolumeControl");
		%init(volumecontrol);
		
	CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(),NULL,&headphoneConnectionChanged,CFSTR("AVSystemController_HeadphoneJackIsConnectedDidChangeNotification"),NULL,CFNotificationSuspensionBehaviorDeliverImmediately);
	}
}
