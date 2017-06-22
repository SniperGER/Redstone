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

%end // %group volumecontrol

%ctor {
	NSDictionary* settings = [NSDictionary dictionaryWithContentsOfFile:PREFERENCES_PATH];
	
	if ([[settings objectForKey:@"enabled"] boolValue] && [[settings objectForKey:@"volumeControlEnabled"] boolValue]) {
		NSLog(@"[Redstone] Initializing VolumeControl");
		%init(volumecontrol);
	}
}
