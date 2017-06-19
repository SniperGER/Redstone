#import "../Redstone.h"

@implementation RSLockScreenMediaControlsView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		mediaTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 44)];
		[mediaTitleLabel setFont:[UIFont fontWithName:@"SegoeUI-Semilight" size:24]];
		[mediaTitleLabel setTextColor:[UIColor whiteColor]];
		[mediaTitleLabel setText:@"Track Title"];
		[mediaTitleLabel setTextAlignment:NSTextAlignmentCenter];
		[self addSubview:mediaTitleLabel];
		
		mediaSubtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 35, frame.size.width, 30)];
		[mediaSubtitleLabel setFont:[UIFont fontWithName:@"SegoeUI-Semilight" size:17]];
		[mediaSubtitleLabel setTextColor:[UIColor whiteColor]];
		[mediaSubtitleLabel setText:@"Artist Name"];
		[mediaSubtitleLabel setTextAlignment:NSTextAlignmentCenter];
		[self addSubview:mediaSubtitleLabel];
		
		prevTitleButton = [[RSTiltView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
		[prevTitleButton setHighlightEnabled:YES];
		[prevTitleButton setTintColor:[UIColor whiteColor]];
		[prevTitleButton setFrame:CGRectMake(self.frame.size.width/2 - 44/2 - 90, self.frame.size.height - 44, 44, 44)];
		[prevTitleButton.titleLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:24]];
		[prevTitleButton setTitle:@"\uE892"];
		[prevTitleButton addTarget:self action:@selector(previousTrack)];
		[self addSubview:prevTitleButton];
		
		playPauseButton = [[RSTiltView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
		[playPauseButton setHighlightEnabled:YES];
		[playPauseButton setTintColor:[UIColor whiteColor]];
		[playPauseButton setFrame:CGRectMake(self.frame.size.width/2 - 44/2, self.frame.size.height - 44, 44, 44)];
		[playPauseButton.titleLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:24]];
		[playPauseButton setTitle:@"\uE768"];
		[playPauseButton addTarget:self action:@selector(togglePlayPause)];
		[self addSubview:playPauseButton];
		
		nextTitleButton = [[RSTiltView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
		[nextTitleButton setHighlightEnabled:YES];
		[nextTitleButton setTintColor:[UIColor whiteColor]];
		[nextTitleButton setFrame:CGRectMake(self.frame.size.width/2 - 44/2 + 90, self.frame.size.height - 44, 44, 44)];
		[nextTitleButton.titleLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:24]];
		[nextTitleButton setTitle:@"\uE893"];
		[nextTitleButton addTarget:self action:@selector(nextTrack)];
		[self addSubview:nextTitleButton];

		[self setHidden:YES];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNowPlayingInfo:) name:@"RedstoneNowPlayingUpdate" object:nil];
	}
	
	return self;
}

- (void)updateNowPlayingInfo:(id)sender {
	// Thanks to Andrew Wiik for this code (found in iOS Blocks/Curago)
	
	BOOL __block isPlaying;
	NSString* __block title;
	NSString* __block artist;
	UIImage* __block artwork;
	
	MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
		title = [(__bridge NSDictionary*)information objectForKey:@"kMRMediaRemoteNowPlayingInfoTitle"];
		artist = [(__bridge NSDictionary*)information objectForKey:@"kMRMediaRemoteNowPlayingInfoArtist"];
		isPlaying = [[(__bridge NSDictionary*)information objectForKey:@"kMRMediaRemoteNowPlayingInfoPlaybackRate"] boolValue];
		
		// Using the artwork as a verification that there is actually an app that plays/played music
		artwork = [UIImage imageWithData:[(__bridge NSDictionary*)information objectForKey:@"kMRMediaRemoteNowPlayingInfoArtworkData"]];
		
		if (title != nil && ![title isEqualToString:@""]) {
			[mediaTitleLabel setText:title];
		} else {
			[mediaTitleLabel setText:[RSAesthetics localizedStringForKey:@"MEDIA_UNKNOWN_TITLE"]];
		}
		
		if (artist != nil && ![artist isEqualToString:@""]) {
			[mediaSubtitleLabel setText:artist];
		} else {
			[mediaSubtitleLabel setText:[RSAesthetics localizedStringForKey:@"MEDIA_UNKNOWN_ARTIST"]];
		}
		
		[UIView performWithoutAnimation:^{
			if (isPlaying) {
				[playPauseButton setTitle:@"\uE769"];
			} else {
				[playPauseButton setTitle:@"\uE768"];
			}
			
			[playPauseButton layoutIfNeeded];
		}];
		
		if (!isPlaying && !artwork) {
			[self setHidden:YES];
		} else {
			[self setHidden:NO];
		}
	});
}

- (void)previousTrack {
	[(SBMediaController*)[objc_getClass("SBMediaController") sharedInstance] changeTrack:-1];
}


- (void)togglePlayPause {
	[(SBMediaController*)[objc_getClass("SBMediaController") sharedInstance] togglePlayPause];
}

- (void)nextTrack {
	[(SBMediaController*)[objc_getClass("SBMediaController") sharedInstance] changeTrack:1];
}

@end
